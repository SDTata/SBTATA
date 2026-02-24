//
//  VipPayModel.h
//  phonelive2
//
//  Created by vick on 2025/2/10.
//  Copyright © 2025 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VipPayListModel : NSObject
@property (nonatomic, copy) NSString *id_;
@property (nonatomic, copy) NSString *coin;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *length;
@property (nonatomic, copy) NSString *orderno;
@property (nonatomic, copy) NSString *addtime;
@property (nonatomic, copy) NSString *length_name;
@property (nonatomic, copy) NSString *orig_coin_price;
@property (nonatomic, assign) BOOL selected;
@end

@interface VipPayUserModel : NSObject
@property (nonatomic, copy) NSString *id_;
@property (nonatomic, copy) NSString *user_nicename;
@property (nonatomic, copy) NSString *coin;
@end

@interface VipPayModel : NSObject
@property (nonatomic, strong) VipPayUserModel *user;
@property (nonatomic, strong) NSArray <VipPayListModel *> *vip_list;
@end

NS_ASSUME_NONNULL_END
