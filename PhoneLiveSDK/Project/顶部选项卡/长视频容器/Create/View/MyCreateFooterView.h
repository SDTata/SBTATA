//
//  MyCreateFooterView.h
//  phonelive2
//
//  Created by vick on 2024/7/22.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKButton.h"
#import "ShortVideoModel.h"

@protocol MyCreateFooterViewDelegate <NSObject>

/// 视频全选
- (void)myCreateFooterViewDeletgateSelectAll:(BOOL)isSelected;

/// 刷新列表
- (void)myCreateFooterViewDeletgateRefreshList;

@end

@interface MyCreateFooterView : UIView

@property (nonatomic, copy) NSString *type;

@property (nonatomic, strong) NSArray <ShortVideoModel *> *selectVideos;

@property (nonatomic, weak) id <MyCreateFooterViewDelegate> delegate;

@end
