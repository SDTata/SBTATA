//
//  LotteryBetViewController_BJL.h
//  phonelive2
//
//  Created by test on 2021/10/12.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "EqualSpaceFlowLayoutEvolve.h"
#import "PockerView.h"
#import "BetDefineNotification.h"
#import "BetBubbleView.h"
#import "LotteryBetView.h"

@interface LotteryBetViewController_BJL : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

///公共部分处理
@property (assign, nonatomic)  BOOL isExit;

@property (strong, nonatomic) NSString *curIssue; // 当前期号

@property (weak, nonatomic) IBOutlet UICollectionView *openResultCollection; //开奖结果

@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel; //用户余额

@property (weak, nonatomic) IBOutlet UIButton *continueBtn; //续投按钮

@property (weak, nonatomic) IBOutlet UIView *chargeView;//充值

@property (weak, nonatomic) IBOutlet UIView *betHistoryIssueView; //开奖结果记录视图

@property (weak, nonatomic) IBOutlet UIButton *betHistoryButton; //我的历史投注
@property (weak, nonatomic) IBOutlet UIButton *musicBtn;//音乐开关

@property (weak, nonatomic) IBOutlet UICollectionView *betChipCollectionView; //下注列表
@property (weak, nonatomic) IBOutlet UIImageView *otherPlayerImgView; //其他玩家
@property (weak, nonatomic) IBOutlet UIStackView *top5StackView;  //top5
///一分快三游戏部分
//@property (weak, nonatomic) IBOutlet UIImageView *shaiguImgView;
@property (weak, nonatomic) IBOutlet UIImageView *iv_pokeSender;//发牌器
/*
@property (weak, nonatomic) IBOutlet UIView *bet_big_View;
@property (weak, nonatomic) IBOutlet UIView *bet_small_View;
@property (weak, nonatomic) IBOutlet UIView *bet_single_View;
@property (weak, nonatomic) IBOutlet UIView *bet_double_View;
@property (weak, nonatomic) IBOutlet UIView *bet_bao1_View;
@property (weak, nonatomic) IBOutlet UIView *bet_bao6_View;
 */
@property (strong, nonatomic) LotteryBetView *bet_player_View; //闲赢
@property (strong, nonatomic) LotteryBetView *bet_playerDouble_View;//闲对
@property (strong, nonatomic) LotteryBetView *bet_equal_View;//和
@property (strong, nonatomic) LotteryBetView *bet_superSix_View;//超级6点
@property (strong, nonatomic) LotteryBetView *bet_bank_View;//庄赢
@property (strong, nonatomic) LotteryBetView *bet_bankDouble_View;//庄对


@property (weak, nonatomic) IBOutlet UIView *toolBg;
@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UICollectionView *openResultList;
@property (weak, nonatomic) IBOutlet UICollectionView *betHistoryList;

///视图整体弹框动画
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *KeyBTN;
@property (weak, nonatomic) IBOutlet UIButton *returnCancle;
@property (weak, nonatomic) IBOutlet UIButton *gameBTN;
@property (weak, nonatomic) IBOutlet UIView *noView;
@property (weak, nonatomic) IBOutlet UILabel *noLab;

//撩一下 游戏 礼物红包等
@property (weak, nonatomic) IBOutlet UIView *toolBar;

///发牌区
@property (weak, nonatomic) IBOutlet UIView *v_player_added;
@property (weak, nonatomic) IBOutlet UIView *v_player_poker_01;
@property (weak, nonatomic) IBOutlet UIView *v_player_poker_02;
@property (weak, nonatomic) IBOutlet UIView *v_banker_poker_01;
@property (weak, nonatomic) IBOutlet UIView *v_banker_poker_02;
@property (weak, nonatomic) IBOutlet UIView *v_banker_poker_added;

@property (weak, nonatomic) IBOutlet UIView *v_player_area;
@property (weak, nonatomic) IBOutlet UIView *v_banker_area;
@property (weak, nonatomic) IBOutlet UIView *v_poker_area;

@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_01;
@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_02;
@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_03;
@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_04;
@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_05;
@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_06;

@property(weak)id<lotteryBetViewDelegate>lotteryDelegate;

- (void)exitView;
- (void)setLotteryType:(NSInteger)lotteryType;
- (void)appearToolBar;

// 來自主播開播
@property (assign, nonatomic) BOOL isFromLiveBroadcast;
@end
