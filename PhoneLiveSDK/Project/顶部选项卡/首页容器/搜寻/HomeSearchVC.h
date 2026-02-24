//
//  HomeSearchVC.h
//  phonelive2
//
//  Created by user on 2024/7/4.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeSearchVC : VKPagerVC
@property (nonatomic, assign) NSInteger type; //0 全部, 1 短剧 2 短视频 3 长视频(电影) 4直播
@property (nonatomic, assign) BOOL isFromHashTag;
@property(nonatomic,strong) NSString *key; // 输入搜索
@end

NS_ASSUME_NONNULL_END
