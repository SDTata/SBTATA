//
//  BetAnimationView_SSC.h
//  phonelive2
//
//  Created by vick on 2023/12/15.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BetAnimationView_SSC : UIView

@property (nonatomic, copy) NSString *winValue;

@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIFont *font;
@property (assign, nonatomic) CFTimeInterval duration;
@property (assign, nonatomic) CFTimeInterval durationOffset;
@property (assign, nonatomic) NSUInteger density;
@property (assign, nonatomic) NSUInteger minLength;
@property (assign, nonatomic) BOOL isAscending;
@property (assign, nonatomic) BOOL isFinish;

- (void)startAnimation;

- (void)stopAnimation;

- (void)clear;

@end
