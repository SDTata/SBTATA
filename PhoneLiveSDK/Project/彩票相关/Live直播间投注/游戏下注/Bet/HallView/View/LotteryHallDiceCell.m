//
//  LotteryHallDiceCell.m
//  phonelive2
//
//  Created by vick on 2024/1/16.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryHallDiceCell.h"

@interface LotteryHallDiceCell ()

@property (nonatomic, assign) NSInteger count;

@end

@implementation LotteryHallDiceCell

- (instancetype)initWithKey:(NSString *)key superKey:(NSString *)superKey count:(NSInteger)count {
    self = [super init];
    if (self) {
        self.key = key;
        self.superKey = superKey;
        self.count = count;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [super setupView];
    [self.titleLabel removeFromSuperview];
    
    NSMutableArray *views = [NSMutableArray array];
    for (NSInteger i=0; i<self.count; i++) {
        UIImageView *diceImgView = [UIImageView new];
        [self addSubview:diceImgView];
        [views addObject:diceImgView];
        [diceImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(diceImgView.mas_height);
            make.centerX.mas_equalTo(0);
        }];
    }
    [views addObject:self.valueLabel];
    [views mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:5 leadSpacing:10 tailSpacing:5];
}

- (void)setOptionModel:(LotteryOptionModel *)optionModel {
    [super setOptionModel:optionModel];
    
    for (UIImageView *imgView in self.subviews) {
        if ([imgView isKindOfClass:UIImageView.class]) {
            imgView.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@", optionModel.st]];
        }
    }
}

@end
