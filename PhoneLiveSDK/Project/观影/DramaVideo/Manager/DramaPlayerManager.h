//
//  DramaPlayerManager.h
//  DramaTest
//
//  Created by s5346 on 2024/5/1.
//

#import <Foundation/Foundation.h>
#import "DramaVideoInfoModel.h"
#import "VideoTableViewCell.h"
#import "DramaProgressModel.h"

#define DramaPlayerManagerAutoNextIfNeed @"DramaPlayerManagerAutoNextIfNeed"
NS_ASSUME_NONNULL_BEGIN

@protocol DramaPlayerManagerDelegate <NSObject>

- (void)dramaPlayerManagerDelegateForEnd:(BOOL)isNext;
- (void)dramaPlayerManagerDelegateForTapPay:(DramaVideoInfoModel*)model;

@end

@interface DramaPlayerManager : NSObject
@property (nonatomic, strong, readonly) ZFPlayerController *player;
@property (nonatomic, weak, readonly) DramaVideoInfoModel* model;
@property (nonatomic, weak, readonly) DramaInfoModel* infoModel;
@property(nonatomic, weak) id<DramaPlayerManagerDelegate> delegate;

- (instancetype)initWithTableView:(UITableView*)tableView;
- (void)setupVideoInfoWithCell:(VideoTableViewCell *)cell model:(DramaVideoInfoModel*)model infoModel:(DramaInfoModel*)infoModel;
- (void)playVideo:(DramaVideoInfoModel*)model;
- (void)reset;
@end

NS_ASSUME_NONNULL_END
