//
//  BetAnimationView_ZP.h
//  phonelive2
//
//  Created by vick on 2024/1/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BetAnimationView_ZP : UIView

@property (nonatomic, assign) NSInteger winValue;

- (void)startAnimation;

- (void)stopAnimation;

- (void)clear;

@end
