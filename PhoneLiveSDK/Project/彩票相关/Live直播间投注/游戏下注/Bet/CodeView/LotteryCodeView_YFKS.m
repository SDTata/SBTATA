//
//  LotteryCodeView_YFKS.m
//  phonelive2
//
//  Created by vick on 2023/12/7.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryCodeView_YFKS.h"

@implementation LotteryCodeView_YFKS

- (void)setupView {
    [super setupView];
    
    /// 号码样式配置
    self.codeListView.size = CGSizeMake(20, 20);
    self.codeListView.setupStyleBlock = ^(BallView *ballView) {
        ballView.titleLabel.hidden = YES;
        ballView.imageView.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@", ballView.titleLabel.text]];
    };
}

/// 重写结果处理
- (NSArray *)setupTexts:(NSArray *)texts {
    NSMutableArray *results = [NSMutableArray array];
    NSInteger sum = [[self.codeListView.codes valueForKeyPath:@"@sum.self"] integerValue];
    [results addObject:[NSString stringWithFormat:@"%ld",sum]];
    
    if (sum <= 10) {
        [results addObject:YZMsg(@"lobby_small")];
    } else {
        [results addObject:YZMsg(@"lobby_big")];
    }
    
    if (sum % 2 == 0) {
        [results addObject:YZMsg(@"lobby_double")];
    } else {
        [results addObject:YZMsg(@"lobby_single")];
    }
    
    return results;
}

@end
