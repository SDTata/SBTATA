//
//  YBPersonTableViewModel.m
//  TCLVBIMDemo
//
//  Created by 王敏欣 on 2016/11/19.
//  Copyright © 2016年 tencent. All rights reserved.
//
#import "YBPersonTableViewModel.h"
@implementation YBPersonTableViewModel
-(instancetype)initWithDic:(NSDictionary *)subdic{
    self = [super init];
    if (self) {
        _avatar = minstr([subdic valueForKey:@"avatar"]);
        _user_nicename = minstr([subdic valueForKey:@"user_nicename"]);
        _sex = minstr([subdic valueForKey:@"sex"]);
        _level = minstr([subdic valueForKey:@"level"]);
        _ID = minstr([subdic valueForKey:@"id"]);
        _VideoTimes = minstr([subdic valueForKey:@"left_video_times"]);
        _MaxVideoTimes = minstr([subdic valueForKey:@"max_video_times"]);
        _level_anchor = minstr([subdic valueForKey:@"level_anchor"]);
        if ([minstr([subdic valueForKey:@"fans"]) intValue] >= 10000) {
            _fans = [NSString stringWithFormat:YZMsg(@"YBPersonTableViewMode_fansN%.1f"),[minstr([subdic valueForKey:@"fans"]) intValue]/10000.00];
        }else{
            _fans = minstr([subdic valueForKey:@"fans"]);
        }
        if ([minstr([subdic valueForKey:@"follows"]) intValue] >= 10000) {
            _follows = [NSString stringWithFormat:YZMsg(@"YBPersonTableViewMode_fansN%.1f"),[minstr([subdic valueForKey:@"follows"]) intValue]/10000.00];
        }else{
            _follows = minstr([subdic valueForKey:@"follows"]);
        }
        if ([minstr([subdic valueForKey:@"lives"]) intValue] >= 10000) {
            _lives = [NSString stringWithFormat:YZMsg(@"YBPersonTableViewMode_fansN%.1f"),[minstr([subdic valueForKey:@"lives"]) intValue]/10000.00];
        }else{
            _lives = minstr([subdic valueForKey:@"lives"]);
        }

    }
    return self;
}
+(instancetype)modelWithDic:(NSDictionary *)subdic{
    return [[self alloc]initWithDic:subdic];
}
@end
