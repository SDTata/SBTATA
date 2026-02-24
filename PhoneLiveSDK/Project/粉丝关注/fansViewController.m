#import "fansViewController.h"
#import "fans.h"
#import "fansModel.h"
#import "otherUserMsgVC.h"
@interface  fansViewController()<UITableViewDelegate,UITableViewDataSource,guanzhu>
{
    NSInteger a;
    int setvisfans;
    otherUserMsgVC *person;
    UIView *nothingView;
    UIActivityIndicatorView *testActivityIndicator;//菊花
    YBNoWordView *noNetwork;

}
@property(nonatomic,strong)NSArray *fansmodels;
@property(nonatomic,strong)NSArray *allArray;
@property(nonatomic,strong)UITableView *tableView;
@end
@implementation fansViewController
-(NSArray *)fansmodels{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in self.allArray) {
        fansModel *model = [fansModel modelWithDic:dic];
        [array addObject:model];
    }
    _fansmodels = array;
    return _fansmodels;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    setvisfans = 1;
    [self request];

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    setvisfans = 0;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.allArray = [NSArray array];
    self.tableView =  [[UITableView alloc] initWithFrame:CGRectMake(0,64 + statusbarHeight, _window_width, _window_height - 64 - statusbarHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource  = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self navtion];
    [self createView];

    [self request];
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    testActivityIndicator.center = self.view.center;
    [self.view addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor blackColor];
    [testActivityIndicator startAnimating]; // 开始旋转
}
-(void)createView{
    
    nothingView = [[UIView alloc]initWithFrame:CGRectMake(0, 200, _window_width, 40)];
    nothingView.hidden = YES;
    nothingView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:nothingView];
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _window_width, 20)];
    label1.font = [UIFont systemFontOfSize:14];
    label1.text = YZMsg(@"fansViewController_noFans");
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = RGB_COLOR(@"#333333", 1);
    [nothingView addSubview:label1];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, _window_width, 20)];
    label2.font = [UIFont systemFontOfSize:13];
    label2.text = YZMsg(@"fansViewController_noFansTip");
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = RGB_COLOR(@"#969696", 1);
    [nothingView addSubview:label2];
    
    noNetwork = [[YBNoWordView alloc]initWithImageName:NULL andTitle:NULL withBlock:^(id  _Nullable msg) {
        [self request];
    } AddTo:self.view];
    
}
-(void)request
{

    NSString *url = [NSString stringWithFormat:@"User.getFansList&uid=%@&touid=%@&p=%@",[Config getOwnID],self.fensiUid,@"1"];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0)
        {
            strongSelf.allArray = info;//关注信息复制给数据源
            [strongSelf.tableView reloadData];
            //如果数据为空
            if (strongSelf.allArray.count == 0) {
                [strongSelf.tableView removeFromSuperview];
                strongSelf->nothingView.hidden = NO;
            }else{
                strongSelf->nothingView.hidden = YES;
            }
        }
        else{
            
            strongSelf->nothingView.hidden = NO;
        }
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏

    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        strongSelf->nothingView.hidden = YES;
        if (strongSelf.allArray.count == 0) {
            strongSelf->noNetwork.hidden = NO;
        }

    }];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fansmodels.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    fans *cell = [fans cellWithTableView:tableView];
    fansModel *model = self.fansmodels[indexPath.row];
    cell.model = model;
    cell.guanzhuDelegate = self;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor = navigationBGColor;
    UILabel *label = [[UILabel alloc]init];
    label.text = YZMsg(@"public_fans");
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
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];

}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    person = [[otherUserMsgVC alloc]init];
    fansModel *model = self.fansmodels[indexPath.row];
    person.userID = model.uid;
    [self.navigationController pushViewController:person animated:YES];
 //   [self presentViewController:person animated:YES completion:nil];
}
-(void)doGuanzhu:(NSString *)st button:(UIButton *)clickButton{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:10];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.setAttent" withBaseDomian:YES andParameter:@{@"touid":st,@"is_follow":minnum(!clickButton.selected)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [hud hideAnimated:YES];
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSString *isattent = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"isattent"]];
            if ([isattent isEqualToString:@"1"]) {
                clickButton.selected = YES;
                clickButton.layer.borderColor = vkColorHex(0xc8c8c8).CGColor; // #ff5fed
            }else{
                clickButton.selected = NO;
                clickButton.layer.borderColor = vkColorHex(0xff5fed).CGColor; // #ff5fed
            }
            
            NSDictionary *subdic = [info firstObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLiveplayAttion" object:subdic];
            [strongSelf request];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
    }];
    
}
@end
