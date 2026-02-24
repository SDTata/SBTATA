//
//  UserBonusModel.h
//  phonelive2
//
//  Created by s5346 on 2024/8/22.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserBonusItemModel : NSObject

@property (nonatomic, strong) NSString *coin;
@property (nonatomic, strong) NSString *day;

@end

@interface UserBonusModel : NSObject

@property (nonatomic, strong) NSString *bonus_day;
@property (nonatomic, strong) NSArray<UserBonusItemModel *> *bonus_list;
@property (nonatomic, strong) NSString *bonus_switch;
@property (nonatomic, strong) NSString *count_day;

@end

NS_ASSUME_NONNULL_END
