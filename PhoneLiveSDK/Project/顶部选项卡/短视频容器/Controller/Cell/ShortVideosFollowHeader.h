//
//  ShortVideosFollowHeader.h
//  phonelive2
//
//  Created by s5346 on 2024/9/27.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShortVideosFollowModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShortVideosFollowHeader : UICollectionReusableView

- (void)update:(ShortVideosFollowUserModel*)model;

@end

NS_ASSUME_NONNULL_END
