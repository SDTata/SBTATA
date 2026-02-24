//
//  BaseNavBarView.m
//  phonelive2
//
//  Created by vick on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "BaseNavBarView.h"

@implementation BaseNavBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UIButton *backButton = [UIView vk_buttonImage:@"person_back_black" selected:nil];
    [backButton vk_addTapAction:self selector:@selector(clickBackAction)];
    [self addSubview:backButton];
    self.backButton = backButton;
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(VK_STATUS_H);
        make.width.height.mas_equalTo(44);
        make.bottom.mas_equalTo(0);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFont(16) color:UIColor.blackColor];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(backButton.mas_centerY);
    }];
    
    UIStackView *actionStackView = [UIStackView new];
    actionStackView.axis = UILayoutConstraintAxisHorizontal;
    actionStackView.alignment = UIStackViewAlignmentFill;
    actionStackView.distribution = UIStackViewDistributionFill;
    actionStackView.spacing = 0;
    [self addSubview:actionStackView];
    self.actionStackView = actionStackView;
    [actionStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.top.bottom.mas_equalTo(backButton);
    }];
}

- (void)clickBackAction {
    [[MXBADelegate sharedAppDelegate] popViewController:YES];
}

@end
