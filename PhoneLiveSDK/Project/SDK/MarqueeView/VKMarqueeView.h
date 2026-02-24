//
//  VKMarqueeView.h
//
//  Created by vick on 2023/8/11.
//

#import <UIKit/UIKit.h>

@interface VKMarqueeView : UIScrollView

@property (nonatomic, assign) BOOL stop;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, assign) CGFloat space;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSNumber *fromStartX;
@property (nonatomic, copy) void (^clickBlock)(NSInteger index);

@end
