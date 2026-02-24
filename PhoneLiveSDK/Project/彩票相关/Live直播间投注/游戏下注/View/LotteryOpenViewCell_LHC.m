//
//  LotteryOpenViewCell_LHC.m
//  c700LIVE
//
//  Created by lucas on 10/17/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryOpenViewCell_LHC.h"

@implementation LotteryOpenViewCell_LHC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(lastResultModel *)model{
    _model = model;
    self.issueLab.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), model.issue];
    NSDictionary * teDic = model.te_ma_obj;
    self.seLab.text = teDic[@"title"];
    self.shulab.text = teDic[@"num"];
    NSArray *open_result = [model.open_result componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    NSArray * btnArr = @[self.btn1,self.btn2,self.btn3,self.btn4,self.btn5,self.btn6,self.btnTe];
    if (open_result.count == 7) {
        for (int i = 0;i<result_count;i++) {
            NSString * numStr = open_result[i];
            NSInteger iNumber = [numStr integerValue];
            UIButton * btn = btnArr[i];
            [btn setTitle:numStr forState:UIControlStateNormal];
            NSString * seStr = @"";
            
            // 六合彩
            // 红波：01-02-07-08-12-13-18-19-23-24-29-30-34-35-40-45-46
            if(iNumber == 1 || iNumber == 2 || iNumber == 7 || iNumber == 8 || iNumber == 12 || iNumber == 13 || iNumber == 18 || iNumber == 19 || iNumber == 23 || iNumber == 24 || iNumber == 29 || iNumber == 30 || iNumber == 34 || iNumber == 35 || iNumber == 40 || iNumber == 45 || iNumber == 46){
                [btn setBackgroundImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc_%@.png", @"red"]] forState:UIControlStateNormal];
                seStr = YZMsg(@"OpenAward_NiuNiu_Red");
            }
            // 蓝波：03-04-09-10-14-15-20-25-26-31-36-37-41-42-47-48
            else if(iNumber == 3 || iNumber == 4 || iNumber == 9 || iNumber == 10 || iNumber == 14 || iNumber == 15 || iNumber == 20 || iNumber == 25 || iNumber == 25 || iNumber == 26 || iNumber == 31 || iNumber == 36 || iNumber == 37 || iNumber == 41 || iNumber == 42 || iNumber == 47 || iNumber == 48){
                [btn setBackgroundImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc_%@.png", @"blue"]] forState:UIControlStateNormal];
                seStr = YZMsg(@"OpenAward_NiuNiu_Blue");
            }
            // 绿波：05-06-11-16-17-21-22-27-28-32-33-38-39-43-44-49
            else if(iNumber == 5 || iNumber == 6 || iNumber == 11 || iNumber == 16 || iNumber == 17 || iNumber == 21 || iNumber == 22 || iNumber == 27 || iNumber == 28 || iNumber == 32 || iNumber == 33 || iNumber == 38 || iNumber == 39 || iNumber == 43 || iNumber == 44 || iNumber == 49){
                [btn setBackgroundImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc_%@.png", @"green"]] forState:UIControlStateNormal];
                seStr = YZMsg(@"OpenAward_NiuNiu_Green");
            }
            
            if(i == 6){
                self.shulab.text = numStr;
                self.bigLab.text = iNumber>24 ? @"大":@"小";
                int num = iNumber%2;
                self.danLab.text = num == 0? @"双":@"单";
                self.blueLab.text = seStr;
            }
        }
        
    }
  

}


@end
