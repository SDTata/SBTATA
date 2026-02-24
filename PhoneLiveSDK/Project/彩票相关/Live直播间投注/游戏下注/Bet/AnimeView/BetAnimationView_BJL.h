//
//  BetAnimationView_BJL.h
//  phonelive2
//
//  Created by vick on 2024/1/11.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BetAnimationView_BJL : UIView

@property (nonatomic, strong) NSArray <NSArray *> *winValue;

- (void)startAnimation;

- (void)stopAnimation;

- (void)clear;

@end
