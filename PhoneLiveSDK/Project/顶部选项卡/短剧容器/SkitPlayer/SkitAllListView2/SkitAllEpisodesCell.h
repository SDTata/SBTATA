//
//  SkitAllEpisodesCell.h
//  phonelive2
//
//  Created by s5346 on 2025/3/16.
//  Copyright © 2025 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkitVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkitAllEpisodesCell : UICollectionViewCell

- (void)update:(SkitVideoInfoModel*)model index:(int)index isCurrent:(BOOL)isCurrent;

@end

NS_ASSUME_NONNULL_END
