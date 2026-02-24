//
//  profitTypeVC.m
//  yunbaolive
//
//  Created by Boom on 2018/10/11.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "profitTypeVC.h"
#import "profitTypeCell.h"
#import "AddCardViewController.h"
#import "AddUSDTController.h"
#import "AddPpViewController.h"
@implementation WithDrawTypeModel

@end

@interface profitTypeVC ()<UITableViewDelegate,UITableViewDataSource,cellDelegate>{
    UITableView *typeTable;
    NSArray *typeArray;
    UILabel *nothingLabel;
  
    BOOL bOnlyCard;
    AddCardViewController *addCardView;
    AddUSDTController *addUSDTView;
    AddPpViewController *addPpView;
}

@end

@implementation profitTypeVC
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
    addBtn.frame = CGRectMake(_window_width-70, 24+statusbarHeight,70, 45);
    addBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    addBtn.titleLabel.minimumScaleFactor = 0.5;
    [addBtn setTitle:YZMsg(@"profit2_add") forState:0];
    [addBtn setTitleColor:RGB_COLOR(@"#FE0B78", 1) forState:0];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:addBtn];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];
    [self.view addSubview:navtion];
}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setnOnlyCard{
    bOnlyCard = true;
}
- (void)addBtnClick:(UIButton *)sender{
    if (self.types) {
        
        if (self.typeNum > 0) {
            NSString *num = [NSString stringWithFormat:@"%ld", self.typeNum];
            WithDrawTypeModel *type = [self.types filterBlock:^BOOL(WithDrawTypeModel *object) {
                
                NSString *strObj = object.num;
                if ([PublicObj checkNull:strObj]) {
                    strObj = @"";
                }
                return [strObj isEqualToString:num];
            }].firstObject;
            [self pushToAddView:type];
            return;
        }
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"AddWithDrawType_title") message:YZMsg(@"AddWithDrawType_message") preferredStyle:UIAlertControllerStyleAlert];
        for (WithDrawTypeModel *type in self.types) {
            __weak profitTypeVC *weakSelf = self;
            //if (type.status.intValue == 1) {
            UIAlertAction *typeAction = [UIAlertAction actionWithTitle:type.title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                __strong profitTypeVC *strongSelef = weakSelf;
                [strongSelef pushToAddView:type];
            }];
            [alertC addAction:typeAction];
            //}
        }
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:YZMsg(@"AddWithDrawType_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertC addAction:cancel];
        if (self.presentedViewController == nil) {
            [self presentViewController:alertC animated:YES completion:nil];
        }
        
    }else{
        __weak profitTypeVC *weakself = self;
        [self requestTypesAndComplete:^{
            __strong profitTypeVC *strongSelf = weakself;
            [strongSelf addBtnClick:[UIButton new]];
        }];
    }
}

- (void)pushToAddView:(WithDrawTypeModel *)type {
    __weak profitTypeVC *weakSelf = self;
    if (type.num.intValue == 3) {
        //银行卡
        self->addCardView = [[AddCardViewController alloc] init];
        self->addCardView.block = ^{
            [weakSelf requestData];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:self->addCardView animated:YES];
    }else if (type.num.intValue == 6){
        //虚拟币
        self->addUSDTView = [[AddUSDTController alloc] init];
        self->addUSDTView.block = ^{
            [weakSelf requestData];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:self->addUSDTView animated:YES];
    }else{
        self->addPpView = [[AddPpViewController alloc] init];
        self->addPpView.titleStr = type.title;
        self->addPpView.typeNum = type.num;
        self->addPpView.block = ^{
            [weakSelf requestData];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:self->addPpView animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
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
    [self requestData];
    
    if (@available(iOS 11.0, *)) {
        typeTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)requestTypesAndComplete:(void(^)(void))complete{
    NSString *getWithdrawUrl = [NSString stringWithFormat:@"User.getWithdraw&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getWithdrawUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = [info firstObject];
            NSMutableArray *tys = [NSMutableArray array];
            NSArray *support_withdraw_type = infoDic[@"support_withdraw_type"];
            for (NSDictionary *d_type in support_withdraw_type) {
                NSString *title = d_type[@"title"];
                if (![title containsString:@"免提直充"]) {
                    WithDrawTypeModel *type = [[WithDrawTypeModel alloc] init];
                    type.title = title;
                    type.id = d_type[@"id"];
                    type.num = d_type[@"num"];
                    type.status = d_type[@"status"];
                    [tys addObject:type];
                }
            }
            self.types = tys;
            if (complete) {
                complete();
            }
        }else{
            [MBProgressHUD showError:msg];
        }
        [MBProgressHUD hideHUD];
    } fail:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
    }];
}

- (void)requestData {
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.GetUserAccountList" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSMutableArray *typeTmpArray = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *filteredArray = [NSMutableArray arrayWithCapacity:0];
            
            // 過濾掉包含"免提直充"的物件
            for (NSDictionary *item in info) {
                NSString *account = item[@"account"];
                if (![account containsString:@"免提直充"]) {
                    [filteredArray addObject:item];
                }
            }
            
            strongSelf->typeArray = filteredArray;
            
            if (strongSelf->bOnlyCard) {
                NSInteger countMax = strongSelf->typeArray.count;
                for (int i = 0; i < countMax; i++) {
                    // 提现类别如果没有子选项的话 selectedSubBankType 就会-1, 因次会显示全部类型, 没有因为大类型是什么而过滤
                    if (strongSelf.typeNum == -1 || [strongSelf->typeArray[i][@"type"] integerValue] == strongSelf.typeNum) {
                        [typeTmpArray addObject:strongSelf->typeArray[i]];
                    }
                }
                strongSelf->typeArray = typeTmpArray;
            }

            if (strongSelf->typeArray.count > 0) {
                strongSelf->nothingLabel.hidden = YES;
                strongSelf->typeTable.hidden = NO;
                [strongSelf->typeTable reloadData];
            } else {
                strongSelf->nothingLabel.hidden = NO;
                strongSelf->typeTable.hidden = YES;
            }
        } else {
            // 處理錯誤代碼
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
    profitTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profitTypeCell"];
    if (!cell) {
        cell = [[[XBundle currentXibBundleWithResourceName:@"profitTypeCell"] loadNibNamed:@"profitTypeCell" owner:nil options:nil] lastObject];
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
    
    NSString *bankName = minstr([dic valueForKey:@"account_bank"]);
    cell.bankNameLabel.text = bankName;
    
    switch (type) {
        case 1:
            cell.typeImgView.image = [ImageBundle imagewithBundleName:@"profit_alipay"];
            
            cell.nameL.text = [NSString stringWithFormat:@"%@%@",minstr([dic valueForKey:@"account"]),([PublicObj checkNull:[dic valueForKey:@"name"]]?@"":[NSString stringWithFormat:@"(%@)",minstr([dic valueForKey:@"name"])])];
            break;
        case 2:
            cell.typeImgView.image = [ImageBundle imagewithBundleName:@"profit_wx"];
            cell.nameL.text = [NSString stringWithFormat:@"%@",minstr([dic valueForKey:@"account"])];
            break;
        case 3:
        case 6:
            cell.typeImgView.image = [ImageBundle imagewithBundleName:@"profit_card"];
            cell.nameL.text = [NSString stringWithFormat:@"%@%@",minstr([dic valueForKey:@"account"]),([PublicObj checkNull:[dic valueForKey:@"name"]]?@"":[NSString stringWithFormat:@"(%@)",minstr([dic valueForKey:@"name"])])];
            break;
        default:
            cell.typeImgView.image = [ImageBundle imagewithBundleName:@"profit_card"];
            cell.nameL.text = [NSString stringWithFormat:@"%@%@",minstr([dic valueForKey:@"account"]),([PublicObj checkNull:[dic valueForKey:@"name"]]?@"":[NSString stringWithFormat:@"(%@)",minstr([dic valueForKey:@"name"])])];
            break;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
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
            if (code == 0) {
                if (strongSelf == nil) {
                    return;
                }
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
