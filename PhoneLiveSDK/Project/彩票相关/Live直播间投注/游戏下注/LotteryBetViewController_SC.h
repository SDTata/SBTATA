//
//  LotteryBetViewController_YFKS.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "EqualSpaceFlowLayoutEvolve.h"
#import "BetDefineNotification.h"
#import "BetBubbleView.h"
#import "LotteryBetView.h"
#import "BetAnimationView_SC.h"

@interface LotteryBetViewController_SC : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

///公共部分处理
@property (assign, nonatomic)  BOOL isExit;

@property (strong, nonatomic) NSString *curIssue; // 当前期号

@property (weak, nonatomic) IBOutlet UICollectionView *openResultCollection; //开奖结果
@property (weak, nonatomic) IBOutlet UILabel *openResutLab;

@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel; //用户余额fopenResultCollection
@property (weak, nonatomic) IBOutlet UILabel *smallLab;
@property (weak, nonatomic) IBOutlet UILabel *shuLab;

@property (weak, nonatomic) IBOutlet UIButton *continueBtn; //续投按钮

@property (weak, nonatomic) IBOutlet UIView *chargeView;//充值

@property (weak, nonatomic) IBOutlet UIView *betHistoryIssueView; //开奖结果记录视图
@property (weak, nonatomic) IBOutlet UIView *noView;
@property (weak, nonatomic) IBOutlet UILabel *noLab;



@property (weak, nonatomic) IBOutlet UICollectionView *betChipCollectionView; //下注列表
@property (weak, nonatomic) IBOutlet UIImageView *otherPlayerImgView; //其他玩家
@property (weak, nonatomic) IBOutlet UIStackView *top5StackView;  //top5
///一分快三游戏部分
@property (strong, nonatomic) LotteryBetView *bet_big_View;
@property (strong, nonatomic) LotteryBetView *bet_small_View;     //2
@property (strong, nonatomic) LotteryBetView *bet_single_View;    //小
@property (strong, nonatomic) LotteryBetView *bet_double_View;   //3
@property (strong, nonatomic) LotteryBetView *bet_shu1_View;
@property (strong, nonatomic) LotteryBetView *bet_shu10_View;
@property (strong, nonatomic) LotteryBetView *bet_shu9_View;
@property (strong, nonatomic) LotteryBetView *bet_shu8_View;
@property (strong, nonatomic) LotteryBetView *bet_shu7_View;
@property (strong, nonatomic) LotteryBetView *bet_shu6_View;
@property (strong, nonatomic) LotteryBetView *bet_shu4_View;
@property (strong, nonatomic) LotteryBetView *bet_shu3_View;
@property (strong, nonatomic) LotteryBetView *bet_shu5_View;
@property (strong, nonatomic) LotteryBetView *bet_shu2_View;

@property (nonatomic, strong) BetAnimationView_SC *animationView;

@property (strong, nonatomic)  UIButton *musicBtn;//音乐开关
@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UIView *toolBg;
@property (weak, nonatomic) IBOutlet UICollectionView *openResultList;
@property (weak, nonatomic) IBOutlet UICollectionView *betHistoryList;


//撩一下 游戏 礼物红包等
@property (weak, nonatomic) IBOutlet UIView *toolBar;

///视图整体弹框动画
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *KeyBTN;
@property (weak, nonatomic) IBOutlet UIButton *returnCancle;

@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_01;
@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_02;
@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_03;
@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_04;
@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_05;
@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_06;
@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_07;
@property (weak, nonatomic) IBOutlet BetBubbleView *v_bubble_08;
@property(weak)id<lotteryBetViewDelegate>lotteryDelegate;

- (void)exitView;
- (void)setLotteryType:(NSInteger)lotteryType;
- (void)appearToolBar;

// 來自主播開播
@property (assign, nonatomic) BOOL isFromLiveBroadcast;
@end

