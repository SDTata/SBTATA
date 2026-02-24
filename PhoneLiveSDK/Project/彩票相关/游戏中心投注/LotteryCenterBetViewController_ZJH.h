//
//  LotteryBetViewController_ZJH.h
//  phonelive2
//
//  Created by test on 2021/10/27.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "EqualSpaceFlowLayoutEvolve.h"
#import "PockerView.h"
#import "BetDefineNotification.h"
#import "BetBubbleView.h"

@interface LotteryCenterBetViewController_ZJH : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

///公共部分处理

@property (weak, nonatomic) IBOutlet UICollectionView *openResultCollection; //开奖结果

@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel; //用户余额

@property (weak, nonatomic) IBOutlet UIButton *continueBtn; //续投按钮

@property (weak, nonatomic) IBOutlet UIView *chargeView;//充值

@property (weak, nonatomic) IBOutlet UIView *betHistoryIssueView; //开奖结果记录视图

@property (weak, nonatomic) IBOutlet UIButton *betHistoryButton; //我的历史投注
@property (weak, nonatomic) IBOutlet UIButton *musicBtn;//音乐开关

@property (weak, nonatomic) IBOutlet UICollectionView *betChipCollectionView; //下注列表

/**
 player_1
 */
@property (weak, nonatomic) IBOutlet UIView *bet_player1_View;
/**
 player_2
 */
@property (weak, nonatomic) IBOutlet UIView *bet_player2_View;
/**
 player_3
 */
@property (weak, nonatomic) IBOutlet UIView *bet_player3_View;
/**
 player_4
 */
@property (weak, nonatomic) IBOutlet UIView *bet_player4_View;

/**
 player_5
 */
@property (weak, nonatomic) IBOutlet UIView *bet_player5_View;
/**
 player_6
 */
@property (weak, nonatomic) IBOutlet UIView *bet_player6_View;
/**
 player_7
 */
@property (weak, nonatomic) IBOutlet UIView *bet_player7_View;

///视图整体弹框动画
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;


//撩一下 游戏 礼物红包等
@property (weak, nonatomic) IBOutlet UIImageView *iv_player1_bolder;
@property (weak, nonatomic) IBOutlet UIImageView *iv_player2_bolder;
@property (weak, nonatomic) IBOutlet UIImageView *iv_player3_bolder;

@property (weak, nonatomic) IBOutlet UIView *v_player1_Area;
@property (weak, nonatomic) IBOutlet UIView *v_player2_Area;
@property (weak, nonatomic) IBOutlet UIView *v_player3_Area;


@property (weak, nonatomic) IBOutlet UIView *v_player1_area;
@property (weak, nonatomic) IBOutlet UIView *v_player2_area;
@property (weak, nonatomic) IBOutlet UIView *v_player3_area;
@property (weak, nonatomic) IBOutlet UIView *v_poker_area;

///顶部按钮区域
@property (weak, nonatomic) IBOutlet UIView *toolBar;
@property (weak, nonatomic) IBOutlet UIView *toolBg;
@property (weak, nonatomic) IBOutlet UIButton *returnCancle;

@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UIView *noView;
@property (weak, nonatomic) IBOutlet UILabel *noLab;
@property (weak, nonatomic) IBOutlet UICollectionView *openResultList; //开奖历史
@property (weak, nonatomic) IBOutlet UICollectionView *betHistoryList; // 投注记录
@property (weak, nonatomic) IBOutlet UILabel *titleLabel; //游戏名称

@property(weak)id<lotteryBetViewDelegate>lotteryDelegate;

- (void)exitView;
- (void)setLotteryType:(NSInteger)lotteryType;

-(void)releaseView;

@end
