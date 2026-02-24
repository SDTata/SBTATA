//
//  redListView.h
//  yunbaolive
//
//  Created by Boom on 2018/11/16.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "redListCell.h"
#import "hotModel.h"
#import "LivePlayNOScrollView.h"
@protocol redListViewDelegate <NSObject>
- (void)removeShouhuView;
@end

NS_ASSUME_NONNULL_BEGIN

@interface redListView : LivePlayNOScrollView<UITableViewDelegate,UITableViewDataSource,redListCellDelegate>
- (instancetype)initWithFrame:(CGRect)frame withZHuboMsgModel:(hotModel *)model;
@property(nonatomic,assign)id<redListViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
