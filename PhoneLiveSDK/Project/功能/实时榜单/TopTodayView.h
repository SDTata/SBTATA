//
//  TopTodayView.h
//  phonelive
//
//  Created by 400 on 2020/7/28.
//  Copyright © 2020 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hotModel.h"
#import "LivePlayNOScrollView.h"
NS_ASSUME_NONNULL_BEGIN
@protocol TopTodatDelegate <NSObject>
-(void)sendGiftAction;

@end

@interface TopTodayModel:NSObject
@property(nonatomic,strong,nullable)NSString *coin;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *photo;
@property(nonatomic,strong)NSString *uid;
@property(nonatomic,assign)NSInteger index;

@property(nonatomic,assign,nullable)NSString *numberLast;
@end

@interface TopTodayView : LivePlayNOScrollView
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *currentUserLevelabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deslabel;
@property (weak, nonatomic) IBOutlet UIButton *giftSendButton;
@property(nonatomic,weak)id<TopTodatDelegate> delegate;
@property(nonatomic,retain)NSArray<TopTodayModel*> *datasArray;
@property(nonatomic,retain)hotModel *model;
+(nonnull TopTodayView*)showInView:(UIView *)superView model:(nullable hotModel*)model delegate:(nullable id)delegate;
@end



NS_ASSUME_NONNULL_END
