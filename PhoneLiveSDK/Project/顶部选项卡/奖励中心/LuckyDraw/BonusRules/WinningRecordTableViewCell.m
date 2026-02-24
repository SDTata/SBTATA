//
//  WinningRecordTableViewCell.m
//  phonelive2
//
//  Created by user on 2024/8/27.
//  Copyright © 2024 toby. All rights reserved.
//

#import "WinningRecordTableViewCell.h"
@implementation WinningRecordSectionCell
+ (CGFloat)itemHeight {
    return 40;
}
- (void)updateView {
    UILabel *titleLabel = [UIView vk_label:nil font:vkFontName(12, @"PingFangSC-Regular") color:vkColorRGB(151, 164, 176)];
    titleLabel.numberOfLines = 0;
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left);
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(-5);
        make.right.mas_equalTo(-16);
    }];
}

- (void)updateData {
    self.titleLabel.text = [self formattedDateForTM: self.itemModel[@"date"]];
}

-(NSString *)formattedDateForTM:(NSString *)inputDateString {
    // 只保留日期的格式化器
    NSDateFormatter *onlyDateFormatter = [[NSDateFormatter alloc] init];
    [onlyDateFormatter setDateFormat:@"yyyy-MM-dd"]; // 只保留日期部分

    // 获取今天的日期
    NSDate *today = [NSDate date];
    
    // 获取昨天的日期
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400]; // 86400秒是一天
    
    // 获取前天的日期
    NSDate *dayBeforeYesterday = [yesterday dateByAddingTimeInterval: -86400];
    
    // 只保留日期部分
    NSString *todayString = [onlyDateFormatter stringFromDate:today];
    NSString *yesterdayString = [onlyDateFormatter stringFromDate:yesterday];
    NSString *dayBeforeYesterdayString = [onlyDateFormatter stringFromDate:dayBeforeYesterday];

    // 根据输入日期判断是今日、昨日、前日或其他日期
    if ([inputDateString isEqualToString:todayString]) {
        return YZMsg(@"create_date_today");
    } else if ([inputDateString isEqualToString:yesterdayString]) {
        return YZMsg(@"create_date_yesterday");
    } else if ([inputDateString isEqualToString:dayBeforeYesterdayString]) {
        return YZMsg(@"Winning_record_eve");
    } else {
        return inputDateString; // 如果不是这几天，则返回 yyyy-MM-dd 格式的日期
    }
}

@end

@implementation WinningRecordTableViewCell

- (void)updateView {
    UIView *containerView = [UIView new];
    containerView.backgroundColor = UIColor.whiteColor;
    containerView.layer.cornerRadius = 12;
    containerView.layer.shadowColor = vkColorRGB(130, 147, 145).CGColor;
    containerView.layer.shadowOpacity = 0.2;
    containerView.layer.shadowOffset = CGSizeMake(0.0, 2);
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFontName(14, @"PingFangSC-Semibold") color:vkColorRGB(214, 169, 255)];
    self.titleLabel = titleLabel;
    
    UILabel *rightTitleLabel = [UIView vk_label:nil font:vkFontName(16, @"PingFangSC-Semibold") color:vkColorRGBA(0, 0, 0, 0.7)];
    self.rightTitleLabel = rightTitleLabel;
 
    
    UILabel *messageLabel = [UIView vk_label:nil font:vkFontName(12, @"PingFangSC-Regular") color:
                             self.extraData == 0 ?
                             vkColorRGB(82, 99, 119):
                             vkColorRGB(151, 164, 176)];
    self.messageLabel = messageLabel;
    
    [self.contentView addSubview:containerView];
    [containerView addSubview:titleLabel];
    [containerView addSubview:rightTitleLabel];
    [containerView addSubview:messageLabel];
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView).inset(10);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(containerView).offset(15);
        make.right.mas_equalTo(rightTitleLabel.left).inset(10);
        make.height.mas_equalTo(16);
    }];
    
    [rightTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(containerView).offset(15);
        make.right.mas_equalTo(containerView).inset(15);
        make.height.mas_equalTo(16);
    }];
    
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
        make.left.bottom.mas_equalTo(containerView).inset(15);
    }];
}

- (void)updateData {
    if ([self.extraData isEqual: @(1)]) {
        NSDictionary *data = self.itemModel;
        NSString *award = data[@"content"];
        NSString *date = data[@"tm"];
        self.rightTitleLabel.text = award;
        if ([award isEqualToString:@"再接再励"]) {
            self.rightTitleLabel.textColor = vkColorRGB(151, 164, 176);
            self.titleLabel.text = @"Sorry";
        } else {
            self.titleLabel.text = YZMsg(@"Winning_record_congratulations_your_winning_draw");
        }
        self.messageLabel.text = [NSString stringWithFormat:@"%@", date];
    } else {
        [self parseHTML:self.itemModel];
    }
}

- (void)parseHTML:(NSString *)htmlString {
    // 正则表达式：抽取 userName 和 award
    NSString *userNamePattern = @"【(.*?)】";
    NSString *awardPattern = @"抽中<span style='color: rgb\\(255, 255, 255\\);'>(.*?)</span>";
    
    NSError *error = nil;
    
    // 抽取 userName
    NSRegularExpression *userNameRegex = [NSRegularExpression regularExpressionWithPattern:userNamePattern options:0 error:&error];
    NSTextCheckingResult *userNameMatch = [userNameRegex firstMatchInString:htmlString options:0 range:NSMakeRange(0, [htmlString length])];
    NSString *userName = nil;
    if (userNameMatch) {
        userName = [htmlString substringWithRange:[userNameMatch rangeAtIndex:1]];
    }
    
    // 抽取 award
    NSRegularExpression *awardRegex = [NSRegularExpression regularExpressionWithPattern:awardPattern options:0 error:&error];
    NSTextCheckingResult *awardMatch = [awardRegex firstMatchInString:htmlString options:0 range:NSMakeRange(0, [htmlString length])];
    NSString *award = nil;
    if (awardMatch) {
        award = [htmlString substringWithRange:[awardMatch rangeAtIndex:1]];
    }
    
    
    self.rightTitleLabel.text = award;
    
    if ([self.extraData isEqual: @(1)]) {
        if ([award isEqualToString:@"再接再励"]) {
            self.rightTitleLabel.textColor = vkColorRGB(151, 164, 176);
            self.titleLabel.text = @"Sorry";
        } else {
            self.titleLabel.text = YZMsg(@"Winning_record_congratulations_your_winning_draw");
        }
        self.messageLabel.text = [NSString stringWithFormat:@"%@", userName];
    } else {
        self.messageLabel.text = [NSString stringWithFormat:@"%@%@", YZMsg(@"Winning_record_user_name"),userName];
        self.titleLabel.text = YZMsg(@"Winning_record_Congratulations_user_winning_draw");
    }
}
@end
