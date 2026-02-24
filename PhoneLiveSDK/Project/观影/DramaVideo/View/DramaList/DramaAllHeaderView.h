//
//  DramaAllHeaderView.h
//  phonelive2
//
//  Created by s5346 on 2024/5/15.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DramaInfoModel.h"
#import "DramaVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DramaAllHeaderView : UIView

- (void)updateData:(DramaInfoModel*)infoModel videoInfoModel:(NSArray<DramaVideoInfoModel*>*)videoInfoModels;

@end

NS_ASSUME_NONNULL_END
