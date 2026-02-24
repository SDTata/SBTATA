//
//  DramaVideoInfoModel.h
//  phonelive2
//
//  Created by s5346 on 2024/5/21.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DramaVideoInfoModel : NSObject

@property (nonatomic, assign) NSInteger addtime;
@property (nonatomic, assign) NSInteger cate_id;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) NSInteger episode_number;
@property (nonatomic, strong) NSString *video_id;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *over;
@property (nonatomic, strong) NSString *plat;
@property (nonatomic, strong) NSString *progress;
@property (nonatomic, strong) NSString *skit_id;
@property (nonatomic, strong) NSString *tags_id;
@property (nonatomic, assign) NSInteger uptime;
@property (nonatomic, assign) BOOL is_buy;
@property (nonatomic, assign) NSInteger need_ticket_count;

@property (nonatomic, strong) NSString *play_url;
@property (nonatomic, assign) BOOL isNeedPay;
@end

NS_ASSUME_NONNULL_END
