//
//  BetAnimationView_YFKS.h
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BetAnimationView_YFKS : UIView

@property (nonatomic, copy) NSString *winValue;

- (void)startAnimation;

- (void)stopAnimation;

- (void)clear;

@end
