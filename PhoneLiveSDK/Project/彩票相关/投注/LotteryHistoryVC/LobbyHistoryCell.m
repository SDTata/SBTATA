//
//  LobbyHistoryCell.m
//  phonelive2
//
//  Created by test on 2021/6/28.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LobbyHistoryCell.h"
@interface LobbyHistoryCell()
@property (weak, nonatomic) IBOutlet UILabel *lb_name;
@property (weak, nonatomic) IBOutlet UILabel *lb_numAcontent;
@property (weak, nonatomic) IBOutlet UILabel *lb_time;
@property (weak, nonatomic) IBOutlet UILabel *lb_award;//派奖
@property (weak, nonatomic) IBOutlet UILabel *lb_status;
@property (weak, nonatomic) IBOutlet UILabel *lb_change;//帐变

@end
@implementation LobbyHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(BetListDataModel *)model{
    _model = model;
    self.lb_name.text = model.lotteryName;
    if (model.issue != nil && model.issue.length>0) {
        self.lb_numAcontent.text = [NSString stringWithFormat:YZMsg(@"history_betcontent%@%@"),model.issue,model.way];
    }else{
        self.lb_numAcontent.text = @"";
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *time = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.tm.integerValue]];
    self.lb_time.text = [NSString stringWithFormat:YZMsg(@"history_bettime%@"),time];
    self.lb_award.text = [NSString stringWithFormat:@"+ %@", [YBToolClass getRateCurrency:model.profit showUnit:YES]];
    self.lb_change.text = [NSString stringWithFormat:@"- %@", [YBToolClass getRateCurrency:model.money showUnit:YES]];
    switch (model.state.integerValue) {
        case 0:
            //未开奖
            self.lb_status.text = YZMsg(@"history_statewillaward");
            break;
        case 1:
            //未中奖
            self.lb_status.text = YZMsg(@"history_statenotaward");
            break;
        case 2:
            //中奖
            self.lb_status.text = YZMsg(@"history_statedidaward");
            break;
        case 3:
            //和局
            self.lb_status.text = YZMsg(@"history_stateequal");
            break;
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
