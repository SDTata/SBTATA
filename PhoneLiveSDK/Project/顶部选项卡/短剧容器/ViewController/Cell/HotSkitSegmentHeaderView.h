//
//  HotSkitSegmentHeaderView.h
//  NewDrama
//
//  Created by s5346 on 2024/6/28.
//

#import <UIKit/UIKit.h>
#import "SkitHotModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HotSkitSegmentHeaderView : UICollectionReusableView

@property (nonatomic, copy) void (^tapBlock)(NSString*);
- (void)update:(NSArray<CateInfoModel*>*)models cateId:(NSString*)cateId;

@end

@interface HotSkitSegmentHeaderViewCell: UIControl

- (instancetype)initWithTitle:(NSString*)title;

@end

NS_ASSUME_NONNULL_END
