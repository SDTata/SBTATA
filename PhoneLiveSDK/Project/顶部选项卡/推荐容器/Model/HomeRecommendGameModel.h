//
//  HomeRecommendGameModel.h
//  phonelive2
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeRecommendGame : NSObject

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *kindID;
@property (nonatomic, copy) NSString *plat;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGFloat imageScale;

@end

@interface HomeRecommendGameModel : NSObject

@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSArray<HomeRecommendGame *> *data;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int layout_column;
@property (nonatomic, assign) int layout_row;
@property (nonatomic, assign) BOOL isScroll;

@end

NS_ASSUME_NONNULL_END
