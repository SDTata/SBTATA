//
//  SkitListViewController.h
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//短剧首页 type类型 0:观看历史 1:最新短剧 2:热门短剧 3:收藏列表
typedef NS_ENUM(NSInteger, SkitListViewControllerType) {
    SkitListViewControllerTypeHistory,//0:觀看紀錄
    SkitListViewControllerTypeLatest,//1:最新短剧
    SkitListViewControllerTypeHot,//2:热门短剧
    SkitListViewControllerTypeFavorite,//3:收藏列表
    SkitListViewControllerTypeCategory,//4:分類
};

@interface SkitListViewController : VKPagerChildVC

- (instancetype)initWithType:(SkitListViewControllerType)type;

@end

NS_ASSUME_NONNULL_END
