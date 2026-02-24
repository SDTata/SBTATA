//
//  LotteryOpenViewCell_SC.m
//  c700LIVE
//
//  Created by lucas on 10/17/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryOpenViewCell_SC.h"

@implementation LotteryOpenViewCell_SC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(lastResultModel *)model{
    _model = model;
    self.issueLab.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), model.issue];
    NSArray *open_result = [model.open_result componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    NSArray * labArr = @[self.lab1,self.lab2,self.lab3,self.lab4,self.lab5,self.lab6,self.lab7,self.lab8,self.lab9,self.lab10];
    if (open_result.count == 10) {
        for (int i = 0;i<result_count;i++) {
            NSString * numStr = open_result[i];
            NSInteger iNumber = [numStr integerValue];
            if(i == 0){
                self.shuLab.text = numStr;
                self.xiaoLab.text = iNumber>5 ? @"大":@"小";
                int num = iNumber%2;
                self.danLab.text = num == 0? @"双":@"单";
            }
//            sum = sum + [numStr intValue];

            UILabel * lab = labArr[i];
            if(iNumber == 1){
                lab.backgroundColor = UIColorFromRGB(0xe6dc49);
            }
            if(iNumber == 2){
                lab.backgroundColor = UIColorFromRGB(0x3d92d7);
            }
            if(iNumber == 3){
                lab.backgroundColor = UIColorFromRGB(0x4b4b4b);
            }
            if(iNumber == 4){
                lab.backgroundColor = UIColorFromRGB(0xef7d31);
            }
            if(iNumber == 5){
                lab.backgroundColor = UIColorFromRGB(0x67dfe3);
            }
            if(iNumber == 6){
                lab.backgroundColor = UIColorFromRGB(0x4b3ff5);
            }
            if(iNumber == 7){
                lab.backgroundColor = UIColorFromRGB(0xbfbfbf);
            }
            if(iNumber == 8){
                lab.backgroundColor = UIColorFromRGB(0xeb3f25);
            }
            if(iNumber == 9){
                lab.backgroundColor = UIColorFromRGB(0x6e190b);
            }
            if(iNumber == 10){
                lab.backgroundColor = UIColorFromRGB(0x57bb37);
            }
        }

        self.lab1.text = open_result[0];
        self.lab2.text = open_result[1];
        self.lab3.text = open_result[2];
        self.lab4.text = open_result[3];
        self.lab5.text = open_result[4];
        self.lab6.text = open_result[5];
        self.lab7.text = open_result[6];
        self.lab8.text = open_result[7];
        self.lab9.text = open_result[8];
        self.lab10.text = open_result[9];
    }
  
    
}
- (void)updateConstraintsForFullscreen {
    self.issuLabLeadiingConstraint.constant = 30;
    self.rightImg1TrailingConstraint.constant = 30;
    self.rightImg2TrailingConstraint.constant = 30;
}
@end
