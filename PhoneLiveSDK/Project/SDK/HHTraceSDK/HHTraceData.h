//
//  HSShareData.h
//  HSShareSDK
//
//  Created by aa on 2020/10/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HHTraceData : NSObject
@property(nonatomic, copy) NSString *channel;//渠道编码
@property(nonatomic, copy) NSString *parameters;//携带安装参数
@end

NS_ASSUME_NONNULL_END
