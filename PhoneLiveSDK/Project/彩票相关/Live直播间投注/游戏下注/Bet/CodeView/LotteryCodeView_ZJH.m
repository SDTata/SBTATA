//
//  LotteryCodeView_ZJH.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryCodeView_ZJH.h"

@implementation LotteryCodeView_ZJH

- (void)setupView {
    [super setupView];
    
    /// 号码样式配置
    self.codeListView.size = CGSizeMake(26, 26);
    self.codeListView.setupStyleBlock = ^(BallView *ballView) {
        ballView.titleLabel.hidden = YES;
        ballView.imageView.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"zjh_player_%ld", ballView.titleLabel.text.integerValue+1]];
    };
}

- (void)setResultModel:(LotteryResultModel *)resultModel {
    self.codeListView.codes = @[@(resultModel.who_win)];
}

- (void)setResultDict:(NSDictionary *)resultDict {
    self.codeListView.codes = @[resultDict[@"zjh"][@"whoWin"]];
}

@end
