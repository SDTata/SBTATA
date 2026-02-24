//
//  UIButton+Additions.m
//  RacingUKiPad
//
//  Created by Neil Edwards on 26/09/2013.
//  Copyright (c) 2013 racinguk. All rights reserved.
//

#import "UIButton+Additions.h"
#import <objc/runtime.h>

#define buleColor   [UIColor colorWithRed:60/255.0f green:140/255.0f blue:232/255.0f alpha:1.0]
#define purpleColor [UIColor colorWithRed:171/255.0f green:145/255.0f blue:234/255.0f alpha:1.0]

@implementation UIButton (Additions)

static char dataProviderKey;

- (NSObject *)dataProvider {
    return objc_getAssociatedObject(self, &dataProviderKey);
}

- (void)setDataProvider:(NSObject *)dataProvider {
    objc_setAssociatedObject(self, &dataProviderKey, dataProvider, OBJC_ASSOCIATION_RETAIN);
}

/**
添加渐变色特效
*/
-(void)addGradientButton:(UIColor *)startColor endColor:(UIColor *)endColor
{
    if(!startColor){
        startColor = buleColor;
    }
    if(!endColor){
        endColor = purpleColor;
    }
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.colors = @[(__bridge id)startColor.CGColor,(__bridge id)endColor.CGColor];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(1.0, 0);
    layer.frame = self.bounds;
    [self.layer addSublayer:layer];
}



@end
