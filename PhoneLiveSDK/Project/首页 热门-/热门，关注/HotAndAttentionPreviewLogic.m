#import "HotAndAttentionPreviewLogic.h"


static HotAndAttentionPreviewLogic *logic;

@interface HotAndAttentionPreviewLogic ()

@property (nonatomic ,strong) NSMutableArray        *previewIDArr;

@end


@implementation HotAndAttentionPreviewLogic
MJExtensionCodingImplementation

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *str = [NSString stringWithFormat:@"%@%@",@"ArchiveDomainsPath1",[Config getOwnID]];
        logic = [NSKeyedUnarchiver unarchiveObjectWithFile:DocumentPath(str)];
        if (logic == nil) {
            logic = [[super allocWithZone:NULL] init];
        }
    });
    
    return logic;
}

- (NSMutableArray *)getMyPreviewArr
{
    return self.previewIDArr;
}

- (void)setMyPreviewArr:(NSMutableArray *)previewArr
{
    self.previewIDArr = previewArr;
    NSString *str = [NSString stringWithFormat:@"%@%@",@"ArchiveDomainsPath",[Config getOwnID]];
    [NSKeyedArchiver archiveRootObject:self toFile:DocumentPath(str)];
}

#pragma mark - getter

- (NSMutableArray *)previewIDArr
{
    if(!_previewIDArr)
    {
        _previewIDArr = [[NSMutableArray alloc] init];
    }
    
    return _previewIDArr;
}




@end
