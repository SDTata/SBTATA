//
//  GlobalDate.m
//

#import "GlobalDate.h"
#import<CommonCrypto/CommonDigest.h>
#import "MXBADelegate.h"
#import "h5game.h"

@implementation GlobalDate
static GlobalDate* kSingleObject = nil;
static NSInteger curOpenedLiveUID = 0;

/** 单例类方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kSingleObject = [[super allocWithZone:NULL] init];
    });
    
    return kSingleObject;
}

// 重写创建对象空间的方法
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    // 直接调用单例的创建方法
    return [self sharedInstance];
}

+ (NSInteger)getLiveUID{
    return curOpenedLiveUID;
}
+ (void)setLiveUID:(NSInteger)liveuid{
    curOpenedLiveUID = liveuid;
}

@end
