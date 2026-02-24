//
//  GameListViewController.h
//  BRMultilevelMeun
//
//  Created by gitBurning on 15/4/17.
//  Copyright (c) 2015年 BR. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface GameListTableView: UITableView
@end

@interface GameListViewController : UIViewController

@property(nonatomic,assign)BOOL isPushV;
@property(assign,nonatomic) BOOL isTableCanScroll;
@end

