//
//  LotteryOpenViewCell_SSC.m
//  c700LIVE
//
//  Created by lucas on 10/17/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryOpenViewCell_SSC.h"

@implementation LotteryOpenViewCell_SSC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(lastResultModel *)model{
    _model = model;
    self.issuLab.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), model.issue];
    NSArray *open_result = [model.open_result componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    if (result_count == 5) {
        int sum = 0;
        for (int i = 0;i<result_count;i++) {
            NSString * numStr = open_result[i];
            NSInteger iNumber = [numStr integerValue];
            sum += iNumber;
        }
        self.sumLab.text = [NSString stringWithFormat:@"%d",sum];
        self.xiaoLab.text = sum>22 ? @"大":@"小";
        int num = sum%2;
        self.danLab.text = num == 0? @"双":@"单";
        self.lab1.text = open_result[0];
        self.lab2.text = open_result[1];
        self.lab3.text = open_result[2];
        self.lab4.text = open_result[3];
        self.lab5.text = open_result[4];
        self.lab1.backgroundColor = RGB(177, 61, 50);
        self.lab2.backgroundColor = RGB(177, 61, 50);
        self.lab3.backgroundColor = RGB(177, 61, 50);
        self.lab4.backgroundColor = RGB(177, 61, 50);
        self.lab5.backgroundColor = RGB(177, 61, 50);
        
        NSInteger first = [open_result.firstObject integerValue];
        NSInteger last = [open_result.lastObject integerValue];
        if (first == last) {
            self.longLab.text = @"和";
        } else if (first > last) {
            self.longLab.text = @"龙";
        } else {
            self.longLab.text = @"虎";
        }
    }
    
}
- (void)updateConstraintsForFullscreen {
    self.issuLabLeadiingConstraint.constant = 30;
    self.rightImg1TrailingConstraint.constant = 30;
    self.rightImg2TrailingConstraint.constant = 30;
}

@end
