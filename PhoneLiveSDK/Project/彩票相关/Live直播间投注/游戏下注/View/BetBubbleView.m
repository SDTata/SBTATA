//
//  BetBubbleView.m
//  phonelive2
//
//  Created by test on 2022/4/28.
//  Copyright © 2022 toby. All rights reserved.
//

#import "BetBubbleView.h"
@interface BetBubbleView()
{
    
}
@property (nonatomic,strong)UIImageView *iv_background;
@property (nonatomic,strong)UILabel *lb_betCount;
@end
@implementation BetBubbleView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initBubble];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super initWithCoder:coder]) {
        [self initBubble];
    }
    return self;
}

- (void)initBubble{
    self.height = 20;
    
    [self addSubview:self.iv_background];
    [self.iv_background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_greaterThanOrEqualTo(20);
        make.height.mas_equalTo(20);
    }];
    
    [self.iv_background addSubview:self.lb_betCount];
    [self.lb_betCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.top.mas_equalTo(1);
    }];
    [self.lb_betCount setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setBetCount:(NSString *)betCount{
    self.betNum = betCount;
    self.lb_betCount.text = betCount;
    
    UIImage *backImage;
    if (self.iv_background.width > 40) {
        backImage = [ImageBundle imagewithBundleName:@"kuang-2"];
        CGSize size = backImage.size;
        //上 / 左 / 下 / 右
        UIEdgeInsets insets = UIEdgeInsetsMake(size.height * 0.5, size.width * 0.5, size.height * 0.5, size.width * 0.5);
        backImage = [backImage resizableImageWithCapInsets:insets];
    }else{
        backImage = [ImageBundle imagewithBundleName:@"kuang-1"];
    };
    self.iv_background.image = backImage;
}

- (UIImageView *)iv_background{
    if (!_iv_background) {
        _iv_background = [UIImageView new];
        _iv_background.image = [ImageBundle imagewithBundleName:@"kuang-1"];
        _iv_background.contentMode = UIViewContentModeScaleToFill;
    }
    return _iv_background;
}

- (UILabel *)lb_betCount{
    if (!_lb_betCount) {
        _lb_betCount = [UILabel new];
        _lb_betCount.font = [UIFont boldSystemFontOfSize:9];
        _lb_betCount.textColor = [UIColor whiteColor];
        _lb_betCount.textAlignment = NSTextAlignmentCenter;
    }
    return _lb_betCount;
}

@end
