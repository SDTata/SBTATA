//
//  LiveGifImage.m
//  phonelive2
//
//  Created by Co co on 2025/3/24.
//  Copyright © 2025 toby. All rights reserved.
//

#import "LiveGifImage.h"

@implementation LiveGifImage{
    BOOL _loopCountChanged;
    NSUInteger _animatedImageLoopCount;
}

- (NSUInteger)animatedImageLoopCount {
    return _loopCountChanged ? _animatedImageLoopCount : [super animatedImageLoopCount];
}

- (void)setAnimatedImageLoopCount:(NSUInteger)animatedImageLoopCount {
    _loopCountChanged = YES;
    _animatedImageLoopCount = animatedImageLoopCount;
}

@end
