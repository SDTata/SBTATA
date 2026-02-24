//
//  BonusRulesViewController.m
//  phonelive2
//
//  Created by user on 2024/8/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import "BonusRulesViewController.h"
#import "BonusRulesTableViewCell.h"
#import "PostVideoViewController.h"
#import "WinningRecordChildVC.h"
#import <WebKit/WebKit.h>

@interface BonusRulesViewController ()<JXCategoryViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIViewPropertyAnimator *animator;
@property (nonatomic, strong) UIView *floatingView;

@property (nonatomic, strong) WKWebView *webview;
@end

@implementation BonusRulesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    if (self.htmlCode.length <= 0) {
        self.floatingView.transform = CGAffineTransformMakeTranslation(0, self.floatingView.bounds.size.height);
    }
    
    // 使 WebView 的 ScrollView 接受手势，但不处理
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnFloatingView:)];
        panGesture.delegate = self; // 设置代理
        [self.floatingView addGestureRecognizer:panGesture];

    self.floatingView.userInteractionEnabled = YES;

}
// 让浮动视图和 WebView 的手势同时识别
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 判断是否是 WebView 的滚动手势和浮动视图的手势
    if ([self.floatingView.gestureRecognizers containsObject:gestureRecognizer]  && otherGestureRecognizer == self.webview.scrollView.panGestureRecognizer) {
        if (self.webview.scrollView.contentOffset.y>1) {
            return NO;
        }
        return YES;
    }
    return NO;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.htmlCode.length <= 0) {
          [self showAnimation];
      }
}

- (void)showAnimation {
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.floatingView.transform = CGAffineTransformIdentity;
    } completion:^(UIViewAnimatingPosition finalPosition) {
    }];
}

#pragma mark - UI

- (void)setupViews {
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView:)];
    closeTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:closeTap];

    [self.view addSubview:self.floatingView];
    [self.floatingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(80);
        make.left.right.bottom.equalTo(self.view);
    }];

    UIView *containerView = [UIView new];
    containerView.backgroundColor = vkColorRGB(242, 243, 247);
    [self.floatingView addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.floatingView);
    }];
    
    UIImageView *luckydraw_header_bg = [UIImageView new];
    luckydraw_header_bg.image = [ImageBundle imagewithBundleName:@"BonusRules_header_bg"];
    [containerView addSubview:luckydraw_header_bg];
    [luckydraw_header_bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(containerView);
        make.height.equalTo(luckydraw_header_bg.mas_width).multipliedBy(68.0/375.0);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = self.page==1?YZMsg(@"luckyDraw_bonus_rules"):self.page==2?YZMsg(@"public_rule"):YZMsg(@"luckyDraw_winning_record");

    [containerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(containerView).offset(17);
        make.left.right.equalTo(containerView);
        make.height.mas_equalTo(16);
    }];

    UIButton *closeButton = [UIButton new];
    [closeButton addTarget:self action:@selector(closeAnimation) forControlEvents:UIControlEventTouchUpInside];
    closeButton.imageEdgeInsets = UIEdgeInsetsMake(13, 13, 13, 13);
    [closeButton setImage:[ImageBundle imagewithBundleName:@"demo_icon_close"] forState:UIControlStateNormal];
    [containerView addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(containerView).inset(2);
        make.size.equalTo(@44);
    }];
    
    
    if (self.htmlCode.length > 0 &&(self.page == 1 ||self.page == 2)) {
        NSString *htmlContent = [NSString stringWithFormat:@"<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0'></head><body>%@</body></html>", self.htmlCode];
        [self.webview loadHTMLString:htmlContent baseURL:nil];
        [containerView addSubview:self.webview];
        [self.webview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(containerView);
            make.top.mas_equalTo(titleLabel.mas_bottom).offset(24);
        }];
    }else{
        if (self.page == 3) {
            UIView *categoryViewBGView = [UIView new];
            categoryViewBGView.backgroundColor = UIColor.whiteColor;
            categoryViewBGView.layer.cornerRadius = 23;
            categoryViewBGView.layer.shadowColor = vkColorRGB(130, 147, 145).CGColor;
            categoryViewBGView.layer.shadowOpacity = 0.2;
            categoryViewBGView.layer.shadowOffset = CGSizeMake(0.0, 2);
            [containerView addSubview:categoryViewBGView];
            [categoryViewBGView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(luckydraw_header_bg.mas_bottom).offset(-10);
                make.leading.trailing.mas_equalTo(self.view).inset(15);
                make.height.mas_equalTo(46);
            }];
            
            self.categoryView.titles = @[YZMsg(@"bounsRules_category_title1"),
                                         YZMsg(@"bounsRules_category_title2")];
            self.categoryView.titleSelectedColor = [UIColor whiteColor];
            self.categoryView.titleColor = vkColorRGBA(0, 0, 0, 0.7);
            self.categoryView.titleFont = vkFontMedium(14);
            self.categoryView.averageCellSpacingEnabled = YES;
            self.categoryView.titleColorGradientEnabled = YES;
            // BackgroundView 样式的指示器，设置圆角
            JXCategoryIndicatorBackgroundView *backgroundView = [[JXCategoryIndicatorBackgroundView alloc] init];
            backgroundView.indicatorHeight = 26;
            backgroundView.indicatorWidthIncrement = 80;
            backgroundView.indicatorCornerRadius = 13;
            backgroundView.indicatorColor = vkColorRGB(169, 74, 255);
            self.categoryView.indicators = @[backgroundView];
            [categoryViewBGView addSubview:self.categoryView];
            [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(0);
                make.leading.trailing.mas_equalTo(categoryViewBGView).inset(-20);
                make.height.mas_equalTo(26);
            }];
            
            [containerView addSubview:self.listContainerView];
            [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.mas_equalTo(categoryViewBGView);
                make.top.mas_equalTo(categoryViewBGView.mas_bottom).offset(10);
                make.bottom.mas_equalTo(0);
            }];
        }
    }

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
    WinningRecordChildVC* vc = [WinningRecordChildVC new];
    vc.recordType = (int)index;
    return vc;
}


#pragma mark - Floating
- (void)panOnFloatingView:(UIPanGestureRecognizer *)recognizer {
   
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
          
            self.animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.3 curve:UIViewAnimationCurveEaseOut animations:^{
                CGFloat translationY = self.floatingView.bounds.size.height;
                self.floatingView.transform = CGAffineTransformMakeTranslation(0, translationY);
                self.view.backgroundColor = [UIColor clearColor];
            }];
         
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [recognizer translationInView:self.floatingView];
            CGFloat fractionComplete = translation.y / self.floatingView.bounds.size.height;
            self.animator.fractionComplete = fractionComplete;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (self.animator.fractionComplete <= 0.22) {
                self.animator.reversed = YES;
            } else {
                __weak typeof(self) weakSelf = self;
                [self.animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                    [weakSelf dismissViewControllerAnimated:NO completion:nil];
                }];
            }
            [self.animator continueAnimationWithTimingParameters:nil durationFactor:0];
            break;
        }
        default:
            break;
    }
}

- (void)closeAnimation {
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2
                                                          delay:0
                                                        options:UIViewAnimationOptionCurveEaseOut
                                                     animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        CGFloat transformY = self.floatingView.bounds.size.height;
        self.floatingView.transform = CGAffineTransformMakeTranslation(0, transformY);
    } completion:^(UIViewAnimatingPosition finalPosition) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)closeView:(UIGestureRecognizer *)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self.view];
    UIView *touchView = [self.view hitTest:touchPoint withEvent:nil];

    if (touchView != self.view) {
        return;
    }

    [self closeAnimation];
}

#pragma mark - Lazy
- (UIView *)floatingView {
    if (!_floatingView) {
        _floatingView = [UIView new];
        _floatingView.backgroundColor = [UIColor whiteColor];
        _floatingView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        _floatingView.layer.cornerRadius = 25;
        _floatingView.layer.masksToBounds = YES;
    }
    return _floatingView;
}


- (WKWebView *)webview {
    if (!_webview) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        _webview = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webview.opaque = NO;
        _webview.backgroundColor = [UIColor clearColor];
        _webview.scrollView.scrollEnabled = YES;
        _webview.scrollView.bounces = NO;
       
    }
    return _webview;
}
@end
