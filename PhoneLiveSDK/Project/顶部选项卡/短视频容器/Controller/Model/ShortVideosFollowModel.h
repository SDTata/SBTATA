//
//  ShortVideosFollowModel.h
//  phonelive2
//
//  Created by s5346 on 2024/9/27.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShortVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShortVideosFollowUserModel : NSObject

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *fans_count;
@property (nonatomic, copy) NSString *follow_count;
@property (nonatomic, copy) NSString *is_followed;
@property (nonatomic, copy) NSString *like_count;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *is_recommend;

@end

@interface ShortVideosFollowModel : NSObject

@property (nonatomic, strong) ShortVideosFollowUserModel *user;
@property (nonatomic, strong) NSArray<ShortVideoModel *> *videos;

@end

NS_ASSUME_NONNULL_END
