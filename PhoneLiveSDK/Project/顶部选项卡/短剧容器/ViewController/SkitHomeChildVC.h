//
//  SkitHomeChildVC.h
//  phonelive2
//
//  Created by vick on 2024/9/29.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkitHotModel.h"

@protocol SkitHomeChildDelegate <NSObject>

- (void)skitHomeChildDeletgateRefreshFinish;

@end

@interface SkitHomeChildVC : VKPagerChildVC

@property (nonatomic, strong) CateInfoModel *cateModel;
@property (nonatomic, weak) id <SkitHomeChildDelegate> delegate;

- (void)startHeaderRefresh;
- (void)reloadData;

@end
