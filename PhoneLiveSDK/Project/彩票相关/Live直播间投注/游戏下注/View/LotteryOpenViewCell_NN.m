//
//  LotteryBetViewCell_NN.m
//  phonelive2
//
//  Created by lucas on 10/16/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryOpenViewCell_NN.h"

@implementation LotteryOpenViewCell_NN

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(void)setModel:(lastResultModel *)model
{
    _model = model;
    self.issuLab.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), model.issue];
    self.leftWinMask.hidden = model.who_win == 1;
    self.rightWinMask.hidden   = model.who_win == 0;
    _leftNLabel.text = model.vs.blue.niu;
    _rightNNLabel.text = model.vs.red.niu;
    
    if ( model.vs.blue.pai.count && model.vs.blue.pai.count == 5){
        //蓝方
         NSString * number1 = [model.vs.blue.pai objectAtIndex:0];
        NSString *imgName1 = minstr([PublicObj getPokerNameBy:number1]);
        [self.blue1 setImage:[ImageBundle imagewithBundleName:imgName1]];
        NSString * number2 = [model.vs.blue.pai objectAtIndex:1];
        NSString *imgName2 = minstr([PublicObj getPokerNameBy:number2]);
        [self.blue2 setImage:[ImageBundle imagewithBundleName:imgName2]];
        NSString * number3 = [model.vs.blue.pai objectAtIndex:2];
        NSString *imgName3 = minstr([PublicObj getPokerNameBy:number3]);
        [self.blue3 setImage:[ImageBundle imagewithBundleName:imgName3]];
        NSString * number4 = [model.vs.blue.pai objectAtIndex:3];
        NSString *imgName4 = minstr([PublicObj getPokerNameBy:number4]);
        [self.blue4 setImage:[ImageBundle imagewithBundleName:imgName4]];
        NSString * number5 = [model.vs.blue.pai objectAtIndex:4];
        NSString *imgName5 = minstr([PublicObj getPokerNameBy:number5]);
        [self.blue5 setImage:[ImageBundle imagewithBundleName:imgName5]];
    }
    if ( model.vs.red.pai.count && model.vs.red.pai.count == 5){
        //红方
         NSString * number1 = [model.vs.red.pai objectAtIndex:0];
         NSString *imgName1 = minstr([PublicObj getPokerNameBy:number1]);
         [self.red1 setImage:[ImageBundle imagewithBundleName:imgName1]];
        NSString * number2 = [model.vs.red.pai objectAtIndex:1];
        NSString *imgName2 = minstr([PublicObj getPokerNameBy:number2]);
        [self.red2 setImage:[ImageBundle imagewithBundleName:imgName2]];
        NSString * number3 = [model.vs.red.pai objectAtIndex:2];
        NSString *imgName3 = minstr([PublicObj getPokerNameBy:number3]);
        [self.red3 setImage:[ImageBundle imagewithBundleName:imgName3]];
        NSString * number4 = [model.vs.red.pai objectAtIndex:3];
        NSString *imgName4 = minstr([PublicObj getPokerNameBy:number4]);
        [self.red4 setImage:[ImageBundle imagewithBundleName:imgName4]];
        NSString * number5 = [model.vs.red.pai objectAtIndex:4];
        NSString *imgName5 = minstr([PublicObj getPokerNameBy:number5]);
        [self.red5 setImage:[ImageBundle imagewithBundleName:imgName5]];
    }
    
}
- (void)updateConstraintsForFullscreen {
    [self.blueOpenBg setHidden: YES];
    [self.redOpenBg setHidden: YES];
    self.issuLabLeadiingConstraint.constant = 30;
    self.redViewTrailingConstraint.constant = 30;
    self.leftWinWidthConstraint.constant = 16;
    self.leftWinTopConstraint.constant = -3;
    self.leftWinLeadingConstraint.constant = -3;
    self.rightWinWidthConstraint.constant = 16;
    self.rightWinTopConstraint.constant = -3;
    self.rightWinTrailingConstraint.constant = 3;
}
@end
