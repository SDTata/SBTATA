//
//  EnterLivePlay.h
//  phonelive
//
//  Created by 400 on 2020/8/1.
//  Copyright © 2020 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "hotModel.h"
#import "LivePlayTableVC.h"
#import "LiveStreamViewCell.h"
//NS_ASSUME_NONNULL_BEGIN

@class moviePlay;
typedef void (^MoviePlayBlock)(moviePlay *callback);

@interface EnterLivePlay : NSObject
/**
 单例类方法
 
 @return 返回一个共享对象
 */
+ (instancetype)sharedInstance;

-(void)showLivePlayFromModels:(NSMutableArray *)models index:(NSInteger)index cell:(UIView * _Nullable)cell;

-(void)showLivePlayFromLiveID:(NSInteger)liveID fromInfoPage:(BOOL)fromInfoPage;
-(void)showLivePlayFromLiveModel:(hotModel*)model nplayer:(NodePlayer*)tempPlayer cell:(LiveStreamViewCell*)cell;

-(void)releaseAll;
@end

//NS_ASSUME_NONNULL_END
