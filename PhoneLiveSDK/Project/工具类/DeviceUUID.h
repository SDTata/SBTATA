//
//  DeviceUUID.h
//  phonelive2
//
//  Created by 400 on 2021/6/10.
//  Copyright © 2021 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceUUID : NSObject

+ (NSString *)uuidForPhoneDevice;

//////////////

///wangyidevice
+ (NSString*)uuidFromWangyiDevice;

+ (void)setWangyiDevice:(NSString*)uuidStr;




@end

NS_ASSUME_NONNULL_END
