//
//  popWebH5.m
//  yunbaolive
//
//  Created by zqm on 16/5/16.
//  Copyright © 2016年 cat. All rights reserved.
//
#import "popWebH5.h"
#import "LivePlay.h"
#import <WebKit/WebKit.h>
#import "EMASCurl.h"
#import "EMASCurlWebUrlSchemeHandler.h"
#import "EMASCurlWebContentLoader.h"
#import "MyDNSResolver.h"
@interface popWebH5 ()<WKUIDelegate, WKNavigationDelegate>
{
    WKWebView *wevView;
    int setvisshenqing;
    UIActivityIndicatorView *testActivityIndicator;//菊花
    NSString *curUrl;
    BOOL bCloseing;

}
@property(nonatomic,strong)UILabel *titleLab;
@end
@implementation popWebH5
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    setvisshenqing = 1;
    _bLoadedOnce = false;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor = RGB(246, 246, 246);
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.masksToBounds = YES;
    self.view.layer.cornerRadius = 10;
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

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
    if(!self.hightRate){
        self.hightRate = 0.78;
    }
    
    NSURL *url = [NSURL URLWithString:_urls];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:5];
    [wevView loadRequest:request];
    wevView.backgroundColor = [UIColor whiteColor];
    wevView.frame = CGRectMake(0, 0, _window_width, _window_height * self.hightRate);
    [wevView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];

    wevView.UIDelegate = self;
    wevView.navigationDelegate = self;
    [self.view addSubview:wevView];
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    testActivityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y/2);
    [self.view addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor blackColor];
    [testActivityIndicator startAnimating]; // 开始旋转
    
    self.view.frame = CGRectMake(0, _window_height, _window_width, _window_height * self.hightRate);
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.view.frame = CGRectMake(0, _window_height * (1-strongSelf.hightRate), _window_width, _window_height * strongSelf.hightRate);
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(finished){
            strongSelf.view.frame = CGRectMake(0, _window_height * (1-strongSelf.hightRate), _window_width, _window_height * strongSelf.hightRate);
        }
    }];
    
    if (self.isBetExplain) {
        [self navtion];
        
        CGRect frame = wevView.frame;
        frame.origin.x = 10;
        frame.size.width = frame.size.width -20;
        wevView.frame = frame;
        wevView.scrollView.showsVerticalScrollIndicator = NO;
    }
}
-(void)home{
    NSLog(@"返回主页");
    [self doCloseWeb];
    
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *url = navigationAction.request.URL.absoluteString;
    NSLog(@"在发送请求之前，决定是否跳转：%@",url);
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
    
    if (!navigationAction.targetFrame) {
        decisionHandler(WKNavigationActionPolicyCancel);
        NSURL *url = navigationAction.request.URL;
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            [app openURL:url options:@{} completionHandler:^(BOOL success) {
                
            }];
            return;
        }
    }
    
    curUrl = url;
    decisionHandler(WKNavigationActionPolicyAllow);
}
#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //网页title
    if ([keyPath isEqualToString:@"title"]) {
        if (object == wevView) {
            self.titleLab.text = wevView.title;
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
}

-(void)navtion{
    CGFloat height = 40;
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0,0, _window_width, height)];
    navtion.verticalColors = @[vkColorHex(0xF8C9FE), vkColorHex(0xFDEBFF)];
    navtion.layer.cornerRadius = 10;
    navtion.layer.maskedCorners = kCALayerMinXMinYCorner|kCALayerMaxXMinYCorner;
    
    self.titleLab = [[UILabel alloc]init];
    self.titleLab.text = _titles;
    [self.titleLab setFont:navtionTitleFont];
    self.titleLab.textColor = navtionTitleColor;
    self.titleLab.frame = CGRectMake(0,0,_window_width,height);
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    [navtion addSubview:self.titleLab];
    
    _returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnBtn.frame = CGRectMake(_window_width-height,0,height,height);
    _returnBtn.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    [_returnBtn setImage:[ImageBundle imagewithBundleName:@"close.png"] forState:UIControlStateNormal];
    [_returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:_returnBtn];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];

    [self.view addSubview:navtion];
    
    wevView.frame = CGRectMake(0, height, _window_width, _window_height * self.hightRate - height);
}

-(void)doReturn{
    NSString *nowUrl = minstr(curUrl);
    NSLog(@"当前请求url为%@",nowUrl);
    NSString *aboutUrl = _urls;
    
    if([nowUrl isEqualToString:aboutUrl]  || nowUrl.length == 0)
    {
        [self doCloseWeb];
    }
    else
    {
        if([wevView canGoBack]){
            [wevView goBack];
        }else{
            [self doCloseWeb];
        }
    }
}
-(void)doCloseWeb{
    if (self.isPresent) {
        [self hideAlert];
        return;
    }
    if(bCloseing)
        return;
    bCloseing = true;
//    self.closeCallback();
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.view.frame = CGRectMake(0, _window_height, _window_width, _window_height * strongSelf.hightRate);
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(finished){
            strongSelf.view.frame = CGRectMake(0, _window_height, _window_width, _window_height * strongSelf.hightRate);
            strongSelf.closeCallback();
        }
    }];
}
- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}
@end
