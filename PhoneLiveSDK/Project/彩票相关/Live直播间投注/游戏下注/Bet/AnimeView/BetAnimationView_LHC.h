//
//  BetAnimationView_LHC.h
//  phonelive2
//
//  Created by vick on 2023/12/15.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BetAnimationView_LHC : UIView

@property (nonatomic, copy) NSString *winValue;

- (void)startAnimation;

- (void)stopAnimation;

- (void)clear;

@end
