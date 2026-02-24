//
//  HomeSearchResultChildVC.h
//  phonelive2
//
//  Created by user on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VKPagerChildVC.h"
#import "MovieHomeModel.h"
#import "HomeSearchResultModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSearchResultChildVC : VKPagerChildVC
@property (nonatomic, assign) NSInteger type; //0 全部, 1 短剧 2 短视频 3 长视频(电影) 4直播
@property(nonatomic,strong) NSString *key; // 输入搜索
@property (nonatomic, assign) BOOL isFromHashTag;
@property(nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL onceDelay; // 是否一次性延遲呼叫API
- (void)loadListData;
- (void)claerAllData;
@end

NS_ASSUME_NONNULL_END
