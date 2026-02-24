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
#import "LotteryBetView.h"
#import "LotteryBetView_ZJH.h"

@interface LotteryBetViewController_ZJH : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

///公共部分处理
@property (assign, nonatomic)  BOOL isExit;

@property (strong, nonatomic) NSString *curIssue; // 当前期号

@property (weak, nonatomic) IBOutlet UICollectionView *openResultCollection; //开奖结果

@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel; //用户余额

@property (weak, nonatomic) IBOutlet UIButton *continueBtn; //续投按钮

@property (weak, nonatomic) IBOutlet UIView *chargeView;//充值

@property (weak, nonatomic) IBOutlet UIView *betHistoryIssueView; //开奖结果记录视图


@property (weak, nonatomic) IBOutlet UICollectionView *betChipCollectionView; //下注列表
@property (weak, nonatomic) IBOutlet UIImageView *otherPlayerImgView; //其他玩家
@property (weak, nonatomic) IBOutlet UIStackView *top5StackView;  //top5


@property (weak, nonatomic) IBOutlet UIView *noView;
@property (weak, nonatomic) IBOutlet UILabel *noLab;
@property (strong, nonatomic)  UIButton *musicBtn;//音乐开关
@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UIView *toolBg;
@property (weak, nonatomic) IBOutlet UICollectionView *openResultList;
@property (weak, nonatomic) IBOutlet UICollectionView *betHistoryList;

///视图整体弹框动画
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *KeyBTN;
@property (weak, nonatomic) IBOutlet UIButton *returnCancle;


//撩一下 游戏 礼物红包等
@property (weak, nonatomic) IBOutlet UIView *toolBar;

@property (strong, nonatomic) LotteryBetView *bet_player1_View;
@property (strong, nonatomic) LotteryBetView *bet_player2_View;
@property (strong, nonatomic) LotteryBetView *bet_player3_View;
@property (strong, nonatomic) LotteryBetView_ZJH *v_player1_Area;
@property (strong, nonatomic) LotteryBetView_ZJH *v_player2_Area;
@property (strong, nonatomic) LotteryBetView_ZJH *v_player3_Area;
@property (strong, nonatomic) UIView *v_poker_area;

@property(weak)id<lotteryBetViewDelegate>lotteryDelegate;

- (void)exitView;
- (void)setLotteryType:(NSInteger)lotteryType;
- (void)appearToolBar;

// 來自主播開播
@property (assign, nonatomic) BOOL isFromLiveBroadcast;
@end
