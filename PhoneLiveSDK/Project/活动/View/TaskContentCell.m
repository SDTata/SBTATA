//
//  TaskContentCell.m
//  phonelive
//
//  Created by 400 on 2020/9/21.
//  Copyright © 2020 toby. All rights reserved.
//

#import "TaskContentCell.h"
@interface TaskContentCell()
{
    NSInteger noFinishTaskType;
}
@end

@implementation TaskContentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.downButton.layer.cornerRadius = 15;
    self.downButton.layer.masksToBounds = YES;
    self.downButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.downButton.titleLabel.minimumScaleFactor = 0.3;
    self.bgView.layer.cornerRadius = 8;
    self.bgView.layer.masksToBounds = YES;
    
    // Initialization code
}
-(void)setModel:(TaskModel *)model
{
    _model = model;
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = model.desc;
    NSString *chargeStr = @"";
    noFinishTaskType = -1;
    NSInteger cureentProgressValue = 0;
    NSInteger totalProgressValue = 0;

    for (ConditionInfoModel *subModel in model.condition_info) {
        NSString *currencyCurNum = [YBToolClass getRateCurrency:minstr(subModel.cur_num) showUnit:NO];
        NSString *currencyConditionNum = [YBToolClass getRateCurrency:minnum(subModel.condition_num) showUnit:NO];

        chargeStr = [chargeStr stringByAppendingFormat:@"%@(%@/%@)",
                     subModel.desc,
                     currencyCurNum.floatValue > currencyConditionNum.floatValue ? currencyConditionNum : currencyCurNum,
                     currencyConditionNum];
        totalProgressValue = totalProgressValue + currencyConditionNum.floatValue;
        cureentProgressValue = cureentProgressValue + currencyCurNum.floatValue;
        if (currencyCurNum.floatValue < currencyConditionNum.floatValue) {
            if (noFinishTaskType<0) {
                noFinishTaskType = subModel.condition_type;
            }
        }
    }
    self.chargeLabel.text = chargeStr;
    
//    NSArray *rewards_id = [model.reward_id componentsSeparatedByString:@","];
//    NSArray *rewards_num = [model.reward_num componentsSeparatedByString:@","];
//    NSString *rewardsStr = @"";
//    for (int i = 0; i<rewards_id.count; i++) {
//        NSString *rewards_idS = rewards_id[i];
//        NSString *rewards_ValueS = rewards_num[i];
//        if ([rewards_idS isEqualToString:@"1"]) {
//            rewardsStr = [rewardsStr stringByAppendingFormat:@"%@+%@:%@",rewardsStr.length>0?@" ":@"",[common name_votes],rewards_ValueS];
//        }else if ([rewards_idS isEqualToString:@"2"]) {
//            rewardsStr = [rewardsStr stringByAppendingFormat:@"%@+坐骑%@",rewardsStr.length>0?@" ":@"",rewards_ValueS];
//        }else if ([rewards_idS isEqualToString:@"3"]) {
//            rewardsStr = [rewardsStr stringByAppendingFormat:@"%@+VIP%@天",rewardsStr.length>0?@" ":@"",rewards_ValueS];
//        }else if ([rewards_idS isEqualToString:@"4"]) {
//            rewardsStr = [rewardsStr stringByAppendingFormat:@"%@+打码量%@",rewardsStr.length>0?@" ":@"",rewards_ValueS];
//        }
//    }
    
    self.rewardLabel.text = model.task_reward_desc;
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@ - %@",YZMsg(@"task_time"),[self timeWithTimeIntervalString:model.start_time],[self timeWithTimeIntervalString:model.end_time]];
    if (noFinishTaskType>0) {
        self.downButton.backgroundColor = RGB(231, 160, 110);
        [self.downButton setTitle:YZMsg(@"taskgofinish") forState:UIControlStateNormal];
        self.downButton.userInteractionEnabled = YES;
    }else{
        if (model.completed) {
            self.downButton.backgroundColor = [UIColor lightGrayColor];
            [self.downButton setTitle:YZMsg(@"taskfinished") forState:UIControlStateNormal];
            self.downButton.userInteractionEnabled = NO;
        }else{
            self.downButton.backgroundColor = RGB(133, 187, 171);
            [self.downButton setTitle:YZMsg(@"tasktoget") forState:UIControlStateNormal];
            self.downButton.userInteractionEnabled = YES;
        }
    }
    if (totalProgressValue != 0) {
        self.progressView.progress = cureentProgressValue * 1.0 / totalProgressValue * 1.0;
    } else {
        self.progressView.progress = 0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (NSString *)timeWithTimeIntervalString:(NSInteger )timeInteger
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:YZMsg(@"public_timeFormat1")];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInteger];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}
- (IBAction)buttonAction:(id)sender {
    if (noFinishTaskType>0) {
        if (self.taskCallback) {
            self.taskCallback(noFinishTaskType);
        }
    }else{
        [self requestReward];
    }
}
-(void)requestReward
{
    NSString *userBaseUrl = [NSString stringWithFormat:@"User.getTaskReward"];
    NSDictionary *paramDic = @{@"taskID":@(_model.ID)};
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.bgView animated:YES];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:paramDic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        if(code == 0)
        {
            strongSelf.model.completed = 1;
            [strongSelf setModel:strongSelf.model];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        
        [hud hideAnimated:YES];
    }];
}
@end
