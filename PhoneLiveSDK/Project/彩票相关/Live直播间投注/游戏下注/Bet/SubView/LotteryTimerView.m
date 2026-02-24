//
//  LotteryTimerView.m
//  phonelive2
//
//  Created by vick on 2023/12/12.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryTimerView.h"
#import "UIView+Shake.h"
#import <JKCountDownButton/JKCountDownButton.h>

@interface LotteryTimerView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) JKCountDownButton *timeButton;

@end

@implementation LotteryTimerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    UIImageView *backImgView = [UIImageView new];
    backImgView.layer.cornerRadius = 16;
    backImgView.backgroundColor = vkColorHexA(0x000000, 0.5);
    backImgView.layer.masksToBounds = YES;
    [self addSubview:backImgView];
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(18);
        make.height.mas_equalTo(32);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = RGB(252, 245, 146);
    titleLabel.text = YZMsg(@"game_will_begain");
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [backImgView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-10);
    }];
    
    JKCountDownButton *timeButton = [JKCountDownButton buttonWithType:UIButtonTypeCustom];
    [timeButton setBackgroundImage:[ImageBundle imagewithBundleName:@"game_secondimg"] forState:UIControlStateNormal];
    [timeButton setTitleColor:RGB(182, 66, 16) forState:UIControlStateNormal];
    timeButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [timeButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 7, 0, 7)];
    timeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    timeButton.titleLabel.minimumScaleFactor = 0.5;
    timeButton.userInteractionEnabled = NO;
    [self addSubview:timeButton];
    self.timeButton = timeButton;
    [timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(37);
        make.height.mas_equalTo(40);
    }];
    
    _weakify(self)
    [timeButton countDownChanging:^NSString *(JKCountDownButton *countDownButton,NSUInteger second) {
        _strongifyReturn(self)
        if (second < 5) {
            [countDownButton shakeWithOptions:SCShakeOptionsDirectionRotate | SCShakeOptionsForceInterpolationLinearDown | SCShakeOptionsAtEndComplete force:0.15 duration:0.55 iterationDuration:0.05 completionHandler:nil];
            VKBLOCK(self.timerChangingBlock, self, second);
        }
        return [NSString stringWithFormat:@"%zd", second + 1];
    }];
    
    [timeButton countDownFinished:^NSString *(JKCountDownButton *countDownButton, NSUInteger second) {
        _strongifyReturn(self)
        VKBLOCK(self.timerFinishBlock, self);
        return nil;
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setTime:(NSInteger)time {
    _time = time;
    [self.timeButton startCountDownWithSecond:time];
}

@end
