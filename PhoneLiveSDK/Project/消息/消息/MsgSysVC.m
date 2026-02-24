//
//  MsgSysVC.m
//  iphoneLive
//
//  Created by YunBao on 2018/8/2.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "MsgSysVC.h"
#import "SystemMsgModel.h"
#import "MsgSysCell.h"
#import "webH5.h"

@interface MsgSysVC ()<UITableViewDelegate,UITableViewDataSource>
{
    int _paging;
    YBNavi *navi;
}
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation MsgSysVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self pullData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataArray = [NSMutableArray array];
    _paging = 1;
    [self creatNavi];
    [self.view addSubview:self.tableView];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [common saveSystemNewMsgs:self.dataArray];
}


-(void)pullData {
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"index.php?service=Message.getList&p=%d",_paging];
    NSArray<SystemMsgModel*> *systemMsg = [common getSystemNewMsgs];
    
WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url  withBaseDomian:NO andParameter:nil data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.tableView.mj_footer endRefreshing];
        [strongSelf.tableView.mj_header endRefreshing];
        if (code == 0) {
            NSArray *infoA = info;
            if (strongSelf->_paging == 1) {
                [strongSelf.dataArray removeAllObjects];
            }
            
            if (infoA.count <=0 ) {
                [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                for (NSDictionary *subDic in infoA) {
                    SystemMsgModel *modelSub = [SystemMsgModel mj_objectWithKeyValues:subDic];
                    NSPredicate *predicateisRead = [NSPredicate predicateWithFormat:@"addtime CONTAINS %@ ",modelSub.addtime];
                    NSArray<SystemMsgModel*> *isreadArray = [systemMsg filteredArrayUsingPredicate:predicateisRead]; //
                    if (isreadArray.count>0) {
                        modelSub.isRead = isreadArray[0].isRead;
                    }
                    [strongSelf.dataArray addObject:modelSub];
                }
            }
            if (strongSelf.dataArray.count <=0) {
                [PublicView showTextNoData:strongSelf.tableView text1:@"" text2:YZMsg(@"MsgSysVC_noMoremsg")];
            }else{
                [common saveSystemNewMsgs:strongSelf.dataArray];
                [PublicView hiddenTextNoData:strongSelf.tableView];
            }
            if (strongSelf.dataArray.count > 0) {
                [[NSUserDefaults standardUserDefaults] setObject:minstr([[strongSelf.dataArray firstObject] valueForKey:@"addtime"]) forKey:@"notifacationOldTime"];
            }
            [strongSelf.tableView reloadData];
            
//            NSArray *visibleCell = strongSelf.tableView.visibleCells;
//            for (MsgSysCell *cell  in visibleCell) {
//                cell.model.isRead = YES;
//                cell.unreadView.hidden = YES;
//            }
            
        }else{
//            [MBProgressHUD showError:msg];
            [MBProgressHUD showError:msg];
        }
    } fail:^(id fail) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.tableView.mj_footer endRefreshing];
        [strongSelf.tableView.mj_header endRefreshing];
    }];

}


+(void)reloadUnreadMsgs:(void (^)(NSInteger unreadNmb))callback{
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"index.php?service=Message.getList&p=%d",1];
    
    NSMutableArray<SystemMsgModel*> *systemMsg = [NSMutableArray array];
    NSArray *arrayOld = [common getSystemNewMsgs];
    if (arrayOld) {
        [systemMsg addObjectsFromArray:arrayOld];
    }
    [[YBNetworking sharedManager] postNetworkWithUrl:url  withBaseDomian:NO andParameter:nil data:nil success:^(int code, NSArray *info, NSString *msg) {
        if (code == 0) {
            NSArray *infoA = info;
            if (infoA.count>0) {
                for (NSDictionary *subDic in infoA) {
                    SystemMsgModel *modelSub = [SystemMsgModel mj_objectWithKeyValues:subDic];
                    NSPredicate *predicateisRead = [NSPredicate predicateWithFormat:@"addtime CONTAINS %@ ",modelSub.addtime];
                    NSArray<SystemMsgModel*> *isreadArray = [systemMsg filteredArrayUsingPredicate:predicateisRead]; //
                    if (isreadArray.count>0) {
                        modelSub.isRead = isreadArray[0].isRead;
                    }else{
                        [systemMsg addObject:modelSub];
                    }
                }
                [common saveSystemNewMsgs:systemMsg];
            }
        }
        NSPredicate *predicateisRead = [NSPredicate predicateWithFormat:@"isRead == 0"];
        NSArray<SystemMsgModel*> *isreadArray = [systemMsg filteredArrayUsingPredicate:predicateisRead]; //
        callback(isreadArray.count);
    } fail:^(id fail) {
        callback(0);
    }];
    
}

-(void)refreshFooter {
    _paging +=1;
    [self pullData];
}
#pragma mark - UITableViewDelegate、UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.01;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.01;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 80;
//}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MsgSysCell *cell = [MsgSysCell cellWithTab:tableView andIndexPath:indexPath];
    SystemMsgModel *model = _dataArray[indexPath.row];
    cell.model = model;
    return cell;
}

//-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    SystemMsgModel *model = _dataArray[indexPath.row];
//    model.isRead = YES;
//    MsgSysCell *cellMsg = (MsgSysCell*)cell;
//    cellMsg.unreadView.hidden = YES;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    SystemMsgModel *model = _dataArray[indexPath.row];
    model.isRead = YES;
    [self.tableView reloadData];
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:model.content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:YZMsg(@"publictool_copy") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = model.content;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertC addAction:confirm];
    [alertC addAction:cancel];
    [self presentViewController:alertC animated:YES completion:nil];
}

#pragma mark - set/get
-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,64+statusbarHeight, _window_width, _window_height - 64-statusbarHeight-ShowDiff)style:UITableViewStylePlain];
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.backgroundColor = Black_Cor;
        
        //先设置预估行高
        _tableView.estimatedRowHeight = 200;
        //再设置自动计算行高
        _tableView.rowHeight = UITableViewAutomaticDimension;
        
        WeakSelf;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf ->_paging = 1;
            [strongSelf pullData];
        }];
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
        _tableView.mj_footer = footer;
        [footer setTitle:YZMsg(@"public_loadMore_loading") forState:MJRefreshStateRefreshing];
        [footer setTitle:YZMsg(@"public_loadMore_noMore") forState:MJRefreshStateIdle];
        [footer setTitle:YZMsg(@"public_loadMore_noMore") forState:MJRefreshStateNoMoreData];
        footer.stateLabel.font = [UIFont systemFontOfSize:15.0f];
        footer.automaticallyHidden = YES;
        
    }
    return _tableView;
}

#pragma mark - 导航
-(void)creatNavi {
    navi = [[YBNavi alloc]init];
    navi.leftHidden = NO;
    navi.rightHidden = NO;
    navi.haveTitleR = YES;
    WeakSelf
    [navi ybNaviLeft:^(id btnBack) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf.dataArray.count > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:minstr([[strongSelf.dataArray firstObject] valueForKey:@"addtime"]) forKey:@"notifacationOldTime"];
        }
        [strongSelf.navigationController popViewControllerAnimated:YES];
    } andRightName:YZMsg(@"MsgSysVC_allRead") andRight:^(id btnBack) {
        STRONGSELF
        [strongSelf.dataArray setValue:@(YES) forKeyPath:@"isRead"];
        [strongSelf.tableView reloadData];
    } andMidTitle:YZMsg(@"MsgSysVC_systemMsg")];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navi.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navi];
    [self.view addSubview:navi];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (void)reloadSystemView{
    UIView *smallNavi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 35)];
    smallNavi.backgroundColor = RGB_COLOR(@"#f9fafb", 1);
    [self.view addSubview:smallNavi];
    
    UIButton *btn = [UIButton buttonWithType:0];
    btn.frame = CGRectMake(0, 0, 35, 35);
    [btn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:0];
    btn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [btn addTarget:self action:@selector(hideSmallView) forControlEvents:UIControlEventTouchUpInside];
    [smallNavi addSubview:btn];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(35, 0, _window_width-70, 35)];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor= RGB_COLOR(@"#636464", 1);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = YZMsg(@"MsgSysVC_systemMsg");
    [smallNavi addSubview:titleLabel];
    _tableView.frame = CGRectMake(0, 35, _window_width, _window_height*0.4-35);
}
- (void)hideSmallView{
    if (self.block) {
        self.block(0);
    }
}
@end
