#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HotAndAttentionPreviewLogic : NSObject<NSCoding>

+ (instancetype)sharedManager;
- (NSMutableArray *)getMyPreviewArr;
- (void)setMyPreviewArr:(NSMutableArray *)previewArr;



@end

NS_ASSUME_NONNULL_END
