//
//  GradientView.m
//  DramaTest
//
//  Created by s5346 on 2024/5/14.
//

#import "GradientView.h"

@implementation GradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithStyle:(GradientViewStyle)style {
    if (self = [super init]) {
        CAGradientLayer *layer = (CAGradientLayer *)self.layer;
        UIColor *darkColor = [UIColor colorWithWhite:0 alpha:0.8];
        UIColor *lightColor = [UIColor clearColor];
        layer.colors = @[(id)darkColor.CGColor, (id)lightColor.CGColor];
        layer.locations = @[@(0), @(1)];
        switch (style) {
            case GradientViewStyleTop:
                layer.startPoint = CGPointMake(0.5, 0);
                layer.endPoint = CGPointMake(0.5, 1);
                break;
            case GradientViewStyleRight:
                layer.startPoint = CGPointMake(1, 0.5);
                layer.endPoint = CGPointMake(0, 0.5);
                break;
            case GradientViewStyleBottom:
                layer.startPoint = CGPointMake(0.5, 1);
                layer.endPoint = CGPointMake(0.5, 0);
                break;
        }
    }
    return self;
}

@end
