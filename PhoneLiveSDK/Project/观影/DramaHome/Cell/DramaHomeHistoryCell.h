//
//  DramaHomeHistoryCell.h
//  DramaTest
//
//  Created by s5346 on 2024/5/3.
//

#import <UIKit/UIKit.h>
#import "DramaInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DramaHomeHistoryCellDelegate <NSObject>

- (void)dramaHomeHistoryCellForTapDrama:(DramaInfoModel*)model;
- (void)dramaHomeHistoryCellForTapMore;

@end
@interface DramaHomeHistoryCell : UICollectionViewCell

@property(nonatomic, strong) NSMutableArray<DramaInfoModel*> *dramaHistoryInfoList;
@property(nonatomic, weak) id<DramaHomeHistoryCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END

@protocol DramaHomeHistoryMoreCellDelegate <NSObject>

- (void)dramaHomeHistoryMoreCellForTap;

@end
@interface DramaHomeHistoryMoreCell : UICollectionReusableView
@property(nonatomic, weak) id<DramaHomeHistoryMoreCellDelegate> _Nullable delegate;
@end
