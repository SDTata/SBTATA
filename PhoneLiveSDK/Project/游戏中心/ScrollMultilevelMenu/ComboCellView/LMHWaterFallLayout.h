//
//  LMHWaterFallLayout.h
//  c700LIVE
//
//  Created by lucas on 2022/10/13.
//  Copyright © 2022 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LMHWaterFallLayout;

@protocol  LMHWaterFallLayoutDeleaget<NSObject>

@required
/**
 * 每个item的高度
 */
- (CGRect)waterFallLayout:(LMHWaterFallLayout *)waterFallLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath contentHeight:(CGFloat)contentHeight;




@end

@interface LMHWaterFallLayout : UICollectionViewLayout
/** 代理 */
@property (nonatomic, weak) id<LMHWaterFallLayoutDeleaget> delegate;

@end

NS_ASSUME_NONNULL_END
