#import "CachePostVideo.h"

static NSString *strPathCacheImageKey = @"ArchiveDomainsPath_CachePostVideoKey";
static CachePostVideo *logic;


@interface CachePostVideo ()

@end


@implementation CachePostVideo
//MJExtensionCodingImplementation

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
//        logic = [NSKeyedUnarchiver unarchiveObjectWithFile:DocumentPath(strPathCacheImageKey)];
        if (logic == nil) {
            logic = [[super allocWithZone:NULL] init];
        }
    });
    
    return logic;
}


-(void)saveCachePostVideo
{
//    [NSKeyedArchiver archiveRootObject:self toFile:DocumentPath(strPathCacheImageKey)];
}

-(NSArray*)getAllOthertagids
{
    NSMutableArray *aarids = [NSMutableArray array];
    for (int i=0; i<self.selectedOtherTags.count; i++) {
        NSDictionary *subDic = self.selectedOtherTags[i];
        [aarids addObject:subDic[@"id"]];
    }
    return aarids;
}
-(NSArray*)getAllCurrentTags{
    NSMutableArray *aarids = [NSMutableArray array];
    for (int i=0; i<self.selectedCurrentTags.count; i++) {
        NSDictionary *subDic = self.selectedCurrentTags[i];
        [aarids addObject:subDic[@"id"]];
    }
    return aarids;
}
@end
