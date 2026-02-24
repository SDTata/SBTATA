//
//  MovieHomeModel.h
//  phonelive2
//
//  Created by vick on 2024/7/9.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortVideoModel.h"

@interface MovieCateModel : NSObject
@property (nonatomic, copy) NSString *id_;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger order;
@end

@interface MovieHomeModel : NSObject
@property (nonatomic, strong) MovieCateModel *sub_cate;
@property (nonatomic, strong) NSArray <ShortVideoModel *> *movies;
@end
