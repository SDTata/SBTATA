//
//  SlotCell.h
//  SlotDemo
//
//  Created by test on 2021/12/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SlotCell : UITableViewCell
@property(nonatomic,strong)NSString *data;
@property(nonatomic,assign)NSInteger lineCount;//总计连线数
@property(nonatomic,assign)NSInteger remainLineCount;//剩余未连线数
@end

NS_ASSUME_NONNULL_END
