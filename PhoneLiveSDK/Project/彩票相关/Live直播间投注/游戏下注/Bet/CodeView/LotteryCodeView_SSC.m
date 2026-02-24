//
//  LotteryCodeView_SSC.m
//  phonelive2
//
//  Created by vick on 2023/12/1.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryCodeView_SSC.h"

@implementation LotteryCodeView_SSC

- (void)setupView {
    [super setupView];
    
    /// 号码样式配置
    self.codeListView.size = CGSizeMake(15, 22);
    self.codeListView.setupStyleBlock = ^(BallView *ballView) {
        ballView.titleLabel.hidden = YES;
        ballView.imageView.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ssc_%@", ballView.titleLabel.text]];
    };
    
    self.textListView.size = CGSizeMake(14, 14);
    self.textListView.setupStyleBlock = ^(BallView *ballView) {
        ballView.titleLabel.textColor = vkColorRGB(243, 193, 145);
        ballView.titleLabel.font = vkFont(12);
        ballView.imageView.image = [ImageBundle imagewithBundleName:@"ssc_text_bg"];
    };
}

/// 重写结果处理
- (NSArray *)setupTexts:(NSArray *)texts {
    NSMutableArray *results = [NSMutableArray array];
    NSInteger sum = [[self.codeListView.codes valueForKeyPath:@"@sum.self"] integerValue];
    [results addObject:[NSString stringWithFormat:@"%ld",sum]];
    
    if (sum < 23) {
        [results addObject:YZMsg(@"lobby_small")];
    } else {
        [results addObject:YZMsg(@"lobby_big")];
    }
    
    if (sum % 2 == 0) {
        [results addObject:YZMsg(@"lobby_double")];
    } else {
        [results addObject:YZMsg(@"lobby_single")];
    }
    
    NSString *first = self.codeListView.codes.firstObject;
    NSString *last = self.codeListView.codes.lastObject;
    if (first.integerValue == last.integerValue) {
        [results addObject:YZMsg(@"OpenHistory_he")];
    } else if (first.integerValue > last.integerValue) {
        [results addObject:YZMsg(@"OpenHistory_Dragon")];
    } else {
        [results addObject:YZMsg(@"OpenHistory_Tiger")];
    }
    
    return results;
}

@end
