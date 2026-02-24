//
//  LobbyHistoryBottomView.m
//  phonelive2
//
//  Created by test on 2021/9/20.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LobbyHistoryBottomView.h"
@interface LobbyHistoryBottomView()
@property (weak, nonatomic) IBOutlet UILabel *lb_tz;//投注
@property (weak, nonatomic) IBOutlet UILabel *lb_zj;//中奖
@property (weak, nonatomic) IBOutlet UILabel *lb_yl;//盈利
@property (weak, nonatomic) IBOutlet UILabel *lb_tz_tag;
@property (weak, nonatomic) IBOutlet UILabel *lb_zj_tag;
@property (weak, nonatomic) IBOutlet UILabel *lb_yl_tag;

@end
@implementation LobbyHistoryBottomView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.lb_tz_tag.text = YZMsg(@"LobbyLotteryVC_Bet");
    self.lb_zj_tag.text = YZMsg(@"history_award");
    self.lb_yl_tag.text = YZMsg(@"history_profit");

}

- (void)setModel:(BetListTotalModel *)model{
    _model = model;
    self.lb_tz.text = [NSString stringWithFormat:@"-%@", [YBToolClass getRateCurrency:model.money showUnit:YES]];
    self.lb_zj.text = [NSString stringWithFormat:@"+%@", [YBToolClass getRateCurrency:model.profit showUnit:YES]];
    
    float yl = model.profit.floatValue - model.money.floatValue;
    NSString *text = [NSString stringWithFormat:@"%.2f", fabs(yl)];
    text = [YBToolClass getRateCurrency:text showUnit:YES];
    if (yl >= 0) {
        self.lb_yl.text = [NSString stringWithFormat:@"+%@", text];
        self.lb_yl.textColor = RGB_COLOR(@"#5FB473", 1);
    }else{
        self.lb_yl.text = [NSString stringWithFormat:@"-%@", text];
        self.lb_yl.textColor = RGB_COLOR(@"#C13931", 1);
    }
}

@end
