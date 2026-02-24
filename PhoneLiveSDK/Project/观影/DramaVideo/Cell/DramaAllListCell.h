//
//  DramaAllListCell.h
//  phonelive2
//
//  Created by s5346 on 2024/5/15.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DramaVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DramaAllListCell : UITableViewCell

- (void)updateData:(DramaVideoInfoModel*)model;

@end

NS_ASSUME_NONNULL_END
