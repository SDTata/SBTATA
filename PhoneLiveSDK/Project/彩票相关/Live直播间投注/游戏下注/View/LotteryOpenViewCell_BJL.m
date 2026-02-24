//
//  LotteryOpenViewCell_BJL.m
//  phonelive2
//
//  Created by lucas on 10/17/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryOpenViewCell_BJL.h"

@implementation LotteryOpenViewCell_BJL

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(void)setModel:(lastResultModel *)model
{
    _model = model;
    if(_isShowJustLast){
        self.issueLab.hidden = YES;
        self.issueLab.text = @"";
        self.spaceTitle.constant = 5;
        if (!_isFullscreen) {
            self.rightLab.textAlignment = NSTextAlignmentCenter;
            [self.rightLab setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
            self.rightLab.layer.cornerRadius = self.rightLab.height/2;
            self.rightLab.layer.masksToBounds = YES;
        }
    }else{
        self.issueLab.hidden = NO;
        self.issueLab.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), model.issue];
    }
  
    self.rightLab.text =  [NSString stringWithFormat:@" %@ ",model.open_result];

    if ( model.vs.blue.pai.count){
        //蓝方
         NSString * number1 = [model.vs.blue.pai objectAtIndex:0];
        NSString *imgName1 = minstr([PublicObj getPokerNameBy:number1]);
        [self.blue1 setImage:[ImageBundle imagewithBundleName:imgName1]];
        NSString * number2 = [model.vs.blue.pai objectAtIndex:1];
        NSString *imgName2 = minstr([PublicObj getPokerNameBy:number2]);
        [self.blue2 setImage:[ImageBundle imagewithBundleName:imgName2]];
       
        if(model.vs.blue.pai.count>2){
            NSString * number3 = [model.vs.blue.pai objectAtIndex:2];
            if([number3 isEqual:@"0"]){
                [self.blue3 setImage:[UIImage imageNamed:@""]];
            }else{
                NSString *imgName3 = minstr([PublicObj getPokerNameBy:number3]);
                [self.blue3 setImage:[ImageBundle imagewithBundleName:imgName3]];
                self.blue3.transform = CGAffineTransformMakeRotation(M_PI/2.0);
            }
        }else{
            [self.blue3 setImage:[UIImage imageNamed:@""]];
        }
        if ([model.vs.blue.dian containsString:@"点"]) {
            self.idleLab.text = [[model.vs.blue.dian substringToIndex:model.vs.blue.dian.length-1] stringByAppendingFormat:@" %@",YZMsg(@"points")];
        }else{
            self.idleLab.text = [model.vs.blue.dian stringByAppendingFormat:@" %@",YZMsg(@"points")];
        }
        
    }
    
    if ( model.vs.red.pai.count){
        //蓝方
         NSString * number1 = [model.vs.red.pai objectAtIndex:0];
        NSString *imgName1 = minstr([PublicObj getPokerNameBy:number1]);
        [self.red1 setImage:[ImageBundle imagewithBundleName:imgName1]];
        NSString * number2 = [model.vs.red.pai objectAtIndex:1];
        NSString *imgName2 = minstr([PublicObj getPokerNameBy:number2]);
        [self.red2 setImage:[ImageBundle imagewithBundleName:imgName2]];
        if(model.vs.red.pai.count>2){
            NSString * number3 = [model.vs.red.pai objectAtIndex:2];
            if([number3 isEqual:@"0"]){
                [self.red3 setImage:[UIImage imageNamed:@""]];
            }else{
                NSString *imgName3 = minstr([PublicObj getPokerNameBy:number3]);
                [self.red3 setImage:[ImageBundle imagewithBundleName:imgName3]];
                self.red3.transform = CGAffineTransformMakeRotation(M_PI/2.0);

            }
        }else{
            [self.red3 setImage:[UIImage imageNamed:@""]];
        }
        if ([model.vs.red.dian containsString:@"点"]) {
            self.aLab.text = [[model.vs.red.dian substringToIndex:model.vs.red.dian.length-1] stringByAppendingFormat:@" %@",YZMsg(@"points")];
        }else{
            self.aLab.text = [model.vs.red.dian stringByAppendingFormat:@" %@",YZMsg(@"points")];
        }
       

    }

    
}


- (void)updateConstraintsForFullscreen {
    self.issuLabLeadiingConstraint.constant = 20;
    self.spaceTitle.priority = 250;
    self.imgV1LeadiingConstraint.priority = 250;
    self.imgV1HorizontalConstraint.priority = 1000;
    self.rigthtLabTrailingConstraint.constant = 20;
}

@end
