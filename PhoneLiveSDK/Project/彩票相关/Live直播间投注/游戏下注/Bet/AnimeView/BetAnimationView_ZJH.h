//
//  BetAnimationView_ZJH.h
//  phonelive2
//
//  Created by vick on 2024/1/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BetAnimationView_ZJH : UIView

@property (nonatomic, strong) NSArray <NSString *> *winTypes;
@property (nonatomic, strong) NSArray <NSArray *> *winValue;

- (void)startAnimation;

- (void)stopAnimation;

- (void)clear;

@end
