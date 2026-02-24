//
//  LotteryBetViewController_YFKS.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "EqualSpaceFlowLayoutEvolve.h"
#import "BetDefineNotification.h"
#import "BetBubbleView.h"
@interface LotteryCenterBetViewController_ZP : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

///公共部分处理

@property (weak, nonatomic) IBOutlet UICollectionView *openResultCollection; //开奖结果
@property (weak, nonatomic) IBOutlet UILabel *openResutLab;

@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel; //用户余额fopenResultCollection
@property (weak, nonatomic) IBOutlet UIView *betBgView;

@property (weak, nonatomic) IBOutlet UIButton *continueBtn; //续投按钮

@property (weak, nonatomic) IBOutlet UIView *chargeView;//充值

@property (weak, nonatomic) IBOutlet UIView *betHistoryIssueView; //开奖结果记录视图

@property (weak, nonatomic) IBOutlet UIButton *betHistoryButton; //我的历史投注
@property (weak, nonatomic) IBOutlet UIButton *musicBtn;//音乐开关

@property (weak, nonatomic) IBOutlet UICollectionView *betChipCollectionView; //下注列表

///一分快三游戏部分
@property (weak, nonatomic) IBOutlet UIImageView *shaiguImgView;

@property (weak, nonatomic) IBOutlet UIView *ballBgView;

///视图整体弹框动画
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *bet_bg1_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg2_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg3_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg4_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg5_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg6_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg7_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg8_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg9_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg10_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg11_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg12_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg13_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg14_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg15_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg16_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg17_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg18_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg19_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg20_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg21_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg22_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg23_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg24_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg25_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg26_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg27_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg28_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg29_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg30_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg31_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg32_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg33_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg34_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg35_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg36_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg37_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg38_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg39_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg40_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg41_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg42_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg43_view;
@property (weak, nonatomic) IBOutlet UIView *bet_bg44_view;

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

- (void)releaseView;



@end

