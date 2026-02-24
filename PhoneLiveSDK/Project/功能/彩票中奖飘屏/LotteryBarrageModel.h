//
//  LotteryBarrageModel.h
//  phonelive
//
//  Created by 400 on 2020/7/31.
//  Copyright © 2020 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LotteryBarrageModel : NSObject

@property(nonatomic,strong)NSString *showImgName;
@property(nonatomic,strong)NSString *liveuid;
@property(nonatomic,strong)NSString *lotteryType;
@property(nonatomic,strong)NSString *content;

@property(nonatomic,assign)NSInteger isCurrentUser;

@end

NS_ASSUME_NONNULL_END
