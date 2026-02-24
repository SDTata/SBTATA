//
//  GlobalDate.h
//
//  Created by Boom on 2018/9/19.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface GlobalDate : NSObject
/**
 单例类方法
 
 @return 返回一个共享对象
 */
+ (instancetype)sharedInstance;

+ (NSInteger)getLiveUID;

+ (void)setLiveUID:(NSInteger)liveuid;

@end

NS_ASSUME_NONNULL_END
