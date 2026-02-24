//
//  GamesController.h
//  phonelive2
//
//  Created by test on 4/12/21.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GamesController : VKPagerChildVC
@property (nonatomic, strong) UILabel *label;
@property (nonatomic,strong)UIView *pageView;
-(void)filterVC;
@end

NS_ASSUME_NONNULL_END
