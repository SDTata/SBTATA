//
//  LotteryCodeView_ZP.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryCodeView_ZP.h"

NSString * const kZPRedBalls = @"[32],[4],[21],[25],[34],[27],[36],[30],[23],[5],[16],[1],[14],[9],[18],[7],[12],[3]";

@implementation LotteryCodeView_ZP

- (void)setupView {
    [super setupView];
    
    /// 号码样式配置
    self.codeListView.size = CGSizeMake(20, 20);
    self.codeListView.setupStyleBlock = ^(BallView *ballView) {
        NSString *ball = ballView.titleLabel.text;
        NSString *key = [NSString stringWithFormat:@"[%@]", ball];
        if ([ball isEqualToString:@"0"]) {
            ballView.imageView.image = [ImageBundle imagewithBundleName:@"zp_green"];
        } else if ([kZPRedBalls containsString:key]) {
            ballView.imageView.image = [ImageBundle imagewithBundleName:@"zp_red"];
        } else {
            ballView.imageView.image = [ImageBundle imagewithBundleName:@"zp_black"];
        }
    };
}

@end
