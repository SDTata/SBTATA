//
//  SkitAllListCell.h
//  phonelive2
//
//  Created by s5346 on 2024/7/11.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkitVideoInfoModel.h"
#import "HomePayBaseViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkitAllListCell : HomePayBaseViewTableViewCell

- (void)updateData:(SkitVideoInfoModel*)model cover:(NSString*)coverImage;

@end

NS_ASSUME_NONNULL_END
