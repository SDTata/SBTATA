//
//  MoreAlertView.m
//  phonelive2
//
//  Created by Co co on 2024/2/28.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MoreAlertView.h"
#import <WebKit/WebKit.h>
#import "UIImageView+WebCache.h"
#import <Masonry/Masonry.h>
@interface MoreAlertView()<WKUIDelegate,WKNavigationDelegate>
@property (nonatomic, strong)NSString *type;
@property (nonatomic, strong)NSString *jumpurl;
@property (nonatomic, strong)NSString *jumptype;

@end

@implementation MoreAlertView


- (void)awakeFromNib{
    [super awakeFromNib];
    
    WKWebViewConfiguration *config = self.webView.configuration;
//    config.preferences.minimumFontSize = 10;
    
    //是否支持JavaScript
    config.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
//    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
    config.allowsInlineMediaPlayback = YES;
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
   

    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView setOpaque:NO];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self cancelAction:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)instanceNotificationAlertWithMessages:(NSString *)messages type:(NSString*)type jumpurl:(NSString*)jumpurl jumptype:(NSString*)jumptype
{
    
    MoreAlertView *alert = [[[XBundle currentXibBundleWithResourceName:@"MoreAlertView"] loadNibNamed:@"MoreAlertView" owner:nil options:nil] firstObject];
    alert.type = type;
    alert.jumpurl = jumpurl;
    alert.jumptype = jumptype;
    if (type!=nil && [type isEqualToString:@"2"]) {
        // 创建并配置 imageView
        alert.imageView = [[UIImageView alloc] init];
        alert.imageView.contentMode = UIViewContentModeScaleAspectFit;
        alert.imageView.backgroundColor = [UIColor clearColor];
        alert.imageView.userInteractionEnabled = YES; // 启用用户交互
        [alert addSubview:alert.imageView];
        
        // 为imageView添加点击手势
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:alert action:@selector(imageViewTapped:)];
        [alert.imageView addGestureRecognizer:imageTap];
        
        // 创建关闭按钮（因为需要相对于imageView重新布局）
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[ImageBundle imagewithBundleName:@"guanbi_111"] forState:UIControlStateNormal];
        [closeBtn addTarget:alert action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [alert addSubview:closeBtn];
        
        // 设置imageView的约束
        [alert.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(alert);
            make.centerY.equalTo(alert);
            make.width.equalTo(alert.webView);
            // 高度约束：最大高度不超过webView高度，但会根据图片比例自适应
            make.height.lessThanOrEqualTo(alert.webView);
        }];
        
        // 设置关闭按钮约束
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(alert);
            make.top.equalTo(alert.imageView.mas_bottom).offset(30);
            make.width.height.mas_equalTo(34);
        }];
        
        // 加载图片，并在加载完成后调整高度
        if (messages && messages.length > 0) {
            [alert.imageView sd_setImageWithURL:[NSURL URLWithString:messages] 
                                placeholderImage:nil
                                       completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image && !error) {
                    // 计算图片实际宽高比
                    CGFloat imageRatio = image.size.height / image.size.width;
                    CGFloat maxWidth = alert.webView.frame.size.width;
                    CGFloat maxHeight = alert.webView.frame.size.height;
                    
                    // 根据图片比例更新高度约束
                    CGFloat actualHeight = maxWidth * imageRatio;
                    if (actualHeight > maxHeight) {
                        actualHeight = maxHeight;
                    }
                    
                    [alert.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(actualHeight);
                    }];
                    
                    [alert layoutIfNeeded];
                }
            }];
        }
        
        // 隐藏原来的webView和关闭按钮
        alert.webView.hidden = YES;
        // 隐藏xib中的关闭按钮（需要找到它）
        for (UIView *subview in alert.subviews) {
            if ([subview isKindOfClass:[UIButton class]] && subview != closeBtn) {
                subview.hidden = YES;
            }
        }
    }else{
        if (alert.webView) {
            NSString *headerString = @"<header><meta name='viewport' content='width=device-width, initial-scale=0.95, maximum-scale=0.95, minimum-scale=0.8, user-scalable=no'></header>";
            [alert.webView loadHTMLString:[headerString stringByAppendingString:messages] baseURL:nil];
        }
    }
   
    
    return alert;
}


- (void)alertShowAnimationWithfishi:(FinishBlocks)block
{
    self.blockFinished = block;
    UIViewController *vc = [MoreAlertView currentViewController];
    UIView *superView = vc.view;
    self.frame = CGRectMake(0, _window_height, _window_width, _window_height);
    
    // 图片模式不需要手动设置frame，因为已经通过约束绑定到webView的位置
    self.webView.frame = CGRectMake(15, (_window_height-_window_height*0.5)/2, _window_width-30, _window_height*0.5);
    [self layoutIfNeeded];
    [self setNeedsLayout];
    [superView addSubview:self];
    self.backgroundColor = [UIColor clearColor];
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.frame = CGRectMake(0, 0, _window_width, _window_height);
        // 图片模式不需要手动设置frame，因为已经通过约束绑定到webView的位置
        strongSelf.webView.frame = CGRectMake(15, (_window_height-_window_height*0.5)/2, _window_width-30, _window_height*0.5);
        [strongSelf layoutIfNeeded];
    }];
    
    
}
- (IBAction)cancelAction:(UIButton *)sender {
    
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(0, _window_height, _window_width, _window_height*0.7);
       
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


- (void)imageViewTapped:(UITapGestureRecognizer *)gesture {
    // 点击图片时调用跳转方法
    if (self.jumpurl && self.jumpurl.length > 0) {
        [self clickToJump];
        // 跳转后关闭弹框
        [self cancelAction:nil];
    }
}

-(void)clickToJump{
    NSDictionary *data = @{@"scheme": self.jumpurl?self.jumpurl:@"", @"showType": self.jumptype?self.jumptype:@"0"};
    [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
    
}
@end
