//
//  SkitHotModel.h
//  phonelive2
//
//  Created by s5346 on 2024/7/8.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeRecommendSkitModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CateInfoModel : NSObject

@property (nonatomic, copy) NSString *cate_id;
@property (nonatomic, copy) NSString *name;

@end

//@interface CateSkitListModel : NSObject
//
//@property (nonatomic, copy) NSString *video_id;
//@property (nonatomic, copy) NSString *name;
//@property (nonatomic, copy) NSString *desc;
//@property (nonatomic, copy) NSString *over;
//@property (nonatomic, copy) NSString *language;
//@property (nonatomic, copy) NSString *cate_id;
//@property (nonatomic, copy) NSString *total_episodes;
//@property (nonatomic, copy) NSString *release_time;
//@property (nonatomic, copy) NSString *end_time;
//@property (nonatomic, copy) NSString *is_hot;
//@property (nonatomic, copy) NSString *is_new;
//@property (nonatomic, copy) NSString *featured_end_time;
//@property (nonatomic, copy) NSString *addtime;
//@property (nonatomic, copy) NSString *uptime;
//@property (nonatomic, copy) NSString *plat;
//
//@end

@interface SkitHotModel : NSObject

@property (nonatomic, strong) NSArray<CateInfoModel *> *cate_info;
@property (nonatomic, strong) NSArray<HomeRecommendSkit *> *cate_skit_list;
@property (nonatomic, strong) NSArray<HomeRecommendSkit *> *list;
@property (nonatomic, copy) NSString *ticket_count;

@end

NS_ASSUME_NONNULL_END
