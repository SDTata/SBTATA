//
//  profitTypeVC.m
//  yunbaolive
//
//  Created by Boom on 2018/10/11.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "popularizeTypeVC.h"
#import "popularizeTypeCell.h"
#import "addPopTypeView.h"
#import "AddCardViewController.h"
@interface popularizeTypeVC ()<UITableViewDelegate,UITableViewDataSource,cellDelegate>{
    UITableView *typeTable;
    NSArray *typeArray;
    UILabel *nothingLabel;
    addPopTypeView *addView;
    AddCardViewController *addCardView;
}

@end

@implementation popularizeTypeVC
-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor =navigationBGColor;
    UILabel *label = [[UILabel alloc]init];
    label.text = YZMsg(@"profit2_withDraw_account");
    [label setFont:navtionTitleFont];
    label.textColor = navtionTitleColor;
    label.frame = CGRectMake(0, statusbarHeight+24,_window_width,40);
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
    
    
    UIButton *addBtn = [UIButton buttonWithType:0];
    addBtn.frame = CGRectMake(_window_width-45, 24+statusbarHeight, 45, 45);
    [addBtn setTitle:YZMsg(@"profit2_add") forState:0];
    [addBtn setTitleColor:normalColors forState:0];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:addBtn];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];
    [self.view addSubview:navtion];
}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)addBtnClick:(UIButton *)sender{
    __weak popularizeTypeVC *weakSelf = self;
    addCardView = [[AddCardViewController alloc] init];
    [self.navigationController pushViewController:addCardView animated:YES];
    addCardView.block = ^{
        [weakSelf requestData];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self navtion];
    typeTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight) style:UITableViewStylePlain];
    typeTable.delegate = self;
    typeTable.dataSource = self;
    typeTable.separatorStyle = 0;
    [self.view addSubview:typeTable];
    
    nothingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 150, _window_width, 20)];
    nothingLabel.text = YZMsg(@"profit2_NoAddAccount");
    nothingLabel.textAlignment = NSTextAlignmentCenter;
    nothingLabel.font = [UIFont systemFontOfSize:14];
    nothingLabel.textColor = RGB_COLOR(@"#333333", 1);
    nothingLabel.hidden = YES;
    [self.view addSubview:nothingLabel];
    self.view.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);
    if (@available(iOS 11.0, *)) {
        typeTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self requestData];
}
- (void)requestData{
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.GetUserAccountList" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            strongSelf->typeArray = info;
            if (strongSelf->typeArray.count > 0) {
                strongSelf->nothingLabel.hidden = YES;
                strongSelf->typeTable.hidden = NO;
                [strongSelf->typeTable reloadData];
            }else{
                strongSelf->nothingLabel.hidden = NO;
                strongSelf->typeTable.hidden = YES;
            }
        }else{
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->nothingLabel.hidden = NO;
        strongSelf->typeTable.hidden = YES;
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return typeArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    popularizeTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"popularizeTypeCell"];
    if (!cell) {
        cell = [[[XBundle currentXibBundleWithResourceName:@"popularizeTypeCell"]loadNibNamed:@"popularizeTypeCell" owner:nil options:nil] lastObject];
    }
    cell.delegate = self;
    cell.indexRow = indexPath.row;
    NSDictionary *dic = typeArray[indexPath.row];
    if ([minstr([dic valueForKey:@"id"])isEqual:_selectID]) {
        cell.stateImgView.image = [ImageBundle imagewithBundleName:@"profit_sel"];
    }else{
        cell.stateImgView.image = [ImageBundle imagewithBundleName:@"profit_nor"];
    }
    int type = [minstr([dic valueForKey:@"type"]) intValue];
    switch (type) {
        case 1:
            cell.typeImgView.image = [ImageBundle imagewithBundleName:@"profit_alipay"];
            cell.nameL.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
            break;
        case 2:
            cell.typeImgView.image = [ImageBundle imagewithBundleName:@"profit_wx"];
            cell.nameL.text = [NSString stringWithFormat:@"%@",minstr([dic valueForKey:@"account"])];
            break;
        case 3:
            cell.typeImgView.image = [ImageBundle imagewithBundleName:@"profit_card"];
            cell.nameL.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
            break;

        default:
            break;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = typeArray[indexPath.row];
    if (![minstr([dic valueForKey:@"id"])isEqual:_selectID]) {
        self.block(dic);
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void)delateIndex:(NSInteger)index{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"adminLists_Alert") message:YZMsg(@"profit2_if_delete_account") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertContro addAction:cancleAction];
    WeakSelf
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"BetCell_remove") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSDictionary *dic = strongSelf->typeArray[index];
        [[YBNetworking sharedManager] postNetworkWithUrl:@"User.DelUserAccount" withBaseDomian:YES andParameter:@{@"id":minstr([dic valueForKey:@"id"])} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (strongSelf == nil) {
                return;
            }
            if (code == 0) {
                [MBProgressHUD showError:msg];
                [strongSelf requestData];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
