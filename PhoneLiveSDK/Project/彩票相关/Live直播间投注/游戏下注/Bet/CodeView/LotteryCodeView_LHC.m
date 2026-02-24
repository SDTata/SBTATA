//
//  LotteryCodeView_LHC.m
//  phonelive2
//
//  Created by vick on 2023/12/1.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryCodeView_LHC.h"

NSString * const kLHCRedBalls = @"[1],[2],[7],[8],[12],[13],[18],[19],[23],[24],[29],[30],[34],[35],[40],[45],[46]";
NSString * const kLHCBlueBalls = @"[3],[4],[9],[10],[14],[15],[20],[25],[26],[31],[36],[37],[41],[42],[47],[48]";
NSString * const kLHCGreenBalls = @"[5],[6],[11],[16],[17],[21],[22],[27],[28],[32],[33],[38],[39],[43],[44],[49]";

@implementation LotteryCodeView_LHC

- (void)setupView {
    [super setupView];
    
    /// 号码样式配置
    self.codeListView.size = CGSizeMake(16, 16);
    self.codeListView.setupStyleBlock = ^(BallView *ballView) {
        ballView.titleLabel.textColor = UIColor.blackColor;
        ballView.titleLabel.font = vkFontMedium(10);
        
        NSString *key = [NSString stringWithFormat:@"[%@]", ballView.titleLabel.text];
        if ([key containsString:@" "]) {
            ballView.imageView.image = [ImageBundle imagewithBundleName:@"lhc_add"];
        } else if ([kLHCBlueBalls containsString:key]) {
            ballView.imageView.image = [ImageBundle imagewithBundleName:@"lhc_blue"];
        } else if ([kLHCGreenBalls containsString:key]) {
            ballView.imageView.image = [ImageBundle imagewithBundleName:@"lhc_green"];
        } else {
            ballView.imageView.image = [ImageBundle imagewithBundleName:@"lhc_red"];
        }
    };
}

/// 重写号码处理
- (NSArray *)setupCodes:(NSArray *)codes {
    NSMutableArray *results = [NSMutableArray arrayWithArray:codes];
    if (results.count > 6) {
        [results insertObject:@" " atIndex:6];
    }
    return results;
}

/// 重写结果处理
- (NSArray *)setupTexts:(NSArray *)texts {
    NSMutableArray *results = [NSMutableArray array];
    NSInteger sum = [self.codeListView.codes.lastObject integerValue];
    [results addObject:[NSString stringWithFormat:@"%ld",sum]];
    
    if (sum <= 24) {
        [results addObject:YZMsg(@"lobby_small")];
    } else {
        [results addObject:YZMsg(@"lobby_big")];
    }
    
    if (sum % 2 == 0) {
        [results addObject:YZMsg(@"lobby_double")];
    } else {
        [results addObject:YZMsg(@"lobby_single")];
    }
    
    NSString *key = [NSString stringWithFormat:@"[%ld]", sum];
    if ([kLHCBlueBalls containsString:key]) {
        [results addObject:YZMsg(@"OpenAward_NiuNiu_Blue")];
    } else if ([kLHCGreenBalls containsString:key]) {
        [results addObject:YZMsg(@"OpenAward_NiuNiu_Green")];
    } else {
        [results addObject:YZMsg(@"OpenAward_NiuNiu_Red")];
    }
    
    if (texts.lastObject) {
        [results addObject:texts.lastObject];
    } else {
        NSArray *winWays = self.resultDict[@"winWays"];
        NSString *result = [winWays filterBlock:^BOOL(NSString *object) {
            return [object hasPrefix:@"特肖_"];
        }].firstObject;
        if (result) {
            NSString *text = [result componentsSeparatedByString:@"_"].lastObject;
            if (text) {
                [results addObject:text];
            }
        }
    }
    
    return results;
}

@end
