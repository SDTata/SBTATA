//
//  GradientView.h
//  DramaTest
//
//  Created by s5346 on 2024/5/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GradientViewStyle) {
    GradientViewStyleTop,
    GradientViewStyleRight,
    GradientViewStyleBottom
};

@interface GradientView : UIView

- (instancetype)initWithStyle:(GradientViewStyle)style;

@end

NS_ASSUME_NONNULL_END
