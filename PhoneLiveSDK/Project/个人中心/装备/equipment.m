#import "equipment.h"
#import "Config.h"
#import <WebKit/WebKit.h>


#import "EMASCurl.h"
#import "EMASCurlWebUrlSchemeHandler.h"
#import "EMASCurlWebContentLoader.h"
#import "MyDNSResolver.h"

@interface equipment ()
{
    WKWebView *wevView;
    NSURL *url;
    //四个下划线
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
    UILabel *label4;
}
@end
@implementation equipment
-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor = navigationBGColor;
    
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBtn.frame = CGRectMake(8,24 + statusbarHeight,40,40);
    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];
    
    
    [self.view addSubview:navtion];
    
    
    UISegmentedControl *segment = [[UISegmentedControl alloc]initWithItems:@[YZMsg(@"market_mount"),YZMsg(@"market_liangNum")]];
    
    segment.tintColor = normalColors;
    
    [segment addTarget:self action:@selector(change:) forControlEvents:UIControlEventValueChanged];
    
    segment.frame = CGRectMake(_window_width*0.15,25 + statusbarHeight, _window_width*0.7,30);
    
    UIFont *font1 = [UIFont systemFontOfSize:9];
    UIFont *font2 = [UIFont systemFontOfSize:11];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font1,NSFontAttributeName,normalColors, NSForegroundColorAttributeName, nil];
    [segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:font2,NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [segment setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    segment.selectedSegmentIndex = 0;
    [navtion addSubview:segment];
}
//segment事件
-(void)change:(UISegmentedControl *)segment{
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
    [config setURLSchemeHandler:urlSchemeHandler forURLScheme:@"http"];
    [config setURLSchemeHandler:urlSchemeHandler forURLScheme:@"https"];
    
    [config enableCookieHandler];
    
    
    if (segment.selectedSegmentIndex == 0) {
        [wevView stopLoading];
        //坐骑
        NSString *paths = [[DomainManager sharedInstance].domainGetString stringByAppendingFormat:@"/index.php?g=Appapi&m=Car&a=mycar&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
        paths = [paths stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
        url = [NSURL URLWithString:paths];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [wevView removeFromSuperview];
        wevView = nil;
        wevView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        //wevView.scrollView.scrollEnabled = NO;
        [wevView loadRequest:request];
        wevView.backgroundColor = [UIColor whiteColor];
        wevView.frame = CGRectMake(0,64 + statusbarHeight, _window_width, _window_height-64 - statusbarHeight);
        [self.view addSubview:wevView];
    }
    //靓号
    else if (segment.selectedSegmentIndex == 1){
        [wevView stopLoading];
        NSString *paths = [[DomainManager sharedInstance].domainGetString stringByAppendingFormat:@"/index.php?g=Appapi&m=Liang&a=myliang&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
        paths = [paths stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
        url = [NSURL URLWithString:paths];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [wevView removeFromSuperview];
        wevView = nil;
        wevView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        //wevView.scrollView.scrollEnabled = NO;
        [wevView loadRequest:request];
        wevView.backgroundColor = [UIColor whiteColor];
        wevView.frame = CGRectMake(0,64 + statusbarHeight, _window_width, _window_height-64 - statusbarHeight);
        [self.view addSubview:wevView];
    }

}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    
    [self navtion];
    NSString *paths = [[DomainManager sharedInstance].domainGetString stringByAppendingFormat:@"/index.php?g=Appapi&m=Car&a=mycar&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    paths = [paths stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    url = [NSURL URLWithString:paths];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    wevView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    //wevView.scrollView.scrollEnabled = NO;
    [wevView loadRequest:request];
    wevView.backgroundColor = [UIColor whiteColor];
    wevView.frame = CGRectMake(0,64 + statusbarHeight, _window_width, _window_height-64 - statusbarHeight);
    [self.view addSubview:wevView];
    self.view.backgroundColor = [UIColor whiteColor];
}
@end
