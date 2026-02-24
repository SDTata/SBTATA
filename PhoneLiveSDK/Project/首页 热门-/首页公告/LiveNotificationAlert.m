//
//  LiveNotificationAlert.m
//  phonelive2
//
//  Created by test on 2021/6/10.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LiveNotificationAlert.h"
#import <WebKit/WebKit.h>
@interface LiveNotificationAlertCell : UITableViewCell
@property (strong, nonatomic) UIImageView *iv_background;
@property (strong, nonatomic) UILabel *lb_title;
@property (strong, nonatomic) NSNumber *state;


@end
@implementation LiveNotificationAlertCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initialUI];
    }
    return self;
}
- (void)initialUI{
    self.iv_background = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [self addSubview:self.iv_background];
    
    self.lb_title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.lb_title.textAlignment = NSTextAlignmentCenter;
    self.lb_title.textColor = [UIColor blackColor];
    self.lb_title.font = [UIFont systemFontOfSize:10];
    self.lb_title.numberOfLines = 2;
    self.lb_title.adjustsFontSizeToFitWidth = YES;
    self.lb_title.adjustsFontForContentSizeCategory = YES;
    self.lb_title.minimumScaleFactor = 0.5;
    [self addSubview:self.lb_title];
    [self.iv_background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-5);
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.lb_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-11);
        make.top.mas_equalTo(4);
        make.bottom.mas_equalTo(0);
    }];
   
    
    
    
}
- (void)setState:(NSNumber *)state{
    _state = state;
    if ([state boolValue]) {
        self.iv_background.image = [ImageBundle imagewithBundleName:@"anniu_bg111"];
        self.lb_title.textColor = [UIColor whiteColor];
       
    }else{
        self.lb_title.textColor = [UIColor blackColor];
        self.iv_background.image = [ImageBundle imagewithBundleName:@"anniu_bg222"];
    }
}
@end

@interface LiveNotificationAlert()<UITableViewDelegate,UITableViewDataSource,WKUIDelegate,WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tb_titles;
@property (weak, nonatomic) IBOutlet WKWebView *text_content;
@property (weak, nonatomic) IBOutlet UIImageView *iv_logo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_alertCenterY;
@property (weak, nonatomic) IBOutlet UIView *bgView;


@property (nonatomic, copy)FinishBlock blockFinished;

@property(nonatomic,assign) NSInteger currentSelectedIndex;
@property(nonatomic,strong)NSArray *datas;

@end

@implementation LiveNotificationAlert

- (void)awakeFromNib{
    [super awakeFromNib];
    self.titleLabel.text = YZMsg(@"LiveNotif_AlertTitle");
    self.bgView.layer.cornerRadius = 10;
    self.bgView.layer.masksToBounds = YES;
    
    WKWebViewConfiguration *config = self.text_content.configuration;
//    config.preferences.minimumFontSize = 10;
    
    //是否支持JavaScript
    config.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
//    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
    config.allowsInlineMediaPlayback = YES;
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
   

    self.text_content.backgroundColor = [UIColor clearColor];
    [self.text_content setOpaque:NO];
    self.text_content.UIDelegate = self;
    self.text_content.navigationDelegate = self;

    
    
    
    
}
+ (instancetype)instanceNotificationAlertWithMessages:(NSArray *)messages{
    LiveNotificationAlert *alert = [[[XBundle currentXibBundleWithResourceName:@"LiveNotificationAlert"] loadNibNamed:@"LiveNotificationAlert" owner:nil options:nil] firstObject];
    alert.tb_titles.delegate = alert;
    alert.tb_titles.dataSource = alert;
    [alert.tb_titles registerClass:[LiveNotificationAlertCell class] forCellReuseIdentifier:@"LiveNotificationAlertCell"];
   
    if (messages.count>0) {
        NSDictionary *subDic = messages[0];
        NSString *contentHtml = subDic[@"content"];
        if (contentHtml!= nil && contentHtml.length>0) {
            
            NSString *headerString = @"<header><meta name='viewport' content='width=device-width, initial-scale=0.95, maximum-scale=0.95, minimum-scale=0.8, user-scalable=no'></header>";
            [alert.text_content loadHTMLString:[headerString stringByAppendingString:contentHtml] baseURL:nil];
            
//            NSData *htmlData = [contentHtml dataUsingEncoding:NSUTF8StringEncoding];
//            NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:htmlData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
//            alert.text_content.attributedText = attrStr;
        }
    }
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if(strongSelf == nil){
            return;
        }
        alert.datas  = messages;
        [alert.tb_titles reloadData];
        
    });
    
    return alert;
}
- (void)alertShowAnimationWithfishi:(UIViewController*)vc block:(FinishBlock)block{
    self.blockFinished = block;
//    UIViewController *vc = [LiveNotificationAlert currentViewController];
    UIView *superView = vc.view;
    self.frame = CGRectMake(0, 0, _window_width, _window_height);
    self.layout_alertCenterY.constant = _window_height;
    [self layoutIfNeeded];
    [self setNeedsLayout];
    [superView addSubview:self];
    self.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.25 animations:^{
        self.layout_alertCenterY.constant = 40;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [self layoutIfNeeded];
    }];
//    [self.tb_titles reloadData];
}


- (IBAction)didClickCloseAlert:(UIButton *)sender {
    //dismiss alert
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        self.layout_alertCenterY.constant = _window_height;
        self.backgroundColor =[UIColor clearColor];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf removeFromSuperview];
        if (strongSelf.blockFinished) {
            strongSelf.blockFinished();
        }
        
    }];
}

+ (UIViewController *)currentViewController
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;;
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)vc;
        if ([tab.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
            return [nav.viewControllers lastObject];
        } else {
            return tab.selectedViewController;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.viewControllers lastObject];
    } else {
        return vc;
    }
    return nil;
}

#pragma mark - UITableView -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LiveNotificationAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveNotificationAlertCell" forIndexPath:indexPath];
    
    NSDictionary *subDic = self.datas[indexPath.row];
    if (indexPath.row ==self.currentSelectedIndex) {
        cell.state = @1;
    }else{
        cell.state = @0;
    }
    cell.lb_title.text  = subDic[@"title"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.currentSelectedIndex = indexPath.row;
    [tableView reloadData];
    
    NSDictionary *subDic = self.datas[indexPath.row];
    NSString *contentHtml = subDic[@"content"];
    if (contentHtml!= nil && contentHtml.length>0) {
//        NSString *contentHtmlWithoutJS = [contentHtml stringByReplacingOccurrencesOfString:@"<script[^>]*>[\\s\\S]*?</script>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, contentHtml.length)];
//        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[contentHtmlWithoutJS dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        NSString *headerString = @"<header><meta name='viewport' content='width=device-width, initial-scale=0.95, maximum-scale=0.95, minimum-scale=0.8, user-scalable=no'></header>";
        [self.text_content loadHTMLString:[headerString stringByAppendingString:contentHtml] baseURL:nil];
       
    }
    
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

@end
