//
//  RemoteControllerCell.h
//  phonelive2
//
//  Created by s5346 on 2023/12/4.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteOrderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RemoteControllerCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *selectedButton;

- (void)updateOrder:(NSInteger)index info:(RemoteOrderModel*)info;
- (void)updateRemoteToy:(NSInteger)index info:(RemoteOrderModel*)info;
- (void)updateOrderForOnlySelect:(NSInteger)index info:(RemoteOrderModel*)info;
@end

NS_ASSUME_NONNULL_END
