//
//  LotteryOpenViewCell_LH.m
//  phonelive2
//
//  Created by lucas on 10/16/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryOpenViewCell_LH.h"

@implementation LotteryOpenViewCell_LH

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(NSDictionary *)model{
    _model = model;
    
    if(_isShowJustLast){
        self.issuLab.hidden = YES;
        self.issuLab.text = @"";
        self.spaceTitle.constant = 5;
        if(_isFullscreen) {
            self.imgV1LeadiingConstraint.priority = 250;
            self.imgV1HorizontalConstraint.priority = 250;
            self.leftPointLabel.hidden = YES;
            self.rightPointLabel.hidden = YES;
            self.rigthtLabTrailingConstraint.constant = 15;
            self.spaceTitle.constant = 0;
        } else {
            self.rightLab.textAlignment = NSTextAlignmentCenter;
            [self.rightLab setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
            self.rightLab.layer.cornerRadius = self.rightLab.height/2;
            self.rightLab.layer.masksToBounds = YES;
        }
    }else{
        self.issuLab.hidden = NO;
        self.issuLab.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), model[@"issue"]];
    }
    
    self.rightLab.text =  [NSString stringWithFormat:@" %@ ",model[@"open_result"]];
    NSDictionary *vs = model[@"vs"];
    NSDictionary *tigerDic = vs[@"tiger"];
   NSString * tiger = tigerDic[@"pai"];
    NSString *imgName2 = minstr([PublicObj getPokerNameBy:tiger]);
    [self.rigthImgV setImage:[ImageBundle imagewithBundleName:imgName2]];
    NSString *pointRight = minstr(tigerDic[@"pai_type"]);
    

    self.rightPointLabel.text = [[pointRight containsString:@"点"]?[pointRight substringToIndex:pointRight.length-1]:pointRight stringByAppendingFormat:@" %@",YZMsg(@"points")];
    
    
    NSDictionary *dragonDic = vs[@"dragon"];
   NSString * dragon = dragonDic[@"pai"];
   NSString *imgName1 = minstr([PublicObj getPokerNameBy:dragon]);
   [self.leftImgV setImage:[ImageBundle imagewithBundleName:imgName1]];
    
    NSString *pointLeft = minstr(dragonDic[@"pai_type"]);
    self.leftPointLabel.text = [[pointLeft containsString:@"点"]?[pointLeft substringToIndex:pointLeft.length-1]:pointLeft stringByAppendingFormat:@" %@",YZMsg(@"points")];
   
}

- (void)updateConstraintsForFullscreen {
    self.issuLabLeadiingConstraint.constant = 40;
    self.imgV1LeadiingConstraint.priority = 250;
    self.imgV1HorizontalConstraint.priority = 1000;
    self.imgV1HorizontalConstraint.constant = 20;
    self.rigthtLabTrailingConstraint.constant = 50;
    self.leftPointLabel.hidden = YES;
    self.rightPointLabel.hidden = YES;
}
@end
