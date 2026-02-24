//
//  PayRichTextViewController.m
//
//

#import "PayRichTextViewController.h"
#import <WebKit/WebKit.h>


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kPayTransferCollectionViewCell @"PayTransferCollectionViewCell"
#define kImageDefaultName @"tempShop2"

@interface PayRichTextViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>{
    NSMutableDictionary *allData;
    BOOL bUICreated; // UI是否创建
    NSIndexPath *curselectIndex;
}
@property (nonatomic,strong) WKWebView *webView;

@end

@implementation PayRichTextViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    
}
- (void)viewDidAppear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
}
- (void)refreshSelectPayChannel:(NSNotification *)notification {
    NSArray *arr = (notification.userInfo[@"subContent"]);
    NSInteger maxCount = arr.count;
    
    
    for (int i=0; i<maxCount; i++) {
        if([minstr(arr[i][@"type"]) isEqualToString:@"richtextClass"]){
            NSDictionary *contentDict = arr[i][@"content"];
            allData = [NSMutableDictionary dictionaryWithDictionary:contentDict];
            
            break;
        }
    }
    
    NSString *viewString = @"";
    if(!allData[@"viewString"] || [allData[@"viewString"] isKindOfClass:[NSNull class]] || [minstr(allData[@"viewString"]) isEqualToString:@"<null>"]){
        viewString = @"";
    }else{
        viewString = minstr(allData[@"viewString"]);
    }
//    if(viewString){
//        
//        NSAttributedString * contentString = [[NSAttributedString alloc] initWithData:[viewString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//        [self.tipLabel setAttributedText:contentString];
//        
//        CGFloat height =  [self.tipLabel.attributedText boundingRectWithSize:CGSizeMake(self.tipLabel.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
////        self.viewHeight.constant = height + 5;
////        self.view.height = self.viewHeight.constant;
//        self.tipLabel.hidden = YES;
//    }
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
//    });
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
//    });
    
    if (!self.webView) {
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
        
        self.webView = [[WKWebView alloc] initWithFrame:self.tipLabel.bounds configuration:config];
        self.webView.backgroundColor = [UIColor clearColor];
        [self.webView setOpaque:NO];
        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        self.webView.UIDelegate = self;
        self.webView.navigationDelegate = self;
        [self.view addSubview:self.webView];
    }
   NSString *myStr = [NSString stringWithFormat:@"<meta name='viewport' content='width=device-width, shrink-to-fit=YES' initial-scale='1.0' maximum-scale='1.0' minimum-scale='1.0' user-scalable='no'>"];
   NSString *strHTML = [NSString stringWithFormat:@"%@%@",myStr, viewString];
    [self.webView loadHTMLString:strHTML baseURL:nil];
    [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}
#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
   
 
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *url = navigationAction.request.URL.absoluteString;
    NSLog(@"触发跳转地址：[%@]", url);

    if ([url containsString:@"copy://"]) {
        NSString *results = [url substringFromIndex:7];
        UIPasteboard *paste = [UIPasteboard generalPasteboard];
        paste.string = results;
        [MBProgressHUD showError:YZMsg(@"publictool_copy_success")];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
  
    if (url!= nil &&( [url containsString:@"http"]|[url containsString:@"https"] |[url containsString:@"mailto"])) { //判断类型,根据需求,判断不同类型禁止
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:^(BOOL success) {

        }];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
   }
   
    decisionHandler(WKNavigationActionPolicyAllow);
}
//网页加载完成
//页面加载完后获取高度，设置脚,注意，控制器里不能重写代理方法，否则这里会不执行
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    
    // 不执行前段界面弹出列表的JS代码，关闭系统的长按保存图片
    WeakSelf
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
//        CGFloat heightWeb = webView.scrollView.contentSize.height;
        CGFloat heightWeb = [result floatValue]+ 25;
        strongSelf.webView.frame = CGRectMake(strongSelf.tipLabel.origin.x, strongSelf.tipLabel.origin.y, strongSelf.tipLabel.size.width, heightWeb);
        strongSelf.viewHeight.constant = heightWeb ;
        strongSelf.view.height = strongSelf.viewHeight.constant;
        dispatch_main_async_safe(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
        });
    }];
    
   
    
}
     
#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //网页titl
}

//- (void)webViewDidFinishLoad:(WKWebView *)webView
//{
//    // 获取webView的高度
    
//}

//
//- (BOOL)webView:(WKWebView *)web shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(WKWebView)navigationType
// {
//     NSURL * requestUrl = [request URL];
//     if (([[requestUrl scheme] isEqualToString:@"http"] || [[requestUrl scheme] isEqualToString:@"https"]|| [[requestUrl scheme] isEqualToString:@"mailto"] )&& (navigationType == UIWebViewNavigationTypeLinkClicked)) { //判断类型,根据需求,判断不同类型禁止
//         [[UIApplication sharedApplication] openURL:requestUrl options:@{} completionHandler:^(BOOL success) {
//
//         }];
//         return NO;
//    }
//     return YES;
// }

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    
    if (@available(iOS 11.0, *)) {
        self.gamesCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSelectPayChannel:) name:@"Pay_RefreshPayChannel" object:nil];
//    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshUI];
//    });
}
-(void)exitView{
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.contentView.bottom = _window_height + strongSelf.contentView.frame.origin.y;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.view removeFromSuperview];
        [strongSelf removeFromParentViewController];
    }];
}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pay_RefreshPayChannel" object:nil];
}

-(void)refreshUI{
    if(!bUICreated){
        [self initUI];
    }
}

-(void)initUI{
    bUICreated = true;
    curselectIndex = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (UIImage *)createImageWithColor:(UIColor *)color rect:(CGRect)rect radius:(float)radius {
    //设置长宽
//    CGRect rect = rect;//CGRectMake(0.0f, 0.0f, 80.0f, 30.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *original = resultImage;
    CGRect frame = CGRectMake(0, 0, original.size.width, original.size.height);
    // 开始一个Image的上下文
    UIGraphicsBeginImageContextWithOptions(original.size, NO, 1.0);
    // 添加圆角
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:radius] addClip];
    // 绘制图片
    [original drawInRect:frame];
    // 接受绘制成功的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
