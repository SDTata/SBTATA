//
//  CustomScrollView.m
//  phonelive2
//
//  Created by coco on 2023/11/2.
//  Copyright © 2023 toby. All rights reserved.
//

#import "CustomScrollView.h"

@implementation CustomScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    [super touchesShouldCancelInContentView:view];
    return YES;
}

@end
