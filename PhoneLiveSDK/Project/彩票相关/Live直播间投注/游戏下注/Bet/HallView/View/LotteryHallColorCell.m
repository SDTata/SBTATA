//
//  LotteryHallColorCell.m
//  phonelive2
//
//  Created by vick on 2024/1/23.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryHallColorCell.h"

@interface LotteryHallColorCell ()

@property (nonatomic, assign) NSInteger type;

@end

@implementation LotteryHallColorCell

- (instancetype)initWithKey:(NSString *)key superKey:(NSString *)superKey type:(NSInteger)type {
    self = [super init];
    if (self) {
        self.key = key;
        self.superKey = superKey;
        self.type = type;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [super setupView];
    
    UIImage *normalImage = [ImageBundle imagewithBundleName:@"bjl_betbg"];
    if (self.type == 1) {
        normalImage = [ImageBundle imagewithBundleName:@"lp_red_bg"];
    } else if (self.type == 2) {
        normalImage = [ImageBundle imagewithBundleName:@"lp_black_bg"];
    } else if (self.type == 3) {
        normalImage = [ImageBundle imagewithBundleName:@"lp_green_bg"];
    }
    [self.backImgView setBackgroundImage:normalImage forState:UIControlStateNormal];
}

@end
