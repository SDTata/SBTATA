//
//  webH5.m
//  yunbaolive
//
//  Created by zqm on 16/5/16.
//  Copyright © 2016年 cat. All rights reserved.
//
#import "HomeWebViewController.h"
#import <WebKit/WebKit.h>
#import "EMASCurl.h"
#import "EMASCurlWebUrlSchemeHandler.h"
#import "EMASCurlWebContentLoader.h"
#import "MyDNSResolver.h"
#import "PayViewController.h"
@interface HomeWebViewController ()<WKUIDelegate, WKNavigationDelegate>
{
    WKWebView *wevView;
   
    UIActivityIndicatorView *testActivityIndicator;//菊花
    NSString *curUrl;
    UIView *navtion;

}
@property(nonatomic,strong)UILabel *titleLab;
@end
@implementation HomeWebViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
   
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

    NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
   
    [EMASCurlProtocol setBuiltInRedirectionEnabled:NO]; // 让WebView处理重定向
    [EMASCurlProtocol setCacheEnabled:YES];
    [EMASCurlProtocol setDNSResolver:[MyDNSResolver class]]; // 设置DNS解析器
    [EMASCurlProtocol installIntoSessionConfiguration:urlSessionConfig];

    [EMASCurlWebContentLoader initializeInterception];
//    [EMASCurlProtocol setDebugLogEnabled:YES];
    
    EMASCurlWebUrlSchemeHandler *urlSchemeHandler = [[EMASCurlWebUrlSchemeHandler alloc] initWithSessionConfiguration:urlSessionConfig];
    [config setURLSchemeHandler:urlSchemeHandler forURLScheme:@"http"];
    [config setURLSchemeHandler:urlSchemeHandler forURLScheme:@"https"];
    
    [config enableCookieHandler];
    
    config.allowsInlineMediaPlayback = true;
    config.allowsPictureInPictureMediaPlayback = true;
    wevView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    
    
    NSURL *url = [NSURL URLWithString:_urls];
    if(url == nil){
        _urls = [_urls stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        url = [NSURL URLWithString:_urls];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:5];
    [wevView loadRequest:request];
    wevView.backgroundColor = [UIColor whiteColor];
    wevView.frame = CGRectMake(0,64+statusbarHeight/2, _window_width, _window_height-44-statusbarHeight/2-ShowDiff/2- 68 - (!iPhoneX?8:0));
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

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *url = navigationAction.request.URL.absoluteString;
    NSLog(@"在发送请求之前，决定是否跳转：%@",url);
    
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


@end
