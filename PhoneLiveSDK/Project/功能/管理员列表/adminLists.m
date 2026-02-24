#import "adminLists.h"
#import "adminCell.h"
#import "fansModel.h"
@interface adminLists ()<UITableViewDelegate,UITableViewDataSource,adminCellDelegate>
@property(nonatomic,strong)NSArray *fansmodels;
@property(nonatomic,strong)NSArray *allArray;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSString *addAdmins;

@end
@implementation adminLists
-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor =navigationBGColor;
    UILabel *label = [[UILabel alloc]init];
    label.text = YZMsg(@"upmessageInfo_management_list");
    [label setFont:navtionTitleFont];
    label.textColor = navtionTitleColor;
    label.frame = CGRectMake(0, statusbarHeight,_window_width,84);
    label.textAlignment = NSTextAlignmentCenter;
    [navtion addSubview:label];
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *bigBTN = [[UIButton alloc]initWithFrame:CGRectMake(0, statusbarHeight, _window_width/2, 64)];
    [bigBTN addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:bigBTN];
    returnBtn.frame = CGRectMake(8,24 + statusbarHeight,40,40);
    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];
    UIButton *btnttttt = [UIButton buttonWithType:UIButtonTypeCustom];
    btnttttt.backgroundColor = [UIColor clearColor];
    [btnttttt addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    btnttttt.frame = CGRectMake(0,0,100,64);
    [navtion addSubview:btnttttt];
    [self.view addSubview:navtion];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height, _window_width, 5) andColor:RGB(244, 245, 246) andView:self.view];

}
-(void)doReturn{
    [self.delegate adminZhezhao];
}

-(NSArray *)fansmodels{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in self.allArray) {
        fansModel *model = [fansModel modelWithDic:dic];
        [array addObject:model];
    }
    _fansmodels = array;
    return _fansmodels;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(adminxin) name:@"adminlist" object:nil];
}
-(void)listMessage{
    
    NSDictionary *subdic = @{
                             @"liveuid":[Config getOwnID]
                             };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.getAdminList" withBaseDomian:YES andParameter:subdic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            strongSelf.allArray = [[info firstObject] valueForKey:@"list"];//关注信息复制给数据源
            strongSelf.addAdmins = [[info firstObject] valueForKey:@"total"];//总的管理员
            dispatch_main_async_safe(^{
                [strongSelf.tableView reloadData];
            });
        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
}
-(void)adminxin{
    [self navtion];
    self.allArray = [NSArray array];
    self.fansmodels = [NSArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 69+statusbarHeight, _window_width, _window_height-69-statusbarHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    [self.view addSubview:self.tableView];
    [self listMessage];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _window_width, 30)];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    label.text = [NSString stringWithFormat:@"    %@（%ld/%@）",YZMsg(@"adminLists_currentManager"),self.allArray.count,self.addAdmins];
    return label;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    adminCell *cell = [adminCell cellWithTableView:tableView];
    cell.delegate = self;
    fansModel *model = self.fansmodels[indexPath.row];
    cell.model = model;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //弹窗
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)doGuanzhu:(NSString *)st button:(UIButton *)clickButton{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:10];
//    WeakSelf
    NSString *url = [NSString stringWithFormat:@"User.setAttention&uid=%@&showid=%@&token=%@&is_follow=%@",[Config getOwnID],st,[Config getOwnToken],!clickButton.selected?@"1":@"0"];
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [hud hideAnimated:YES];
        if (code == 0) {
//            NSString *isattent = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"isattent"]];
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
    }];
    clickButton.selected = !clickButton.selected;
    
    if (clickButton.selected) {
        clickButton.layer.borderColor = vkColorHex(0xc8c8c8).CGColor; // #ff5fed
    }else{
        clickButton.layer.borderColor = vkColorHex(0xff5fed).CGColor; // #ff5fed
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (void)delateAdminUser:(fansModel *)model{
    
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"adminLists_Alert") message:[NSString stringWithFormat:@"%@%@%@？",YZMsg(@"adminLists_ifCancel"),model.name,YZMsg(@"adminLists_managerRule")] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"adminLists_No") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertContro addAction:cancleAction];
    WeakSelf
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *setadmin = @{
                                   @"liveuid":[Config getOwnID],
                                   @"touid":model.uid,
                                   };
        [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.setAdmin" withBaseDomian:YES andParameter:setadmin data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (code == 0) {
                NSString *isadmin = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"isadmin"]];
                [strongSelf.delegate setAdminSuccess:isadmin andName:model.name andID:model.uid];
                [strongSelf listMessage];
            }else{
                [MBProgressHUD showError:msg];
            }
        } fail:^(NSError * _Nonnull error) {
            
        }];

    }];
    [alertContro addAction:sureAction];
    if (self.presentedViewController == nil) {
        [self presentViewController:alertContro animated:YES completion:nil];
    }
    
}
@end
