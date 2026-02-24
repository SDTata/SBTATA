//
//  GuestLogin.h
//  phonelive2
//
//  Created by 400 on 2021/4/10.
//  Copyright © 2021 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^GuestLoginBlock)(BOOL success,NSString *errorMsg);
@interface GuestLogin : NSObject
+ (instancetype)sharedInstance;
+(NSString*)getEncodefp;
-(void)loginWithGuest:(GuestLoginBlock)callback;

@end

NS_ASSUME_NONNULL_END
