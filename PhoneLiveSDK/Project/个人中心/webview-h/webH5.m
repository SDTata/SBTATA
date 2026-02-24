//
//  webH5.m
//  yunbaolive
//
//  Created by zqm on 16/5/16.
//  Copyright © 2016年 cat. All rights reserved.
//
#import "webH5.h"
#import "LivePlay.h"
#import <WebKit/WebKit.h>

#import "EMASCurl.h"
#import "EMASCurlWebUrlSchemeHandler.h"
#import "EMASCurlWebContentLoader.h"
#import "MyDNSResolver.h"
@interface webH5 ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
{
    WKWebView *wevView;
    int setvisshenqing;
    UIActivityIndicatorView *testActivityIndicator;//菊花
    NSString *curUrl;
    UIView *navtion;
    UIButton *navSafariBtn;
}
@property(nonatomic,strong)UILabel *titleLab;
@end
@implementation webH5
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
    setvisshenqing = 1;
    _bLoadedOnce = false;
    if (self.isFromHome) { return; }
    [self navtion];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor = RGB(246, 246, 246);
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];


    config.allowsInlineMediaPlayback = true;
    config.allowsPictureInPictureMediaPlayback = true;
    
    NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
   
    [EMASCurlProtocol setBuiltInRedirectionEnabled:NO]; // 让WebView处理重定向
    [EMASCurlProtocol setCacheEnabled:YES];
    [EMASCurlProtocol setDNSResolver:[MyDNSResolver class]]; // 设置DNS解析器
    [EMASCurlProtocol installIntoSessionConfiguration:urlSessionConfig];

    [EMASCurlWebContentLoader initializeInterception];
//    [EMASCurlProtocol setDebugLogEnabled:YES];
    
    EMASCurlWebUrlSchemeHandler *urlSchemeHandler = [[EMASCurlWebUrlSchemeHandler alloc] initWithSessionConfiguration:urlSessionConfig];
    NSString *domainString = nil;
    NSString *domainGetString = nil;
    
    if ([DomainManager respondsToSelector:@selector(sharedInstance)]) {
        DomainManager *domainManager = [DomainManager sharedInstance];
        if ([domainManager respondsToSelector:@selector(domainString)]) {
            domainString = domainManager.domainString;
        }
        if ([domainManager respondsToSelector:@selector(domainGetString)]) {
            domainGetString = domainManager.domainGetString;
        }
    }
    // 检查serverVersion是否存在并有效
    BOOL hasServerVersion = NO;
    if (serverVersion && [serverVersion isKindOfClass:[NSString class]]) {
        hasServerVersion = (serverVersion.length > 0);
    }
    
    if (domainString && domainGetString && [_urls rangeOfString:domainString].location!=NSNotFound && hasServerVersion)
    {
        [config setURLSchemeHandler:urlSchemeHandler forURLScheme:@"http"];
        [config setURLSchemeHandler:urlSchemeHandler forURLScheme:@"https"];
    }else{
        if (![_urls containsString:@"127.0.0"]) {
           
        }else{
            [config setURLSchemeHandler:urlSchemeHandler forURLScheme:@"http"];
            [config setURLSchemeHandler:urlSchemeHandler forURLScheme:@"https"];
        }
    }
    
    [config enableCookieHandler];
    
    
    wevView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    wevView.UIDelegate = self;
    
    
    NSURL *url = [NSURL URLWithString:_urls];
    if(url == nil){
        _urls = [_urls stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        url = [NSURL URLWithString:_urls];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:5];
    [wevView loadRequest:request];
    wevView.backgroundColor = [UIColor whiteColor];
    wevView.frame = CGRectMake(0,self.isFromHome ? 0 : 64 + statusbarHeight, _window_width, self.isFromHome ? VK_SCREEN_H-VK_STATUS_H-VKPX(150) : _window_height-64 - statusbarHeight);
    [wevView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];

    wevView.UIDelegate = self;
    wevView.navigationDelegate = self;
    [self.view addSubview:wevView];
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    testActivityIndicator.center = self.view.center;
    [self.view addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor blackColor];
    [testActivityIndicator startAnimating]; // 开始旋转
    WeakSelf    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
       
    });
}
-(void)home{
    NSLog(@"返回主页");
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.navigationController popViewControllerAnimated:YES];
    });
    
}
// 处理新窗口打开链接
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        // 在新窗口中打开链接
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - 打开Safari
- (void)openInSafari {
    if (wevView.URL.absoluteString.length > 0) {
        NSURL *url = wevView.URL;
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    } else {
        [MBProgressHUD showError:@"无法打开链接"];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *url = navigationAction.request.URL.absoluteString;
    NSLog(@"在发送请求之前，决定是否跳转：%@",url);
    
    // 更新当前URL
    curUrl = url;
    
    // 处理 target="_blank" 的链接
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
        decisionHandler(WKNavigationActionPolicyCancel);
        if (navSafariBtn!= nil) {
            navSafariBtn.hidden = false;
        }
        return;
    }
    if(_bHiddenReturnBtn){
        _returnBtn.hidden = YES;
    }else{
        _returnBtn.hidden = NO;
    }
    if ([url containsString:@"backtohome://"]) {
        [self home];
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
    decisionHandler(WKNavigationActionPolicyAllow);
}
#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //网页title
    if ([keyPath isEqualToString:@"title"]) {
        if (object == wevView) {
            self.titleLab.text = [PublicObj checkNull:wevView.title]?@"":wevView.title;
            [testActivityIndicator stopAnimating]; // 结束旋转
            [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
            _bLoadedOnce = true;
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark 移除观察者
- (void)dealloc
{
    [wevView removeObserver:self forKeyPath:@"title"];
    if ([self.scheme hasPrefix:@"shop://"]) {
        // bill: 暫時取消，先由 beforeDoReturn 取代，目前還仰賴即時更新
//        [[NSNotificationCenter defaultCenter] postNotificationName:KGetBaseInfoNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:KVipPayNotificationMsg object:nil];
    }
}

-(void)navtion{
    if (!navtion) {
        navtion = [[UIView alloc]initWithFrame:CGRectMake(0,0, _window_width, 64 + statusbarHeight)];
        navtion.backgroundColor = navigationBGColor;
    }
    if (!self.titleLab) {
        self.titleLab = [[UILabel alloc]init];
    }
    
    self.titleLab.text = _titles?_titles:@"";
    [self.titleLab setFont:navtionTitleFont];
    
    self.titleLab.textColor = navtionTitleColor;
    self.titleLab.frame = CGRectMake(0,statusbarHeight,_window_width,84);
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    [navtion addSubview:self.titleLab];
    
    if (!_returnBtn) {
        _returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIButton *bigBTN = [[UIButton alloc]initWithFrame:CGRectMake(0,statusbarHeight, _window_width/2, 64)];
        [bigBTN addTarget:self action:@selector(beforeDoReturn) forControlEvents:UIControlEventTouchUpInside];
        [navtion addSubview:bigBTN];
    }
    _returnBtn.frame = CGRectMake(8,24 + statusbarHeight,40,40);
    _returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [_returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
    [_returnBtn addTarget:self action:@selector(beforeDoReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:_returnBtn];
    
    // 添加Safari按钮到自定义导航栏
    navSafariBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    navSafariBtn.frame = CGRectMake(_window_width - 38, 24 + statusbarHeight, 30, 30);
    [navSafariBtn setImage:[ImageBundle imagewithBundleName:@"safari.png"] forState:UIControlStateNormal];
    navSafariBtn.hidden = YES;
    [navSafariBtn addTarget:self action:@selector(openInSafari) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:navSafariBtn];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];

    [self.view addSubview:navtion];
}

- (void)beforeDoReturn {
    if ([self.scheme isEqualToString:@"shop://"]) {
        [MBProgressHUD showMessage:nil];
        _weakify(self)
        [LotteryNetworkUtil getBaseInfoBlock:^(NetworkData *networkData) {
            _strongify(self)
            if (!networkData.status) {
                return;
            }

            NSDictionary *liang = networkData.data[@"liang"];
            NSString *liangnum = minstr([liang valueForKey:@"name"]);
            NSDictionary *vip = networkData.data[@"vip"];
            NSString *type = minstr([vip valueForKey:@"type"]);
            NSDictionary *subdic = [NSDictionary dictionaryWithObjects:@[type,liangnum] forKeys:@[@"vip_type",@"liang"]];
            [Config saveVipandliang:subdic];
            [MBProgressHUD hideHUD];
            [self doReturn];
        }];
        return;
    }
    [self doReturn];
}

-(void)doReturn{
    NSString *nowUrl = minstr(curUrl);
    NSLog(@"当前请求url为%@",nowUrl);
    NSString *aboutUrl = _urls;
    
    if([nowUrl isEqualToString:aboutUrl]  || nowUrl.length == 0 || (nowUrl!=nil &&[nowUrl isEqualToString:@"about:blank"]))
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
        if([wevView canGoBack]){
            [wevView goBack];
            if (navSafariBtn!= nil) {
                navSafariBtn.hidden = YES;
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

}
- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}
@end
