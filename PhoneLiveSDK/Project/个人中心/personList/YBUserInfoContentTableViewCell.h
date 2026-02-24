//
//  YBUserInfoContentTableViewCell.h
//  phonelive2
//
//  Created by user on 2024/7/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBUserInfoContentView.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^YBUserInfoContentTableViewCellDidSelectBlock)(void);
@interface YBUserInfoContentTableViewCell : UITableViewCell
/**初始化界面*/
- (void)updateView;
@property (nonatomic, copy) YBUserInfoContentTableViewCellDidSelectBlock didSelectCellBlock;
@property (nonatomic, strong) NSArray *datas;
@property (nonatomic,assign) id <YBUserInfoContentViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
