//
//  HomeRecommendLongVideoModel.h
//  phonelive2
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

//@interface HomeRecommendLongVideo : NSObject
//
//@property (nonatomic, assign) NSInteger comments_count;
//@property (nonatomic, copy) NSString *cover_aid;
//@property (nonatomic, copy) NSString *cover_path;
//@property (nonatomic, copy) NSString *created_at;
//@property (nonatomic, copy) NSString *desc;
//@property (nonatomic, copy) NSString *encrypted_key;
//@property (nonatomic, assign) NSInteger filesize;
//@property (nonatomic, assign) NSInteger kid;
//@property (nonatomic, assign) NSInteger is_encrypted;
//@property (nonatomic, assign) NSInteger likes_count;
//@property (nonatomic, copy) NSString *meta;
//@property (nonatomic, assign) NSInteger screen_orientation;
//@property (nonatomic, copy) NSString *title;
//@property (nonatomic, assign) NSInteger uid;
//@property (nonatomic, copy) NSString *updated_at;
//@property (nonatomic, copy) NSString *video_aid;
//@property (nonatomic, assign) NSInteger video_duration;
//@property (nonatomic, copy) NSString *video_path;
//
//@end

@interface HomeRecommendLongVideoModel : NSObject

@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSArray<ShortVideoModel *> *data;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int layout_column;
@property (nonatomic, assign) int layout_row;
@property (nonatomic, assign) BOOL isScroll;

@end

NS_ASSUME_NONNULL_END
