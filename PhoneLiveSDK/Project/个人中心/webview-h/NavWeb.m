//
//  NavWeb.m
//  yunbaolive
//
//  Created by zqm on 16/5/16.
//  Copyright © 2016年 cat. All rights reserved.
//
#import "NavWeb.h"
#import "LivePlay.h"
#import <WebKit/WebKit.h>
#import "EMASCurl.h"
#import "EMASCurlWebUrlSchemeHandler.h"
#import "EMASCurlWebContentLoader.h"
#import "MyDNSResolver.h"
@interface NavWeb ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
{
    WKWebView *wevView;
    int setvisshenqing;
    UIActivityIndicatorView *testActivityIndicator;//菊花
    NSString *curUrl;

}
@property(nonatomic,strong)UILabel *titleLab;
@end
@implementation NavWeb
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
    setvisshenqing = 1;
    _bLoadedOnce = false;
    //[self navtion];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor = RGB(246, 246, 246);
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.view.backgroundColor = [UIColor whiteColor];
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
    
    CGFloat titleHeight = self.navigationController.navigationBar.frame.size.height;
    
    NSURL *url = [NSURL URLWithString:_urls];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:5];
    [wevView loadRequest:request];
    wevView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 13.0, *)) {
        wevView.frame = CGRectMake(0,titleHeight, _window_width, _window_height - ShowDiff - titleHeight-State_Bar_H-20);
    }else{
        wevView.frame = CGRectMake(0,titleHeight + State_Bar_H, _window_width, _window_height - ShowDiff - State_Bar_H - titleHeight);
    }
    
    [wevView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];

    wevView.UIDelegate = self;
    wevView.navigationDelegate = self;
    [self.view addSubview:wevView];
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    testActivityIndicator.center = self.view.center;
    [self.view addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor blackColor];
    [testActivityIndicator startAnimating]; // 开始旋转
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YZMsg(@"public_back") style:UIBarButtonItemStylePlain target:self action:@selector(doReturn)];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = YZMsg(@"public_back");
    } else {
        self.navigationItem.leftBarButtonItem.title = YZMsg(@"public_back");
    }
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YZMsg(@"public_close") style:UIBarButtonItemStylePlain target:self action:@selector(home)];
}

-(void)home{
    NSLog(@"返回主页");
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf doClose];
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

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *url = navigationAction.request.URL.absoluteString;
    NSLog(@"在发送请求之前，决定是否跳转：%@",url);
    
    // 处理 target="_blank" 的链接
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
        decisionHandler(WKNavigationActionPolicyCancel);
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
// 优化：页面加载完成回调，确保菊花被隐藏
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"Web page finished loading: %@", webView.title);
    [testActivityIndicator stopAnimating]; // 结束旋转
    [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
    _bLoadedOnce = true;
}

// 优化：页面加载失败回调，也要停止菊花
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"Web page failed to load: %@", error);
    [testActivityIndicator stopAnimating]; // 结束旋转
    [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
    _bLoadedOnce = true;
}

// 优化：处理提前加载失败的情况
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"Web page provisional load failed: %@", error);
    [testActivityIndicator stopAnimating]; // 结束旋转
    [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
    _bLoadedOnce = true;
}

#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //网页title
    if ([keyPath isEqualToString:@"title"]) {
        if (object == wevView) {
            //self.titleLab.text = wevView.title;
            self.navigationItem.title = wevView.title;
            // 优化：title 改变时也停止菊花（作为备选方案）
            if (!_bLoadedOnce) {
                [testActivityIndicator stopAnimating]; // 结束旋转
                [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
                _bLoadedOnce = true;
            }
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
//    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0,0, _window_width, 64 + statusbarHeight)];
//    navtion.backgroundColor = navigationBGColor;
//    self.titleLab = [[UILabel alloc]init];
//    self.titleLab.text = _titles;
//    [self.titleLab setFont:navtionTitleFont];
//
//    self.titleLab.textColor = navtionTitleColor;
//    self.titleLab.frame = CGRectMake(0,statusbarHeight,_window_width,84);
//    self.titleLab.textAlignment = NSTextAlignmentCenter;
//    [navtion addSubview:self.titleLab];
//
//    _returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIButton *bigBTN = [[UIButton alloc]initWithFrame:CGRectMake(0,statusbarHeight, _window_width/2, 64)];
//    [bigBTN addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
//    [navtion addSubview:bigBTN];
//    _returnBtn.frame = CGRectMake(8,24 + statusbarHeight,40,40);
//    _returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
//    [_returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
//    [_returnBtn setTitle:@"后退" forState:UIControlStateNormal];
//    [_returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
//    [navtion addSubview:_returnBtn];
//
//    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
////    UIButton *bigBTN = [[UIButton alloc]initWithFrame:CGRectMake(0,statusbarHeight, _window_width/2, 64)];
////    [bigBTN addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
////    [navtion addSubview:bigBTN];
//    _closeBtn.frame = CGRectMake(_window_width - 8 - 40 ,24 + statusbarHeight,40,40);
//    _closeBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
//    [_closeBtn setImage:[ImageBundle imagewithBundleName:@"close@2x.png"] forState:UIControlStateNormal];
//    [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
//    [_closeBtn addTarget:self action:@selector(doClose) forControlEvents:UIControlEventTouchUpInside];
//    [navtion addSubview:_closeBtn];
//    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];
//
//    [self.view addSubview:navtion];
}

-(void)doClose{
    [[[MXBADelegate sharedAppDelegate] topViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)doReturn{
//    NSString *nowUrl = curUrl;
//    NSLog(@"当前请求url为%@",nowUrl);
    if([wevView canGoBack]){
        [wevView goBack];
    }else{
        [self doClose];
    }
}
- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}
@end
