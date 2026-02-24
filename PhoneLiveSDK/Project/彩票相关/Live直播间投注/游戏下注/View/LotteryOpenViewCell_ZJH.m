//
//  LotteryOpenViewCell_ZJH.m
//  phonelive2
//
//  Created by lucas on 10/16/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryOpenViewCell_ZJH.h"

@implementation LotteryOpenViewCell_ZJH

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(NSDictionary *)model
{
    _model = model;
    
    
    if(_isShowJustLast){
        self.issuLab.hidden = YES;
        self.issuLab.text = @"";
        self.spaceTitle.constant = 5;
        if(_isFullscreen) {
            self.imgV1LeadiingConstraint.priority = 250;
            self.imgV1HorizontalConstraint.priority = 250;
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
    
    NSDictionary * vsDic = model[@"vs"];
    int  who_win = [model[@"who_win"] intValue];
    NSArray * win_pai = model[@"win_pai"];
   
    if(who_win == 0){
        NSDictionary * dict = vsDic[@"player1"];
        self.resultLab.text = dict[@"pai_type_str"];
        if(win_pai==nil || (win_pai!= nil && win_pai.count<3)){
            win_pai = dict[@"pai"];
        }
    }else if (who_win == 1){
        NSDictionary * dict = vsDic[@"player2"];
        self.resultLab.text = dict[@"pai_type_str"];
        if(win_pai==nil || (win_pai!= nil && win_pai.count<3)){
            win_pai = dict[@"pai"];
        }
    }else{
        NSDictionary * dict = vsDic[@"player3"];
        self.resultLab.text = dict[@"pai_type_str"];
        if(win_pai==nil || (win_pai!= nil && win_pai.count<3)){
            win_pai = dict[@"pai"];
        }
    }

    NSString * number = model[@"open_result"];
    if ([number rangeOfString:@"玩家一"].location!=NSNotFound) {
        self.rightLab.text = [NSString stringWithFormat:@" %@ ",YZMsg(@"LobbyLotteryVC_Bleuberi")];
    }else if ([number rangeOfString:@"玩家二"].location!=NSNotFound) {
        self.rightLab.text =  [NSString stringWithFormat:@" %@ ",YZMsg(@"LobbyLotteryVC_Ceri")];
    }else if ([number rangeOfString:@"玩家三"].location!=NSNotFound) {
        self.rightLab.text =  [NSString stringWithFormat:@" %@ ",YZMsg(@"LobbyLotteryVC_Lemon")];
    }
    
    
    if (win_pai && win_pai.count == 3){
        NSString * number1 = [win_pai objectAtIndex:0];
        NSString *imgName1 = minstr([PublicObj getPokerNameBy:number1]);
        [self.imgV1 setImage:[ImageBundle imagewithBundleName:imgName1]];
        NSString * number2 = [win_pai objectAtIndex:1];
        NSString *imgName2 = minstr([PublicObj getPokerNameBy:number2]);
        [self.imgV2 setImage:[ImageBundle imagewithBundleName:imgName2]];
        NSString * number3 = [win_pai objectAtIndex:2];
        NSString *imgName3 = minstr([PublicObj getPokerNameBy:number3]);
        [self.imgV3 setImage:[ImageBundle imagewithBundleName:imgName3]];
    }else{
        
    }

    
}

- (void)updateConstraintsForFullscreen {
    self.issuLabLeadiingConstraint.constant = 40;
    self.imgV1LeadiingConstraint.priority = 250;
    self.imgV1HorizontalConstraint.priority = 1000;
    self.imgV1HorizontalConstraint.constant = 20;
    self.rigthtLabTrailingConstraint.constant = 50;
}

@end
