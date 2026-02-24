//
//  SlotView.h
//  SlotDemo
//
//  Created by test on 2021/12/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SlotView : UIView
+ (instancetype)instanceSlotViewWithFrame:(CGRect)frame;
- (void)startSlotWithResult:(NSArray *)result animationCompleteHandler:(void(^)(void))handler;
- (void)startLine:(NSArray<NSDictionary *> *)lines withLineCompleteHander:(void(^)(void))handler;
@end

NS_ASSUME_NONNULL_END
