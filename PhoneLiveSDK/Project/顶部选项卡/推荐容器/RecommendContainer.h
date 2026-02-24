//
//  RecommendContainer.h
//  phonelive2
//
//  Created by user on 2024/9/30.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecommendContainer : VKPagerVC
@property (nonatomic, strong) NSArray *tags;
- (void)resetOperate;
- (void)convertCoinOut:(nullable NSNotification*)notification;
- (void)handleRecommendRefresh;
- (void)handleRedirectToRecommend;
- (void)needShowTicket:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
