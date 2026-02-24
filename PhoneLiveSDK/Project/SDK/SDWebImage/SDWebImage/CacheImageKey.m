#import "CacheImageKey.h"
#import "CachePostVideo.h"
static NSString *strPathCacheImageKey = @"ArchiveDomainsPath_ImageKey";
static CacheImageKey *logic;


@interface CacheImageKey ()


@end


@implementation CacheImageKey
MJExtensionCodingImplementation

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        logic = [NSKeyedUnarchiver unarchiveObjectWithFile:DocumentPath(strPathCacheImageKey)];
        if (logic == nil) {
            logic = [[super allocWithZone:NULL] init];
        }
    });
    
    return logic;
}


-(void)saveImageKeyCache
{
    @try {
        if (self && strPathCacheImageKey) {
            NSString *path = DocumentPath(strPathCacheImageKey);
            if (path) {
                [NSKeyedArchiver archiveRootObject:self toFile:path];
            }
        }
        
        // 安全调用CachePostVideo
        CachePostVideo *cachePostVideo = [CachePostVideo sharedManager];
        if (cachePostVideo) {
            [cachePostVideo saveCachePostVideo];
        }
    } @catch (NSException *exception) {
        NSLog(@"saveImageKeyCache exception: %@", exception);
    }
}


@end
