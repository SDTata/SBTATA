#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CacheImageKey : NSObject<NSCoding>

+ (instancetype)sharedManager;
@property(nonatomic,strong)NSDictionary *gameheightDic;

@property(nonatomic,strong)NSMutableDictionary *imageKey;


@property(nonatomic,strong)NSArray *cacheUrlHost;

-(void)saveImageKeyCache;

@end

NS_ASSUME_NONNULL_END
