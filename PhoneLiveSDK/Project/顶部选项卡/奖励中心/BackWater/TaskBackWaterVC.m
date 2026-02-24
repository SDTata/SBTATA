//
//  TaskBackWaterVC.m
//  phonelive2
//
//  Created by vick on 2024/8/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import "TaskBackWaterVC.h"
#import "TaskBackWaterModel.h"
#import <WebKit/WebKit.h>

@interface TaskBackWaterVC () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *textBackView;
@property (nonatomic, strong) UIStackView *leftStackView;
@property (nonatomic, strong) UIStackView *rightStackView;
@property (nonatomic, strong) UIView *lineMaskView;

@end

@implementation TaskBackWaterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self loadListData];
}

- (void)setupView {
    self.view.backgroundColor = vkColorHex(0xf2f2f6);
    self.view.frame = CGRectMake(0, 0, VK_SCREEN_W, 600+VK_BOTTOM_H);
    self.view.layer.cornerRadius = 20;
    self.view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    
    UIImageView *backImgView = [UIImageView new];
    backImgView.image = [ImageBundle imagewithBundleName:@"task_alert_top"];
    [self.view addSubview:backImgView];
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(68);
    }];
    
    UILabel *titleLabel = [UIView vk_label:YZMsg(@"task_reward_backwater") font:vkFontBold(16) color:UIColor.whiteColor];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(16);
    }];
    
    UIButton *closeButton = [UIView vk_buttonImage:@"demo_icon_close" selected:nil];
    [closeButton vk_addTapAction:self selector:@selector(hideAlert)];
    closeButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    [self.view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(44);
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
        make.right.mas_equalTo(0);
    }];
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(60);
        make.bottom.mas_equalTo(0);
    }];
    
    UIView *contentView = [UIView new];
    [scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(scrollView);
        make.width.mas_equalTo(scrollView);
    }];
    
    [contentView addSubview:self.textBackView];
    [self.textBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(10);
    }];
    
    UIView *listBackView = [UIView new];
    [listBackView vk_border:vkColorHex(0xb4bdc5) cornerRadius:8];
    listBackView.backgroundColor = UIColor.whiteColor;
    [contentView addSubview:listBackView];
    [listBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.textBackView.mas_bottom).offset(20);
        make.bottom.mas_equalTo(-20);
    }];
    
    UIStackView *leftStackView = [UIStackView new];
    leftStackView.axis = UILayoutConstraintAxisVertical;
    leftStackView.distribution = UIStackViewDistributionFillProportionally;
    [listBackView addSubview:leftStackView];
    self.leftStackView = leftStackView;
    [leftStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(80);
    }];
    
    UIScrollView *bottomScrollView = [UIScrollView new];
    bottomScrollView.showsHorizontalScrollIndicator = NO;
    bottomScrollView.showsVerticalScrollIndicator = NO;
    bottomScrollView.bounces = NO;
    [listBackView addSubview:bottomScrollView];
    [bottomScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftStackView.mas_right);
        make.top.bottom.right.mas_equalTo(0);
    }];
    
    UIStackView *rightStackView = [UIStackView new];
    rightStackView.axis = UILayoutConstraintAxisVertical;
    rightStackView.distribution = UIStackViewDistributionFillProportionally;
    [bottomScrollView addSubview:rightStackView];
    self.rightStackView = rightStackView;
    [rightStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(bottomScrollView);
    }];
    
    UIView *lineMaskView = [UIView new];
    lineMaskView.userInteractionEnabled = NO;
    lineMaskView.backgroundColor = vkColorHexA(0x000000, 0.1);
    [contentView addSubview:lineMaskView];
    self.lineMaskView = lineMaskView;
    
    UIImageView *arrowImgView = [UIImageView new];
    arrowImgView.image = [ImageBundle imagewithBundleName:@"task_center_arrow"];
    [lineMaskView addSubview:arrowImgView];
    [arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(-6);
        make.size.mas_equalTo(12);
    }];
}

- (void)loadListData {
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getRebateRulesBlock:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD hideHUD];
        NSString *desc = networkData.data[@"rebate_rule_desc"];
        NSString *htmlContent = [NSString stringWithFormat:@"<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0'></head><body>%@</body></html>", desc];
        [self.textBackView loadHTMLString:htmlContent baseURL:nil];
        [strongSelf handleNetworkData:networkData];
    }];
}

- (NSString *)displayKingNameFrom:(NSString *)kingName {
    // 1. 把換行移除，避免 "\n-\n"
    NSString *clean = [kingName stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    // 2. 若格式是 "王者V0-王者V0"，只取前半段
    NSArray *parts = [clean componentsSeparatedByString:@"-"];
    if (parts.count == 2 && [parts[0] isEqualToString:parts[1]]) {
        return parts[0];   // 只顯示「王者V0」
    }

    return kingName; // 其他情況保持原樣
}


- (void)handleNetworkData:(NetworkData *)networkData {
    NSArray <TaskBackWaterModel *> *array = [TaskBackWaterModel arrayFromJson:networkData.data[@"rebate_rules"]];
    
    /// 左上角返水比例
    UILabel *titleTopLabel = [self createTitleLabel:YZMsg(@"task_reward_backwater_rate") isTop:YES lineHieght:1];
    [self.leftStackView addArrangedSubview:titleTopLabel];
    
    /// 右侧顶部标题
    NSMutableArray *topValues = @[YZMsg(@"task_reward_backwater_amount"), YZMsg(@"task_reward_backwater_limit")].mutableCopy;
    NSArray *rawNames = [array.firstObject.rates valueForKeyPath:@"king_name"];
    NSMutableArray *displayNames = [NSMutableArray array];

    for (NSString *name in rawNames) {
        [displayNames addObject:[self displayKingNameFrom:name]];
    }

    [topValues addObjectsFromArray:displayNames];

    UIStackView *valueTopView = [self createValueLabel:topValues isTop:YES lineHieght:1];
    [self.rightStackView addArrangedSubview:valueTopView];
    
    NSMutableArray<NSNumber *> *lineHeights = [NSMutableArray array];

    // 先找出每组最后一笔的位置
    for (NSInteger i = 0; i < array.count; i++) {
        TaskBackWaterModel *currentModel = array[i];
        TaskBackWaterModel *nextModel = (i + 1 < array.count) ? array[i + 1] : nil;
        
        if (!nextModel || ![currentModel.game isEqualToString:nextModel.game]) {
            // 当前 game 与下一个不同，或已经是最后一笔，这笔要用 lineHieght = 2
            [lineHeights addObject:@2];
        } else {
            [lineHeights addObject:@1];
        }
    }

    for (NSInteger i = 0; i < array.count; i++) {
        TaskBackWaterModel *model = array[i];
        CGFloat lineHeight = [lineHeights[i] floatValue];
        
        /// 左侧列表内容
        UILabel *label = [self createTitleLabel:model.game isTop:NO lineHieght:lineHeight];
        [self.leftStackView addArrangedSubview:label];
        
        /// 右侧列表内容
        NSMutableArray *values = @[model.money, model.max_rebate].mutableCopy;
        [values addObjectsFromArray:[model.rates valueForKeyPath:@"rebate_rate"]];
        UIStackView *view = [self createValueLabel:values isTop:NO lineHieght:lineHeight];
        [self.rightStackView addArrangedSubview:view];
    }
    
    /// 找出当前等级索引
    NSInteger level = [Config myProfile].king_level.integerValue;
    NSInteger index = [array.firstObject.rates indexOfObjectPassingTest:^BOOL(TaskBackWaterRateModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return level >= obj.min_level && level <= obj.max_level;
    }];
    index = index + 2;
    if (index >= valueTopView.arrangedSubviews.count) {
        self.lineMaskView.hidden = YES;
        return;
    }
    UIView *view = valueTopView.arrangedSubviews[index];
    self.lineMaskView.hidden = NO;
    [self.lineMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(view);
        make.top.mas_equalTo(self.rightStackView.mas_top);
        make.bottom.mas_equalTo(self.rightStackView.mas_bottom);
    }];
}

- (UILabel *)createTitleLabel:(NSString *)title isTop:(BOOL)isTop lineHieght:(int)lineHieght {
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = vkFontMedium(12);
    label.textColor = UIColor.whiteColor;
    label.text = title;
    label.backgroundColor = vkColorHex(0x7e72ff);
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(isTop ? 65 : 32);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = vkColorHex(0xd2d7e6);
    [label addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(lineHieght);
        make.bottom.mas_equalTo(0);
    }];
    return label;
}

- (UIStackView *)createValueLabel:(NSArray *)values isTop:(BOOL)isTop lineHieght:(int)lineHieght  {
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillProportionally;
    for (int i=0; i<values.count; i++) {
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.font = vkFontMedium(12);
        [stackView addArrangedSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(isTop ? 65 : 32);
            make.width.mas_equalTo(80);
        }];
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = vkColorHex(0xd2d7e6);
        [label addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(lineHieght);
            make.bottom.mas_equalTo(0);
        }];
        
        UIView *lineView2 = [UIView new];
        lineView2.backgroundColor = vkColorHex(0xd2d7e6);
        [label addSubview:lineView2];
        [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(1.0);
            make.right.mas_equalTo(0);
        }];
        
        NSString *value = values[i];
        if (isTop) {
            label.textColor = UIColor.whiteColor;
            label.backgroundColor = vkColorHex(0xa9afff);
            label.text = value;
        } else {
            label.textColor = UIColor.blackColor;
            label.backgroundColor = UIColor.clearColor;
            if (i == 0) {
                /// 消费金额
                label.text = [NSString stringWithFormat:@"%@+", [NSString toAmount:value].toRate.toUnit];
            } else if (i == 1) {
                /// 返点上限
                label.text = [NSString toAmount:value].toRate.toUnit;
            } else {
                label.text = [NSString stringWithFormat:@"%@%%", [NSDecimalNumber decimalNumberWithString:value].stringValue];
            }
        }
    }
    return stackView;
}

#pragma mark - Lazy
/*
- (UIView *)textBackView {
    if (!_textBackView) {
        _textBackView = [UIView new];
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = vkColorHex(0xd6a9ff);
        [lineView vk_border:nil cornerRadius:4];
        [_textBackView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.width.mas_equalTo(5);
            make.height.mas_equalTo(14);
            make.top.mas_equalTo(10);
        }];
        
        UILabel *titleLabel = [UIView vk_label:YZMsg(@"task_reward_backwater_about") font:vkFontMedium(16) color:UIColor.blackColor];
        [_textBackView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(lineView.mas_right).offset(5);
            make.centerY.mas_equalTo(lineView.mas_centerY);
        }];
        
        UILabel *messageLabel = [UIView vk_label:nil font:vkFont(12) color:UIColor.blackColor];
        messageLabel.numberOfLines = 0;
        [_textBackView addSubview:messageLabel];
        [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.top.mas_equalTo(titleLabel.mas_bottom).offset(8);
            make.bottom.mas_equalTo(-8);
        }];
        
        NSMutableAttributedString *string = [NSMutableAttributedString new];
        [string vk_appendString:YZMsg(@"task_reward_backwater_tip1") color:UIColor.blackColor font:vkFont(12)];
        [string vk_appendString:YZMsg(@"task_reward_backwater_tip2") color:vkColorHex(0xc87dfa) font:vkFontMedium(16)];
        [string vk_appendString:YZMsg(@"task_reward_backwater_tip3") color:UIColor.blackColor font:vkFont(12)];
        [string vk_appendString:YZMsg(@"task_reward_backwater_tip4") color:vkColorHex(0xc87dfa) font:vkFontMedium(16)];
        [string vk_appendString:YZMsg(@"task_reward_backwater_tip5") color:UIColor.blackColor font:vkFont(12)];
        [string vk_appendString:YZMsg(@"task_reward_backwater_tip6") color:vkColorHex(0xc87dfa) font:vkFontMedium(16)];
        [string vk_appendString:YZMsg(@"task_reward_backwater_tip7") color:UIColor.blackColor font:vkFont(12)];
        [string vk_appendString:YZMsg(@"task_reward_backwater_tip8") color:vkColorHex(0xc87dfa) font:vkFontMedium(16)];
        [string vk_appendString:YZMsg(@"task_reward_backwater_tip9") color:UIColor.blackColor font:vkFont(12)];
        [string vk_setLineSpacing:5 alignment:NSTextAlignmentLeft];
        messageLabel.attributedText = string;
    }
    return _textBackView;
}
 */
- (WKWebView *)textBackView {
    if (!_textBackView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        _textBackView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _textBackView.opaque = NO;
        _textBackView.backgroundColor = [UIColor clearColor];
        _textBackView.scrollView.scrollEnabled = NO;
        _textBackView.scrollView.bounces = NO;
        _textBackView.navigationDelegate = self;
    }
    return _textBackView;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (!error) {
            CGFloat height = [result floatValue];
            [self.textBackView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
            }];
        }
    }];
}

@end
