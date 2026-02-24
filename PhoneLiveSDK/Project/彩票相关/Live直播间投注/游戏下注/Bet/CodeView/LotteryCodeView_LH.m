//
//  LotteryCodeView_LH.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryCodeView_LH.h"

@implementation LotteryCodeView_LH

- (void)setResultDict:(NSDictionary *)resultDict {
    NSString *first = [resultDict[@"winWays"] firstObject];
    NSArray *texts = [first componentsSeparatedByString:@"_"];
    self.codeListView.codes = @[texts.lastObject];
}

@end
