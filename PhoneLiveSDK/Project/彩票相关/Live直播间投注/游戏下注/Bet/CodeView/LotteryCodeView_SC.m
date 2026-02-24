//
//  LotteryCodeView_SC.m
//  phonelive2
//
//  Created by vick on 2023/12/1.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryCodeView_SC.h"

@implementation LotteryCodeView_SC

- (void)setupView {
    [super setupView];
    
    /// 号码样式配置
    self.codeListView.setupStyleBlock = ^(BallView *ballView) {
        ballView.titleLabel.hidden = YES;
        ballView.imageView.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"14-%@", ballView.titleLabel.text]];
    };
}

/// 重写结果处理
- (NSArray *)setupTexts:(NSArray *)texts {
    NSMutableArray *results = [NSMutableArray array];
    NSString *num = self.codeListView.codes.firstObject;
    [results addObject:num];
    [results addObject:num.integerValue > 5 ? YZMsg(@"lobby_big") : YZMsg(@"lobby_small")];
    [results addObject:num.integerValue % 2 == 0 ? YZMsg(@"lobby_double") : YZMsg(@"lobby_single")];
    return results;
}

@end
