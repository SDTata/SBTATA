//
//  LotteryChipSubView.m
//  phonelive2
//
//  Created by vick on 2023/12/9.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryChipSubView.h"

@interface LotteryChipSubView ()

@property (nonatomic, strong) UILabel *chipLabel;

@end

@implementation LotteryChipSubView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UILabel *chipLabel = [UILabel new];
    chipLabel.textAlignment = NSTextAlignmentCenter;
    chipLabel.adjustsFontSizeToFitWidth = YES;
    chipLabel.minimumScaleFactor = 0.5;
    chipLabel.font = [UIFont boldSystemFontOfSize:10];
    chipLabel.textColor = [UIColor blackColor];
    [self addSubview:chipLabel];
    self.chipLabel = chipLabel;
    [chipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(2);
        make.right.mas_equalTo(-2);
        make.top.mas_equalTo(2);
        make.bottom.mas_equalTo(-2);
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(18);
    }];
}

- (void)setMoney:(NSString *)money {
    _money = money;
    [self updateData];
}

- (void)updateData {
    self.chipLabel.text = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%ld", self.money.integerValue] showUnit:NO];
    switch (self.money.integerValue) {
        case 2:
            self.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",1]];
            break;
        case 10:
            self.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",2]];
            break;
        case 100:
            self.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",3]];
            break;
        case 200:
            self.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",4]];
            break;
        case 500:
            self.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",5]];
            break;
        case 1000:
            self.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",6]];
            break;
        default:
            self.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",7]];
            break;
    }
    if (self.isEdit) {
        self.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",7]];
    }
}

@end
