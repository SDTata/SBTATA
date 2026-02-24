//
//  BetAnimationView_LH.h
//  phonelive2
//
//  Created by vick on 2024/1/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BetAnimationView_LH : UIView

@property (nonatomic, copy) NSString *winValue;

- (void)startAnimation;

- (void)stopAnimation;

- (void)clear;

@end
