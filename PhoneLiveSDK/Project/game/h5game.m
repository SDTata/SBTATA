//
//  h5game.m
//  yunbaolive
//
//
#import "h5game.h"
#import "PayViewController.h"
#import "exchangeVC.h"

#import <UMCommon/UMCommon.h>

#define kPrompt_DismisTime    0.2
#define kProportion           0.82

@interface h5game ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
{
    UIActivityIndicatorView *testActivityIndicator;//菊花
    
    // 悬浮菜单
    UIView *assistive_view;
    UIImageView *assistive_bg;
    UIButton *assistive_touchButton;
    UIButton *assistive_refreshButton;
    UIButton *assistive_homeButton;
    UIButton *assistive_exchangeButton;
    UIButton *assistive_serviceButton;
    UIButton *assistive_chargeButton;
    BOOL isAssistiveShow;
    BOOL isAssistiveActive;
    
    NSString *curUrl;
}
@property(nonatomic,strong)UILabel *titleLab;
@end
@implementation h5game

- (BOOL)backgroundCloseEnable {
    return NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [MXBADelegate sharedAppDelegate].isAutoDirection = YES;
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    _bLoadedOnce = false;
    isAssistiveShow = true;
    isAssistiveActive = true;
//    if(iPhoneX){
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
//    }
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeAllScriptMsgHandle];
    [MXBADelegate sharedAppDelegate].isAutoDirection = NO;
    // 移除设备方向变化通知
        
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //禁用屏幕左滑返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [MXBADelegate sharedAppDelegate].isAutoDirection = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  //开启
  [self removeAllScriptMsgHandle];
    [MXBADelegate sharedAppDelegate].isAutoDirection = NO;
  self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent; // 设置状态栏图标为白色
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [MXBADelegate sharedAppDelegate].isAutoDirection = YES;
    self.navigationController.navigationBar.backgroundColor = RGB(246, 246, 246);
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    if (_isFromVideo||_isFromHomeUrls) {
        self.view.backgroundColor = [UIColor whiteColor];
    }else{
        self.view.backgroundColor = [UIColor blackColor];
    }
    if (_isFromHomeUrls) {
        [self enterGameUrl];
    }else{
        [self setWebConfiguration];
    }
   
}

-(void)enterGameUrl {
    NSDictionary *params = [YBToolClass getUrlParamWithUrl:_isFromHomeUrls];
    if (params) {
        NSString *plat = params[@"game"];
        NSString *kid = params[@"kindid"];
        //NSString *ext_1 = params[@"ext_1"];
        if (plat && kid && plat.length > 0 && kid.length > 0) {
            WeakSelf
            [GameToolClass enterHomeH5Game:plat menueName:@"" kindID:kid iconUrlName:@"" autoExchange:NO success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                
            } fail:^{
                
            } finishBlock:^(NSString * _Nonnull url, BOOL bKYorLC) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf.urls = url;
                strongSelf.bKYorLC = bKYorLC;
                [strongSelf setWebConfiguration];
            }];
        }
    }
}
- (void)setWebConfiguration {
    // 设置偏好设置
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

    config.preferences.minimumFontSize = 10;
    //是否支持JavaScript
    config.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
//    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
    config.allowsInlineMediaPlayback = YES;
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    WKUserContentController *userCC = config.userContentController;
    //添加消息处理的handler的name
    [userCC addScriptMessageHandler:self name:@"nomoney"];

    // 网页
    if (!_wevView) {
        _wevView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        
        if (_isFromVideo||_isFromHomeUrls) {
            _wevView.backgroundColor = [UIColor whiteColor];
        }else{
            _wevView.backgroundColor = [UIColor blackColor];
        }
        
        [_wevView setOpaque:NO];
        _wevView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
        if (![YBToolClass isURLEncoded:_urls]) {
            _urls = [YBToolClass customEncodeURLWithCharacterSet:_urls];
        }
        
        NSURL *url = [NSURL URLWithString:_urls];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_wevView loadRequest:request];
    }
    
    [_wevView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    _wevView.UIDelegate = self;
    _wevView.navigationDelegate = self;
    
    CGFloat top = 0;//(self.isFromVideo || self.isFromHomeUrls) ? 0 : State_Bar_H;
    CGFloat bottom = 0;//(self.isFromVideo || self.isFromHomeUrls) ? 0 : ShowDiff;
    [self.view addSubview:_wevView];
    [_wevView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(top);
        make.bottom.mas_equalTo(-bottom);
    }];

    // 菊花
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    testActivityIndicator.center = self.view.center;
    [self.view addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor whiteColor];
    [testActivityIndicator startAnimating]; // 开始旋转
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf->testActivityIndicator stopAnimating];
        [strongSelf->testActivityIndicator setHidesWhenStopped:true];
    });
    
   
//    // 悬浮按钮
    [self assistive];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
//
}



- (void)orientationDidChange:(NSNotification *)notification {
    [self updateWebViewOrientation];
}
- (void)updateWebViewOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    // 根据设备方向更新WKWebView的大小和位置
    CGFloat webViewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat webViewHeight = CGRectGetHeight(self.view.bounds);
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        // 横屏情况
        webViewWidth = CGRectGetHeight(self.view.bounds);
        webViewHeight = CGRectGetWidth(self.view.bounds);
        CGRect webViewFrame = CGRectMake(0, 0, webViewWidth>webViewHeight?webViewWidth:webViewHeight, webViewWidth>webViewHeight?webViewHeight:webViewWidth);
        
        _wevView.frame = webViewFrame;
        testActivityIndicator.center = _wevView.center;
        NSDictionary *dict = @{ @"eventType": @(0),
                                @"menue_name": @"横屏"};
        [MobClick event:@"gamedetail_menue_click" attributes:dict];
    }else{
        
        _wevView.frame = CGRectMake(0, State_Bar_H, _window_width>_window_height?_window_height:_window_width, (_window_width>_window_height?_window_width:_window_height)-ShowDiff-State_Bar_H);
        testActivityIndicator.center = _wevView.center;
    }
    
    
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([minstr(message.name) isEqualToString:@"nomoney"]) {
        // 延迟1帧跳转充值界面
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf==nil) {
                return;
            }
            PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            payView.titleStr = YZMsg(@"Bet_Charge_Title");
            [payView setHomeMode:false];
            [strongSelf.navigationController pushViewController:payView animated:YES];
            [strongSelf refreshAssistiveStatus];
        });
    }
    
    if ([minstr(message.name) isEqualToString:@"test2Params"]) {
//        NSArray *array = message.body;
//        NSString *info = [NSString stringWithFormat:@"有两个参数: %@, %@ !!",array.firstObject,array.lastObject];
    }
}

-(void)removeAllScriptMsgHandle{
    WKUserContentController *userCC = _wevView.configuration.userContentController;
    [userCC removeScriptMessageHandlerForName:@"nomoney"];
}
// WKUIDelegate method to handle new window request
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [_wevView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *url = navigationAction.request.URL.absoluteString;
    NSLog(@"触发跳转地址：[%@]", url);
    if(_bHiddenReturnBtn){
        _returnBtn.hidden = YES;
    }else{
        _returnBtn.hidden = NO;
    }
    if ([url containsString:@"backtohome://"]) {
        [self home];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url containsString:@"copy://"]) {
        NSString *results = [url substringFromIndex:7];
        UIPasteboard *paste = [UIPasteboard generalPasteboard];
        paste.string = results;
        [MBProgressHUD showError:YZMsg(@"publictool_copy_success")];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url containsString:@"phonelive://pay"]) {
        PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        payView.titleStr = YZMsg(@"Bet_Charge_Title");
        [payView setHomeMode:false];
        [self.navigationController pushViewController:payView animated:YES];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
//    NSString *hostname = request.URL.host.lowercaseString;
    if(_bLoadedOnce && _bAllJump){
        decisionHandler(WKNavigationActionPolicyCancel);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
            
        }];
        return;
    }
    
    curUrl = url;
    if(navigationAction.targetFrame ==nil) {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler( WKNavigationActionPolicyAllow );

}

#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //网页title
    if ([keyPath isEqualToString:@"title"]) {
        if (object == _wevView) {
            self.titleLab.text = _wevView.title;
            [testActivityIndicator stopAnimating]; // 结束旋转
            [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
            _bLoadedOnce = true;
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    [testActivityIndicator stopAnimating]; // 结束旋转
    [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
}
#pragma mark 移除观察者
- (void)dealloc
{
    [NSNotificationCenter.defaultCenter postNotificationName:@"KLongVideoCloseGame" object:nil];
    [_wevView removeObserver:self forKeyPath:@"title"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
    [MXBADelegate sharedAppDelegate].isAutoDirection = NO;
}

-(void)assistive{
    // 如果是首页的开启的H5，不需要返回主页按钮，调整相对应位子及宽度
    // CGFloat bg_width = self.isFromHomeUrls ? 215 : 255;
    // CGFloat bottonOffset = self.isFromHomeUrls ? 40 : 0;
    CGFloat bg_width = 255;
    CGFloat bottonOffset = 0;
    
    assistive_view = [UIView new];
    assistive_view.frame = CGRectMake(_window_width - 50, 100, 50, 50);
    assistive_view.alpha = 0.7;
    [self.view addSubview:assistive_view];
    
    // 背景
    assistive_bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 2, bg_width, 50)];
    assistive_bg.alpha = 0;
    [assistive_bg setImage:[ImageBundle imagewithBundleName:@"h5_bg_logout.png"]];
    [assistive_view addSubview:assistive_bg];
    
    // 主按钮
    assistive_touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [assistive_touchButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_fab_close"] forState:UIControlStateNormal];
    [assistive_touchButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_fab_close"] forState:UIControlStateDisabled];
    [assistive_touchButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_fab_close"] forState:UIControlStateHighlighted];
    assistive_touchButton.frame = CGRectMake(0, 0, 50, 50);
    [assistive_touchButton addTarget:self action:@selector(suspensionAssistiveTouch)
                    forControlEvents:UIControlEventTouchUpInside];
    [assistive_view addSubview:assistive_touchButton];
 
    // 刷新按钮
    assistive_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [assistive_refreshButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_refresh"] forState:UIControlStateNormal];
    [assistive_refreshButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_refresh"] forState:UIControlStateDisabled];
    [assistive_refreshButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_refresh"] forState:UIControlStateHighlighted];
    assistive_refreshButton.frame = CGRectMake(50, 5, 40, 40);
    [assistive_refreshButton addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [assistive_view addSubview:assistive_refreshButton];
    
    /*
    if (!self.isFromHomeUrls) {
        // 退出按钮
        assistive_homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [assistive_homeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_fab_back"] forState:UIControlStateNormal];
        [assistive_homeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_fab_back"] forState:UIControlStateDisabled];
        [assistive_homeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_fab_back"] forState:UIControlStateHighlighted];
        assistive_homeButton.frame = CGRectMake(90, 5, 40, 40);
        [assistive_homeButton addTarget:self action:@selector(home) forControlEvents:UIControlEventTouchUpInside];
        [assistive_view addSubview:assistive_homeButton];
    }*/
    // 退出按钮
    assistive_homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [assistive_homeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_fab_back"] forState:UIControlStateNormal];
    [assistive_homeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_fab_back"] forState:UIControlStateDisabled];
    [assistive_homeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_fab_back"] forState:UIControlStateHighlighted];
    assistive_homeButton.frame = CGRectMake(90, 5, 40, 40);
    [assistive_homeButton addTarget:self action:@selector(home) forControlEvents:UIControlEventTouchUpInside];
    [assistive_view addSubview:assistive_homeButton];
     
    // 兑换按钮
    assistive_exchangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [assistive_exchangeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_conversion"] forState:UIControlStateNormal];
    [assistive_exchangeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_conversion"] forState:UIControlStateDisabled];
    [assistive_exchangeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_conversion"] forState:UIControlStateHighlighted];
    assistive_exchangeButton.frame = CGRectMake(130-bottonOffset, 5, 40, 40);
    [assistive_exchangeButton addTarget:self action:@selector(exchange) forControlEvents:UIControlEventTouchUpInside];
    [assistive_view addSubview:assistive_exchangeButton];
    
    // 客服按钮
    assistive_serviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [assistive_serviceButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_kefu"] forState:UIControlStateNormal];
    [assistive_serviceButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_kefu"] forState:UIControlStateDisabled];
    [assistive_serviceButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_kefu"] forState:UIControlStateHighlighted];
    assistive_serviceButton.frame = CGRectMake(170-bottonOffset, 5, 40, 40);
    [assistive_serviceButton addTarget:self action:@selector(service) forControlEvents:UIControlEventTouchUpInside];
    [assistive_view addSubview:assistive_serviceButton];
    
    // 充值按钮
    assistive_chargeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [assistive_chargeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_recharge"] forState:UIControlStateNormal];
    [assistive_chargeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_recharge"] forState:UIControlStateDisabled];
    [assistive_chargeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"h5_icon_recharge"] forState:UIControlStateHighlighted];
    assistive_chargeButton.frame = CGRectMake(210-bottonOffset, 5, 40, 40);
    [assistive_chargeButton addTarget:self action:@selector(charge) forControlEvents:UIControlEventTouchUpInside];
    [assistive_view addSubview:assistive_chargeButton];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changePostion:)];
    [assistive_touchButton addGestureRecognizer:pan];
    
    assistive_refreshButton.alpha = 0;
    assistive_homeButton.alpha = 0;
    assistive_exchangeButton.alpha = 0;
    assistive_serviceButton.alpha = 0;
    assistive_chargeButton.alpha = 0;
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf refreshAssistiveStatus];
    });
    
//    [self performSelector:@selector(checkLeftCoin) withObject:nil afterDelay:20];
}


-(void)checkLeftCoin{
    
}

-(void)reload{
    NSLog(@"刷新网页");
    if (_isFromHomeUrls) {
        [self enterGameUrl];
    }else{
        [_wevView reload];
    }
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"刷新"};
    [MobClick event:@"gamedetail_menue_click" attributes:dict];
}

-(void)home{
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"退出"};
    [MobClick event:@"gamedetail_menue_click" attributes:dict];
    if (_isFromHomeUrls) {
        NSInteger index = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KHomeContainerClickItemAtIndex"
                                                            object:nil
                                                          userInfo:@{@"index": @(index)}];
    } else {
        NSLog(@"返回主页");
        [self forceOrientationPortrait];
        if([common getAutoExchange] && self.isFromHomeUrls == nil){
            [GameToolClass backAllCoin:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                if (code == 0) {
                    
                }else{
                    [MBProgressHUD showError:msg];
                }
            } fail:^{
            }];
        }
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf.wevView evaluateJavaScript:@"document.querySelectorAll('video,audio').forEach(m => { m.pause(); m.src=''; })"
                       completionHandler:nil];

            
            [strongSelf.wevView stopLoading];
            strongSelf.wevView.navigationDelegate = nil;
            strongSelf.wevView.UIDelegate = nil;

            [strongSelf.wevView removeFromSuperview];
            strongSelf.wevView = nil;

            if (strongSelf.isFromVideo) {
                [strongSelf.view.superview removeFromSuperview];
                [strongSelf.view removeFromSuperview];
                [strongSelf removeFromParentViewController];
            } else {
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }
        });
    }
}
//强制竖屏
- (void)forceOrientationPortrait {

    [MXBADelegate sharedAppDelegate].isAutoDirection = NO;
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}

-(void)exchange{
    exchangeVC *VC = [[exchangeVC alloc]init];
    VC.titleStr = YZMsg(@"h5game_Amount_Conversion");
    [self.navigationController pushViewController:VC animated:YES];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"钱包"};
    [MobClick event:@"gamedetail_menue_click" attributes:dict];
}

-(void)charge{
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    [self.navigationController pushViewController:payView animated:YES];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"充值"};
    [MobClick event:@"gamedetail_menue_click" attributes:dict];
}

-(void)service{
    [YBToolClass showService];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"客服"};
    [MobClick event:@"gamedetail_menue_click" attributes:dict];
}

-(void)doReturn{
    NSString *nowUrl = minstr(curUrl);
    NSLog(@"当前请求url为%@",nowUrl);
    NSString *aboutUrl = _urls;
    
    if([nowUrl isEqualToString:aboutUrl]  || nowUrl.length == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated: YES completion:nil];
        
        if ([_isjingpai isEqual:@"isjingpai"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isjingpai" object:nil];
        }
        
    }else if([self.titleLab.text isEqualToString:YZMsg(@"h5game_submit_successfully")] || [self.titleLab.text isEqualToString:YZMsg(@"h5game_application_progress")]|| [self.titleLab.text isEqualToString:YZMsg(@"h5game_My_family_tree")]){
        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated: YES completion:nil];
    }
    else
    {
        if([_wevView canGoBack]){
            [_wevView goBack];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

}

// 悬浮按钮
-(void)suspensionAssistiveTouch {
    isAssistiveActive = !isAssistiveActive;
    
    [self refreshAssistiveStatus];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": isAssistiveActive ? @"展开" : @"关闭"};
    [MobClick event:@"gamedetail_floatbutton_click" attributes:dict];
}

-(void)changePostion:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self.view];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGRect originalFrame = assistive_view.frame;
    if (originalFrame.origin.x >= 0 && originalFrame.origin.x+originalFrame.size.width <= width) {
        originalFrame.origin.x += point.x;
    }
    if (originalFrame.origin.y >= 0 && originalFrame.origin.y+originalFrame.size.height <= height) {
        originalFrame.origin.y += point.y;
    }
    assistive_view.frame = originalFrame;
    [pan setTranslation:CGPointZero inView:self.view];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self beginPoint];
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
           
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self changePoint];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self endPoint];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            [self endPoint];
        }
            break;
            
        default:
            break;
    }
    
}
- (void)beginPoint {
    
    assistive_touchButton.enabled = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    WeakSelf
    [UIView animateWithDuration:kPrompt_DismisTime animations:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->assistive_view.alpha = 1.0;
    }];
}
- (void)changePoint {
    
    BOOL isOver = NO;
    
    CGRect frame = assistive_view.frame;
    
    if (frame.origin.x < 0) {
        frame.origin.x = 0;
        isOver = YES;
    } else if (frame.origin.x+frame.size.width > _window_width) {
        frame.origin.x = _window_width - frame.size.width;
        isOver = YES;
    }
    
    if (frame.origin.y < 20 + statusbarHeight) {
        frame.origin.y = 20 + statusbarHeight;
        isOver = YES;
    } else if (frame.origin.y+frame.size.height > _window_height) {
        frame.origin.y = _window_height - frame.size.height;
        isOver = YES;
    }
    if (isOver) {
        WeakSelf
        [UIView animateWithDuration:kPrompt_DismisTime animations:^{
            STRONGSELF
            if (strongSelf==nil) {
                return;
            }
            strongSelf->assistive_view.frame = frame;
        }];
    }
    assistive_touchButton.enabled = YES;
    
}
static CGFloat _allowance = 30;
- (void)endPoint {
    CGFloat posX = assistive_view.frame.origin.x;
    CGFloat posY = assistive_view.frame.origin.y;
    CGRect frame = assistive_view.frame;
    if (posX <= _window_width / 2 - assistive_view.width/2) {

        if (posY >= _window_height - assistive_view.height - _allowance - (20 + statusbarHeight)) {
            frame.origin.y = _window_height - assistive_view.height ;
        }else{
            if (posY <= 20 + statusbarHeight + _allowance) {
                frame.origin.y = 20 + statusbarHeight;
            }else{
                frame.origin.x = 0;
            }
        }
    }else
    {
        if (posY >= _window_height - assistive_view.height - _allowance - (20 + statusbarHeight)) {
            frame.origin.y = _window_height - assistive_view.height;
        }else{
            if (posY <= 20 + statusbarHeight + _allowance) {
                frame.origin.y = 20 + statusbarHeight;
            }else{
                frame.origin.x = _window_width - assistive_view.width;
            }
        }
    }
    WeakSelf
    [UIView animateWithDuration:kPrompt_DismisTime animations:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->assistive_view.frame = frame;
    }];
    assistive_touchButton.enabled = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hidenFloatButton) withObject:nil afterDelay:3];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"拖动"};
    [MobClick event:@"gamedetail_floatbutton_click" attributes:dict];
//    [self performSelector:@selector(setAlpha) withObject:nil afterDelay:3];
}

-(void)refreshAssistiveStatus {
    assistive_touchButton.alpha = 1;
    WeakSelf
    [UIView animateWithDuration:kPrompt_DismisTime animations:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        //CGFloat bg_width = strongSelf.isFromHomeUrls ? 215 : 255;
        CGFloat bg_width = 255;
        CGRect bg_frame = strongSelf->assistive_bg.frame;
        CGRect view_frame = strongSelf->assistive_view.frame;
        CGFloat bg_alpha = 0;
        CGFloat btn_alpha = 0;
        if(strongSelf->isAssistiveActive){
            bg_frame.origin.x = 0;
            bg_alpha = 0.8;
            btn_alpha = 1;
            view_frame.size.width = bg_width;
            strongSelf->assistive_touchButton.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
        }else{
            bg_frame.origin.x = 15;
            bg_alpha = 0;
            btn_alpha = 0;
            view_frame.size.width = 50;
            strongSelf->assistive_touchButton.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        }
        strongSelf->assistive_bg.frame = bg_frame;
        strongSelf->assistive_bg.alpha = bg_alpha;
        strongSelf->assistive_view.frame = view_frame;
        
        strongSelf->assistive_refreshButton.alpha = btn_alpha;
        strongSelf->assistive_homeButton.alpha = btn_alpha;
        strongSelf->assistive_exchangeButton.alpha = btn_alpha;
        strongSelf->assistive_serviceButton.alpha = btn_alpha;
        strongSelf->assistive_chargeButton.alpha = btn_alpha;
        strongSelf->assistive_touchButton.alpha = strongSelf->isAssistiveActive?1:0.7;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf endPoint];
        //        [kWindow endEditing:YES];
    }];
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hidenFloatButton) withObject:nil afterDelay:3];
}
-(void)hidenFloatButton {
    if (isAssistiveActive) {
        [self suspensionAssistiveTouch];
    }
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}
-(BOOL)shouldAutorotate{
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;

}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
@end
