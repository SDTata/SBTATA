#import "YBUserInfoViewController.h"
#import "YBUserInfoListTableViewCell.h"
#import "YBPersonTableViewCell.h"
#import "YBPersonTableViewModel.h"
#import "AppDelegate.h"
#import "PhoneLoginVC.h"
#import "UIImageView+WebCache.h"
#import "VKSupportUtil.h"
#import "YBUserInfoContentTableViewCell.h"
#import "YBUserInfoManager.h"
#import <UMCommon/UMCommon.h>

@interface YBUserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,personInfoCellDelegate,UIAlertViewDelegate, YBUserInfoContentViewDelegate>
{
    NSArray *listArr;
    UIView *navi;
    BOOL _hasBanner;
    int skitTicketCount;
    CGFloat backgroundImageHeight;
}
@property (nonatomic, assign, getter=isOpenPay) BOOL openPay;
@property(nonatomic,strong)NSDictionary *infoArray;//个人信息
@property (nonatomic, strong) YBPersonTableViewModel *model;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView * backgroundImage;
@end
@implementation YBUserInfoViewController
-(void)getPersonInfo{
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //NSNumber *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];//本地 build
    //NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];version
    //NSLog(@"当前应用软件版本:%@",appCurVersion);
//    NSString *build = [NSString stringWithFormat:@"%@",APPVersionNumber];
    //这个地方传版本号，做上架隐藏，只有版本号跟后台一致，才会隐藏部分上架限制功能，不会影响其他正常使用客户(后台位置：私密设置-基本设置 -IOS上架版本号)
    
    NSString *userBaseUrl = [NSString stringWithFormat:@"User.getBaseInfo"];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        NSLog(@"xxxxxxxxx%@",info);
        if(code == 0)
        {
            
            LiveUser *user = [Config myProfile];
            NSDictionary *infoDic = [info firstObject];
            strongSelf.infoArray = infoDic;
            user.user_nicename = minstr([infoDic valueForKey:@"user_nicename"]);
            user.contact_info = minstr([infoDic valueForKey:@"contact_info"]);
            NSArray *app_list = [infoDic valueForKey:@"app_list"];
            NSMutableArray *apps = [NSMutableArray array];
            for (NSDictionary *item in app_list) {
                LiveAppItem *app = [[LiveAppItem alloc] init];
                app.info = minstr(item[@"info"]);
                app.id = minstr(item[@"id"]);
                app.app_name = item[@"app_name"];
                app.app_logo = item[@"app_logo"];
                [apps addObject:app];
            }
            user.app_list = apps.copy;
            // notice
            user.sex = minstr([infoDic valueForKey:@"sex"]);
            user.level =minstr([infoDic valueForKey:@"level"]);
            user.king_level =minstr([infoDic valueForKey:@"king_level"]);
            user.avatar = minstr([infoDic valueForKey:@"avatar"]);
            user.city = minstr([infoDic valueForKey:@"city"]);
            user.level_anchor = minstr([infoDic valueForKey:@"level_anchor"]);
            user.change_name_cost = minstr([infoDic valueForKey:@"change_name_cost"]);
            user.chat_level = minstr([infoDic valueForKey:@"chat_level"]);
            user.show_level = minstr([infoDic valueForKey:@"show_level"]);
            BOOL isBindMobile = [[infoDic valueForKey:@"isBindMobile"] boolValue];
            user.isBindMobile = isBindMobile;
            user.isZeroCharge =[[infoDic valueForKey:@"isZeroCharge"] boolValue];
            user.liveShowChargeTime = [[infoDic valueForKey:@"liveShowChargeTime"] intValue];
            user.mobile = minstr([infoDic valueForKey:@"mobile"]);
            user.user_login = minstr([infoDic valueForKey:@"user_login"]);
            user.coin = minstr(infoDic[@"coin"]);
            user.withdrawInfo = infoDic[@"withdrawInfo"];
            [Config updateProfile:user];
            // TODO 保存系统公告 infoDic[@"system_msg"]
            NSArray *system_msg = [infoDic objectForKey:@"system_msg"];
            [common saveSystemMsg:system_msg];
            [common saveLivePopChargeInfo:[infoDic valueForKey:@"livePopChargeInfo"]];
            NSArray *contactPrice = [infoDic objectForKey:@"live_contact_cost"];
            [common saveContactPrice:contactPrice];
            
            
            
            //保存靓号和vip信息
            NSDictionary *liang = [infoDic valueForKey:@"liang"];
            NSString *liangnum = minstr([liang valueForKey:@"name"]);
            NSDictionary *vip = [infoDic valueForKey:@"vip"];
            NSString *type = minstr([vip valueForKey:@"type"]);
            NSDictionary *subdic = [NSDictionary dictionaryWithObjects:@[type,liangnum] forKeys:@[@"vip_type",@"liang"]];
            [Config saveVipandliang:subdic];
            strongSelf->skitTicketCount = [minstr(infoDic[@"skit_ticket_count"]) intValue];
            strongSelf.model = [YBPersonTableViewModel modelWithDic:infoDic];
            NSArray *list = [infoDic valueForKey:@"list"];
            [common savepersoncontroller:list];//保存在本地，防止没网的时候不显示
            [[NSNotificationCenter defaultCenter]postNotificationName:KUpdateSkitEntrance object:nil];
            
            NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
            if ([rate compare:[NSDecimalNumber decimalNumberWithString:@"0.0"]]!= NSOrderedDescending) {
                [[MXBADelegate sharedAppDelegate] getConfig:false complete:^(NSString *errormsg) {
                    dispatch_main_async_safe(^{
                    [strongSelf.tableView reloadData];
                    });
                }];
            }else{
                dispatch_main_async_safe(^{
                [strongSelf.tableView reloadData];
                });
            }
        }
        else{
            strongSelf->listArr = [NSArray arrayWithArray:[common getpersonc]];
            dispatch_main_async_safe(^{
                [strongSelf.tableView reloadData];
               
            });
        }

    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
       
        strongSelf->listArr = [NSArray arrayWithArray:[common getpersonc]];
        dispatch_main_async_safe(^{
            [strongSelf.tableView reloadData];
            
        });

    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    [tabbarController stopAndHidenWobble];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [self getPersonInfo];
    [self.tableView reloadData];
    self.navigationController.navigationBar.hidden = YES;
    
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    [tabbarController startWobble];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    backgroundImageHeight = 198 + 20;//self.view.frame.size.height * 0.33;
    self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, backgroundImageHeight)];
    self.backgroundImage.image = [ImageBundle imagewithBundleName:@"profile_bg"];
    self.backgroundImage.contentMode = UIViewContentModeScaleToFill;
    self.backgroundImage.clipsToBounds = YES;
    [self.view addSubview: self.backgroundImage];
    [self.view sendSubviewToBack:self.backgroundImage];
    _hasBanner = YES;
    self.navigationController.navigationBar.hidden = YES;
   
//    [self creatNavi];
    listArr = [NSArray arrayWithArray:[common getpersonc]];
    self.view.backgroundColor = RGB(244, 245, 246);
  
    [self setupView];
    WeakSelf
    self.tableView.mj_header  = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
           STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf getPersonInfo];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (strongSelf == nil) {
                return;
            }
            [strongSelf.tableView.mj_header endRefreshing];
//            ((MJRefreshNormalHeader*)strongSelf.tableView.mj_header).ignoredScrollViewContentInsetTop = 0;
        });
    }];
    ((MJRefreshNormalHeader*)self.tableView.mj_header).stateLabel.hidden = YES;
    ((MJRefreshNormalHeader*)self.tableView.mj_header).arrowView.tintColor = [UIColor whiteColor];
    ((MJRefreshNormalHeader*)self.tableView.mj_header).activityIndicatorViewStyle = UIScrollViewIndicatorStyleWhite;
    ((MJRefreshNormalHeader*)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
//    if (@available(iOS 11.0, *)) {
//        ((MJRefreshNormalHeader*)self.tableView.mj_header).ignoredScrollViewContentInsetTop = -[UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
//    } else {
//        ((MJRefreshNormalHeader*)self.tableView.mj_header).ignoredScrollViewContentInsetTop = -20;
//    }
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 30, 0);
    NSString * keyStr = [NSString stringWithFormat:@"%@%@",isShowGesturePwd,[Config getOwnID]];
    BOOL isShowGesturePwd = [[NSUserDefaults standardUserDefaults] boolForKey:keyStr];
    if(!isShowGesturePwd){
        [self localLockBecomeActive];
    }
}

// 手势密码
- (void)localLockBecomeActive {
    [VKSupportUtil showLockGesture:[Config getOwnID] type:FQLockTypeSetting isPush:NO];
    NSString * keyStr = [NSString stringWithFormat:@"%@%@",isShowGesturePwd,[Config getOwnID]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:keyStr];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//MARK:-懒加载
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}
//MARK:-设置tableView
-(void)setupView
{
    [self.tableView registerClass:[YBUserInfoContentTableViewCell class] forCellReuseIdentifier:@"YBUserInfoContentTableViewCell"];
    [self.tableView registerClass:[YBPersonTableViewCell class] forCellReuseIdentifier:@"YBPersonTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YBUserInfoListTableViewCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellReuseIdentifier:@"YBUserInfoListTableViewCell"];
    //[self.tableView registerClass:[YBUserInfoListTableViewCell class] forCellReuseIdentifier:@"YBUserInfoListTableViewCell"];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        float topOffset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        topOffset = 44 - topOffset;
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(topOffset);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(_window_height-ShowDiff/2.5-49);
    }];
    self.tableView.tableFooterView =[[UIView alloc]init];
    //self.tableView.bounces = NO;
    self.tableView.estimatedRowHeight = 10; // 设置一个估计值
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = UIColor.clearColor;//RGB_COLOR(@"#F7F7F7", 1);
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    [self creatNavi];
}
//MARK:-tableviewDateSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)//102
    {
        YBPersonTableViewCell *cell = [YBPersonTableViewCell cellWithTabelView:tableView];
        [cell.iconView sd_setImageWithURL:[NSURL URLWithString:[Config getavatar]]];
        cell.nameLabel.text = [Config getOwnNicename];
        if ([[Config getSex] isEqual:@"1"]) {
            cell.sexView.backgroundColor = RGB_COLOR(@"#796dff", 1);
            [cell.sexView setImage:[ImageBundle imagewithBundleName:@"profile_sex_man"]];
        }
        else{
            cell.sexView.backgroundColor = RGB_COLOR(@"#fa7d99", 1);
            [cell.sexView setImage:[ImageBundle imagewithBundleName:@"profile_sex_woman"]];
        }
//        [cell.levelView setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"leve%@",[Config getLevel]]]];
//        [cell.level_anchorView setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"host_%@",[Config level_anchor]]]];
        NSDictionary *levelDic = [common getUserLevelMessage:[Config getLevel]];
        [cell.levelView sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];
        NSDictionary *levelDic1 = [common getAnchorLevelMessage:[Config level_anchor]];
        [cell.level_anchorView sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic1 valueForKey:@"thumb"])]];

        cell.personCellDelegate = self;
        if (self.infoArray) {
            cell.model = _model;
            cell.infoArray = self.infoArray;
        }
        [cell refreshVaule];
        cell.backgroundColor = [UIColor clearColor];

         
//        CGRect a = cell.frame;
        return cell;
    } else {
        YBUserInfoContentTableViewCell *cell = [[YBUserInfoContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%ldIndexcell",(long)indexPath.row]];
        cell.delegate = self;
        cell.datas = listArr[indexPath.section-1];
        cell.didSelectCellBlock = ^{
            //[self getGuessUserLike];
        };
        return cell;
    }
    /*
    else  {
        static NSString * Identifier=@"YBUserInfoListTableViewCell";
        YBUserInfoListTableViewCell * cell= [tableView dequeueReusableCellWithIdentifier:Identifier];
        
        //if (!cell) {
        //    cell=[[NSBundle mainBundle] loadNibNamed:Identifier owner:self options:nil][0];
        //}
         
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        cell.rightImg.image = [ImageBundle imagewithBundleName:@"arrows_43"];
        //YBUserInfoListTableViewCell *cell = [YBUserInfoListTableViewCell cellWithTabelView:tableView];
        NSDictionary *subdic = listArr[indexPath.section-1][indexPath.row];
        cell.nameL.text = YZMsg(minstr([subdic valueForKey:@"name"]));
        [cell.iconImage sd_setImageWithURL:[NSURL URLWithString:minstr([subdic valueForKey:@"thumb"])]];
        
        if ([subdic[@"id"] intValue] == 15) {
            cell.rightLab.text = minstr([Config getVippayBalance]);
        } if ([subdic[@"id"] intValue] == 10003) {
            cell.rightLab.text = [NSString stringWithFormat:@"%@:%d", YZMsg(@"DramaHomeViewController_title"), skitTicketCount];
        } else{
            cell.rightLab.text = @"";
        }
        cell.backgroundColor = [UIColor clearColor];
        
        if (indexPath.row ==0 && indexPath.section == 1) {
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.bgView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = cell.bgView.bounds;
            maskLayer.path = maskPath.CGPath;
            cell.bgView.layer.mask = maskLayer;
            cell.line.hidden = NO;
        }else if(indexPath.row == [listArr[indexPath.section-1] count] -1 && indexPath.section == listArr.count){
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.bgView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = cell.bgView.bounds;
            maskLayer.path = maskPath.CGPath;
            cell.bgView.layer.mask = maskLayer;
            cell.line.hidden = YES;
        }else{
            cell.line.hidden = NO;
            [cell.bgView.layer.mask removeFromSuperlayer];
        }
        return cell;
    }
     */
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else{
        
        if(listArr!= nil&& listArr.count>(section-1)){
            return 1;//[listArr[section-1] count];
        }else{
            return 0;
        }
    }
   
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0)
//    {
//        return _hasBanner?(328+(80*(SCREEN_WIDTH/350))):328;
//    }
//        return UITableViewAutomaticDimension;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section == 0) {
        return 0.0001;
//    }
//    else
//        return 8;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [UIView new];
    header.backgroundColor = [UIColor clearColor];
    return header;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [UIView new];
    footer.backgroundColor =[UIColor clearColor];
    return footer;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    #warning 根据ID判断 进入 哪个页面（ID 不可随意更改（服务端，客户端））
//     if (indexPath.section > 0) {
//        NSDictionary *subdic = listArr[indexPath.section-1][indexPath.row];
//        int selectedid = [subdic[@"id"] intValue];//选项ID
//        NSString *url = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"href"]];
//        NSString *name = YZMsg(minstr([subdic valueForKey:@"name"]));
//       
//        if (url.length >9) {
//            [self pushH5Webviewinfo:subdic];
//        }else{
//            /*
//             1我的收益  2 我的钻石  4 在线商城 5 装备中心 13 个性设置  19 我的视频
//             其他页面 都是H5
//             */
//            switch (selectedid) {
//                //原生页面无法动态添加
//                case 1:
//                    [self Myearnings:name];//我的收益
//                    break;
//                case 2:
//                    [self MyDiamonds:name];//我的钻石
//                    break;
//                case 4:
//                    [self ShoppingMall];//在线商城
//                    break;
//                case 5:
//                    [self Myequipment];//装备中心
//                    break;
//                case 8:
//                    [self ListTask];//主播任务
//                    break;
//                case 13:
//                    [self SetUp:name];//设置
//                    break;
//                case 15:
//                    [self getVippayInfo:subdic isJump:YES];
//                    break;
//                case 19:
//                    [self mineVideo:name];//我的视频
//                    break;
//                case 100:
//                    [self service:name];
//                    break;
//                case 10000:
//                    [self pushShouZhi];
//                    break;
//                case 10001:
//                    [self pushToVIP];
//                    break;
//                case 10002:
//                    [YBToolClass showService];
//                    break;
//                case 10003:
//                    [self pushToDrama];
//                    break;
//                case 10004:
//                    [self pushMyCreate];
//                    break;
//                default:
//                    break;
//            }
//        }
//
//    }
}
#pragma mark - PersonCellDelegate -
- (void)refreshBannerData:(BOOL)hasData {
   _hasBanner = hasData;
//    [self.tableView reloadData];
}
- (void)refreshWalletData {
   [self getPersonInfo];
}
- (void)pushExchangeRateAction {
    [self.tableView reloadData];
}
- (void)getVippayInfo:(NSDictionary *)subdic isJump:(BOOL)isJump{
    if (isJump) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:subdic];
    NSString *userBaseUrl = [NSString stringWithFormat:@"User.vipPayLogin2&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        NSLog(@"xxxxxxxxx%@",info);
        if(code == 0)
        {
            LiveUser *user = [Config myProfile];
            if ([info isKindOfClass:[NSDictionary class]]) {
                NSDictionary *infoDic = info[@"result"];
                NSDictionary *userDic = infoDic[@"userInfo"];
                NSDictionary * dataDic = infoDic[@"data"];
                NSString * tokenStr = infoDic[@"token"];
                NSString * vipPayUrl = [NSString stringWithFormat:@"%@?t=%@",dataDic[@"h5WebAddress"],tokenStr];
                if(userDic== nil){
                    user.vippay_balance = @"0";
                }else{
                    user.vippay_balance = minstr([userDic valueForKey:@"balance"]);
                }
                
                [Config updateProfile:user];
                dict[@"href"] = vipPayUrl;
                if(isJump){
                    [[YBUserInfoManager sharedManager] pushVipPayWebviewinfo:dict];
                }else{
                    dispatch_main_async_safe(^{
                    [strongSelf.tableView reloadData];
                    });
                }
                if (isJump) {
                    [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                }
            }else{
                user.vippay_balance = @"0";
                [Config updateProfile:user];
                dispatch_main_async_safe(^{
                [strongSelf.tableView reloadData];
                });
            }
            
        }else{
            if (isJump) {
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            }
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (isJump) {
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > 64+statusbarHeight) {
        navi.alpha = 1;
    }else{
        navi.alpha = scrollView.contentOffset.y/(64.00000+statusbarHeight);
    }

    self.backgroundImage.height = backgroundImageHeight - scrollView.contentOffset.y;
}

//退出登录函数
-(void)quitLogin
{
    [[YBToolClass sharedInstance]quitLogin:NO];
}
#pragma mark -
#pragma mark - navi
-(void)creatNavi {
    navi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    navi.backgroundColor = [UIColor clearColor];
    [self.view addSubview:navi];

    //标题
    UILabel *midLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 20+statusbarHeight, _window_width-120, 44)];
    midLabel.backgroundColor = [UIColor clearColor];
    midLabel.font = fontMT(16);
    midLabel.text = [Config getOwnNicename];
    midLabel.textAlignment = NSTextAlignmentCenter;
    midLabel.textColor = [UIColor blackColor];
    [navi addSubview:midLabel];

//    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0, 63.5+statusbarHeight, _window_width, 0.5)];
//    line.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    [navi addSubview:line];
    navi.alpha = 0;
    
}
#pragma mark - YBUserInfoContentViewDelegate
- (void)didSelected:(NSDictionary *)data {
    NSString *scheme = data[@"scheme"];
    if (scheme!= nil && [scheme containsString:@"http"]) {
        [[YBUserInfoManager sharedManager] pushH5Webviewinfo:data];
    }else{
        [[YBUserInfoManager sharedManager] pushVC: data viewController: self];
    }
  
    
    
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": data[@"name"]};
    [MobClick event:@"mine_menues_click" attributes:dict];
}
@end
