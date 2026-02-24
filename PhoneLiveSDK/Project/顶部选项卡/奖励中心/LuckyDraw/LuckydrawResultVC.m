//
//  LuckydrawResultVC.m
//  phonelive2
//
//  Created by user on 2024/9/1.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LuckydrawResultVC.h"

@interface LuckydrawResultVC ()
@property (nonatomic, strong) MASConstraint *constantY;
@property (nonatomic, strong) UILabel *numLabel;
@end

@implementation LuckydrawResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}
- (void)setupViews {
    UIView *centerView = [UIView new];
    centerView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:centerView];
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.view).multipliedBy(0.6);
        make.width.centerX.mas_equalTo(self.view);
        self.constantY = make.centerY.mas_equalTo(self.view);
    }];
    
    UIImageView *bgImgView = [UIImageView new];
    bgImgView.contentMode = UIViewContentModeScaleAspectFit;
    [centerView addSubview:bgImgView];
    [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(centerView).inset(@RatioBaseWidth375(15).floatValue);
        make.centerX.mas_equalTo(centerView);
        make.centerY.mas_equalTo(centerView).multipliedBy(0.9);
        make.height.mas_equalTo(@RatioBaseWidth375(345));
    }];
    UIImage *imgBg = [ImageBundle imagewithBundleName:YZMsg(@"Luckydraw_result_bg")];
    bgImgView.image = imgBg;
    
    UIImageView *coinImageView = [UIImageView new];
    [bgImgView addSubview:coinImageView];
    float centerX = [self.model.item_type isEqualToString:@"money"] ? 0.6 : 0.65;
    float centerY = [self.model.item_type isEqualToString:@"money"] ? 1.37 : 1.35;
    [coinImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(@RatioBaseWidth375(56));
        make.centerX.mas_equalTo(bgImgView).multipliedBy(centerX);
        make.centerY.mas_equalTo(bgImgView).multipliedBy(centerY);
    }];
    
    NSString *iconName = [NSString stringWithFormat:@"Luckydraw_%@%@",self.model.item_type, [self.model.item_name containsString:@"自行车"] ? @"2" : @""];
    UIImage *coinImg = [ImageBundle imagewithBundleName:iconName];
    coinImageView.image = coinImg;
    
    UILabel *titleLabel = [UIView vk_label:YZMsg(@"task_reward_alert_tip") font:vkFontBold(30) color:UIColor.whiteColor];
    titleLabel.numberOfLines = 1;
    titleLabel.minimumScaleFactor = 0.5;
    titleLabel.adjustsFontSizeToFitWidth = true;
    [bgImgView addSubview: titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(bgImgView).multipliedBy(0.55);
        make.left.mas_equalTo(bgImgView).offset(@RatioBaseWidth375(72).floatValue);
        make.right.mas_equalTo(bgImgView).inset(@RatioBaseWidth375(144).floatValue);
        make.height.mas_equalTo(@RatioBaseWidth375(36).floatValue);
    }];
    
    UILabel *subTitleLabel = [UIView vk_label:self.model.item_name font:vkFontBold(30) color:UIColor.whiteColor];
    subTitleLabel.numberOfLines = 1;
    subTitleLabel.minimumScaleFactor = 0.5;
    subTitleLabel.adjustsFontSizeToFitWidth = true;
    [bgImgView addSubview: subTitleLabel];
    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom);
        make.left.mas_equalTo(bgImgView).offset(@RatioBaseWidth375(72).floatValue);
        make.right.mas_equalTo(bgImgView).inset(@RatioBaseWidth375(144).floatValue);
        make.height.mas_equalTo(@RatioBaseWidth375(36).floatValue);
    }];
    
    UILabel *bottomTitleLabel = [UIView vk_label:YZMsg(@"luckyDraw_result_tips") font:vkFontMedium(12) color:UIColor.whiteColor];
    bottomTitleLabel.textAlignment = NSTextAlignmentCenter;
    [bgImgView addSubview: bottomTitleLabel];
    [bottomTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(coinImageView.mas_bottom).offset(18);
        make.left.right.mas_equalTo(bgImgView).inset(80);
        make.height.mas_equalTo(@RatioBaseWidth375(15).floatValue);
    }];
    
    float fontSize = [self.model.item_type isEqualToString:@"money"] ? 30 : 15;
    UILabel *numLabel = [UIView vk_label:@"" font:vkFontBold(fontSize) color:UIColor.whiteColor];
    numLabel.textAlignment = NSTextAlignmentRight;
    [bgImgView addSubview: numLabel];
    self.numLabel = numLabel;
    [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(coinImageView).offset(-2);
        make.right.mas_equalTo(bgImgView).inset(90);
        make.height.mas_equalTo(@RatioBaseWidth375(62).floatValue);
    }];
    
    self.constantY.mas_equalTo(SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.703636/2);
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
    self.view.backgroundColor = [UIColor clearColor];
    NSString *coin = minstr(self.model.item_num);
    NSString *removeCommaCoin = [coin stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *currencyCoin = [YBToolClass getRateCurrency:removeCommaCoin showUnit:NO showComma:YES];
    //NSString *day = [NSString stringWithFormat:@"%@%@", coin, YZMsg(@"BillVC_Days")];
    NSString *itemName = self.model.item_name;
    if ([self.model.item_type isEqualToString:@"nothing"]) {
        [coinImageView sd_setImageWithURL:[NSURL URLWithString:self.model.item_icon] placeholderImage:coinImg];
        self.numLabel.text = itemName;
    } else if ([self.model.item_type isEqualToString:@"money"]) {
        self.numLabel.text = [NSString stringWithFormat:@"%@", currencyCoin];
    } else {
        self.numLabel.text = itemName;
    }

    UIButton *cancelBtn = [UIButton new];
    [cancelBtn setImage:[ImageBundle imagewithBundleName:YZMsg(@"Luckydraw_cancel_button")] forState:UIControlStateNormal];
    [cancelBtn setImage:[ImageBundle imagewithBundleName:YZMsg(@"Luckydraw_cancel_button")] forState:UIControlStateHighlighted];
    [cancelBtn vk_addTapAction:self selector:@selector(cancelAction:)];
    [centerView addSubview:cancelBtn];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(24);
        make.centerX.mas_equalTo(bgImgView);
        make.top.mas_equalTo(bgImgView.mas_bottom);
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.constantY.mas_equalTo(SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.703636/2);
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.constantY.mas_equalTo(0);
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self cancelDismiss];
}

-(void)cancelDismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.constantY.mas_equalTo(SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.703636/2);
        self.view.backgroundColor = [UIColor clearColor];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)cancelAction:(UIButton *)sender {
    [self cancelDismiss];
}

@end
