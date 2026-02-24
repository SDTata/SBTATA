//
//  TouchSuperView.m
//  phonelive2
//
//  Created by s5346 on 2023/12/5.
//  Copyright © 2023 toby. All rights reserved.
//

#import "TouchSuperView.h"

@implementation TouchSuperView
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return true;
    }
    return false;
}
@end
