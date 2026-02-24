//
//  DramaInfoModel.h
//  phonelive2
//
//  Created by s5346 on 2024/5/17.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DramaInfoModel : NSObject

@property (nonatomic, assign) NSInteger addtime;
@property (nonatomic, assign) NSInteger cate_id;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) NSInteger end_time;
@property (nonatomic, assign) NSInteger featured_end_time;
@property (nonatomic, assign) NSString *skit_id;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *over;
@property (nonatomic, strong) NSString *pay_type;
@property (nonatomic, strong) NSString *plat;
@property (nonatomic, assign) NSInteger release_time;
@property (nonatomic, assign) NSInteger total_episodes;
@property (nonatomic, assign) NSInteger uptime;
@property (nonatomic, strong) NSString *p_progress;

@property (nonatomic, assign) BOOL is_favorite;
@property (nonatomic, assign) NSInteger skit_ticket_count;

@end

NS_ASSUME_NONNULL_END
