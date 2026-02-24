

#import "setView.h"
#import "InfoEdit2TableViewCell.h"
#import "ZFModalTransitionAnimator.h"
#import "userItemCell5.h"
//#import "getpasswangViewController.h"
#import "PhoneLoginVC.h"
#import "MXBADelegate.h"
#import "webH5.h"
#import "SDImageCache.h"

#import "YBSetListCell.h"
#import "LanguageVC.h"
#import "VKSupportUtil.h"
#import <UserNotifications/UserNotifications.h>
#import <UMCommon/UMCommon.h>

@interface setView ()<UITableViewDataSource,UITableViewDelegate>
{
    int setvissssaaasas;
    int isNewBuid;//判断是不是最新版本
    NSMutableArray *infoArray;
    float MBCache;
}
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@property (nonatomic, assign) BOOL noticeAuth;
@end
@implementation setView
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.backgroundColor = RGB(246, 246, 246);
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.frame = CGRectMake(0, 64+statusbarHeight, _window_width, _window_height - 64 - statusbarHeight);
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[YBSetListCell class] forCellReuseIdentifier:@"YBSetListCell"];

    NSUInteger bytesCache = [[SDImageCache alloc]initWithNamespace:@"default"].totalDiskSize;
    
    //换算成 MB (注意i   OS中的字节之间的换算是1000不是1024)
    MBCache = bytesCache/1000/1000;
    
    [self requestData];
}
- (void)requestData{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:30];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getPerSetting" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        [hud hideAnimated:YES];
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            strongSelf->infoArray = [NSMutableArray arrayWithArray:info];
            NSDictionary *subDic = @{@"name":YZMsg(@"swichLanguage"),@"id":@(112)};
            NSDictionary *shouDic = @{@"name":YZMsg(@"Gesture_Password"),@"id":@(113)};
            NSDictionary *noticeDic = @{@"name":YZMsg(@"swichNotice"),@"id":@(114)};
            [strongSelf->infoArray addObject:subDic];
            [strongSelf->infoArray addObject:shouDic];
            [strongSelf->infoArray addObject:noticeDic];
            [strongSelf.tableView reloadData];
        }
    } fail:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [hud hideAnimated:YES];
    }];
}

/// 更新通知开关状态
- (void)refreshNoticeStatus {
    __weak __typeof(self)weakSelf = self;
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) return;
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusNotDetermined:
            case UNAuthorizationStatusDenied:
                strongSelf.noticeAuth = NO;
                break;
            default:
                strongSelf.noticeAuth = YES;
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.tableView reloadData];
        });
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    setvissssaaasas = 0;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    setvissssaaasas = 1;
    self.navigationController.navigationBarHidden = YES;

    [self navtion];
//    [self.tableView reloadData];
    [self refreshNoticeStatus];
}
-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0,0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor = [UIColor whiteColor];
    UILabel *labels = [[UILabel alloc]init];
    labels.text = _titleStr;
    [labels setFont:navtionTitleFont];
    labels.textColor = navtionTitleColor;
    labels.frame = CGRectMake(0,statusbarHeight,_window_width,84);
    labels.textAlignment = NSTextAlignmentCenter;
    [navtion addSubview:labels];
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
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];

    [self.view addSubview:navtion];
}
-(void)doReturn{    
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIFont *font = [UIFont fontWithName:@"Heiti SC" size:15];
    if (indexPath.section == 0) {
        NSDictionary *subDic = infoArray[indexPath.row];
        YBSetListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YBSetListCell class])];
        cell.nameLab.text = minstr([subDic valueForKey:@"name"]);
        NSString *itemID = minstr([subDic valueForKey:@"id"]);
        cell.nameLab.font = font;
        if ([itemID intValue] == 16) {
            cell.versionLab.hidden = NO;
            cell.versionLab.text = [NSString stringWithFormat:@"%@（%@）",APPVersionNumber,ios_buildVersion];
            cell.updateBtn.hidden = NO;
            cell.detailsLab.hidden = YES;
            
            NSString *buildsss = [NSString stringWithFormat:@"%@",APPVersionNumber];
            if (![[common ios_shelves] isEqual:buildsss]) {
                cell.hidden = NO;
            }else
            {
                cell.hidden = YES;
            }
        }else{
            cell.versionLab.hidden = YES;
            cell.updateBtn.hidden = YES;
            cell.detailsLab.hidden = NO;
            if ([itemID intValue] == 18) {
                cell.detailsLab.text = [NSString stringWithFormat:@"%.2fMB",MBCache];
            }else{
                cell.detailsLab.text = @"";
            }
        }
        if(@available(iOS 13.0, *)){
            UIImageView *accessoryView =[[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:@"arrows_43"]] ;
            cell.accessoryView= accessoryView;
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        if (!cell.updateBtn.hidden) {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (itemID.integerValue == 114) {
            cell.switchButton.hidden = NO;
            cell.accessoryView = nil;
            cell.switchButton.on = (self.noticeAuth && YBToolClass.sharedInstance.noticeSwitch);
        } else {
            cell.switchButton.hidden = YES;
        }
        return cell;
    }else{
        userItemCell5 *cell = [userItemCell5 cellWithTableView:tableView];
        return cell;
        
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 10)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 10)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //判断当前分区返回分区行数
    if (section == 0 ) {
        return infoArray.count;
    }
    else
    {
        return 1;
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //返回分区数
    return 2;
}
- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section
{
    return 0;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger) section
{
    if (section == 0) {
        return 50;
    }
    return 0;
}
//点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        NSDictionary *subDic = infoArray[indexPath.row];
        int idd = [minstr([subDic valueForKey:@"id"]) intValue];
        switch (idd) {
            case 0:
            {
                webH5 *web = [[webH5 alloc]init];
                NSString *url = [NSString stringWithFormat:@"%@&uid=%@&token=%@",minstr([subDic valueForKey:@"href"]),[Config getOwnID],[Config getOwnToken]];
                url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
                web.urls = url;
                [self.navigationController pushViewController:web animated:YES];
            }
                break;
                //            case 15:
                //            {
                //                //修改密码
                //                getpasswangViewController *tuisong = [[getpasswangViewController alloc]init];
                //                [self.navigationController pushViewController:tuisong animated:YES];
                //            }
                //                break;
            case 16:
            {
                //版本更新
                [self getbanben];
            }
                break;
            case 17:
            {
                NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
                NSLog(@"手机系统版本: %@", phoneVersion);
                //手机型号
                NSString* phoneModel = [[UIDevice currentDevice] model];
                NSLog(@"手机型号：%@",phoneModel);
                webH5 *web = [[webH5 alloc]init];
                NSString *url = [NSString stringWithFormat:@"%@&uid=%@&token=%@&version=%@&model=%@",minstr([subDic valueForKey:@"href"]),[Config getOwnID],[Config getOwnToken],phoneVersion,phoneModel];
                url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
                web.urls = url;
                [self.navigationController pushViewController:web animated:YES];
            }
                break;
            case 18:
            {
                //清除缓存
                [self clearCrash];
            }
                break;
            case 112:
            {
                LanguageVC *languageVC = [[LanguageVC alloc]initWithNibName:@"LanguageVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                [self.navigationController pushViewController:languageVC animated:YES];
            }
                break;
            case 113:
            {
                [VKSupportUtil showGesturePassword];
            }
                break;
            case 114:
            {
                if (!self.noticeAuth) {
                    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
                        [[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:nil];
                    }
                    return;
                }
                YBToolClass.sharedInstance.noticeSwitch = !YBToolClass.sharedInstance.noticeSwitch;
                [self.tableView reloadData];
            }
                break;
        }
    }else if (indexPath.section == 1){
        [self quitLogin];
    }
}
-(void)getbanben{
    
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //NSNumber *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];//本地
    
    [[MXBADelegate sharedAppDelegate] checkAppVersionWithHandle:true];
//    NSNumber *build = (NSNumber *)[common ipa_ver];//远程
//    NSComparisonResult r = [APPVersionNumber compare:build];
//    if (r == NSOrderedAscending) {//可改为if(r == -1L)
//        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[common app_ios]] options:@{} completionHandler:^(BOOL success) {
//            
//        }];
//        [MBProgressHUD hideHUD];
//    }else if(r == NSOrderedSame || r == NSOrderedDescending) {//可改为if(r == 0L)
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:YZMsg(@"setView_VersionCheck") message:nil delegate:self cancelButtonTitle:YZMsg(@"publictool_sure") otherButtonTitles:nil, nil];
//        [alert show];
//    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (void)clearTmpPics
{
//    [[SDImageCache sharedImageCache] clearDisk];
 
}
//MARK:-设置tableivew分割线
-(void)setTableViewSeparator
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPa
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
//退出登录函数
-(void)quitLogin
{
//    NSString *aliasStr = [NSString stringWithFormat:@"youke"];
//    [JPUSHService setAlias:aliasStr callbackSelector:nil object:nil];
    [[YBToolClass sharedInstance]quitLogin:NO];
    [MobClick event:@"logout_click" attributes:@{@"eventType": @(1)}];
}
- (void)clearCrash{
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
   
    [_tableView reloadData];
    MBCache = 0;
    [MBProgressHUD showError:YZMsg(@"setView_CleardCache")];
}
@end
