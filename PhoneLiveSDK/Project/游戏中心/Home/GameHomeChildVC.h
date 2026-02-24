//
//  GameHomeChildVC.h
//  phonelive2
//
//  Created by vick on 2024/10/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GameHomeChildVCDelegate <NSObject>

- (void)gameHomeChildVCDelegateRefreshFinish;

@end

@interface GameHomeChildVC : UIViewController

@property (nonatomic, weak) id <GameHomeChildVCDelegate> delegate;

- (void)startHeaderRefresh;

@end
