//
//  LotteryBetViewController_YFKS.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "EqualSpaceFlowLayoutEvolve.h"
#import "BetDefineNotification.h"

@interface LotteryBetViewController_LB : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

///公共部分处理

@property (assign, nonatomic)  BOOL isExit;
@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel; //用户余额fopenResultCollection
@property (weak, nonatomic) IBOutlet UIButton *startBtn; //start按钮
@property (weak, nonatomic) IBOutlet UIButton *autoBtn; //auto按钮
@property (weak, nonatomic) IBOutlet UIView *chargeView;//充值

@property (weak, nonatomic) IBOutlet UILabel *lb_totalCount; //底部total总数
@property (weak, nonatomic) IBOutlet UILabel *lb_winCount; //底部win数
@property (weak, nonatomic) IBOutlet UILabel *lb_lineCount;// line数
@property (weak, nonatomic) IBOutlet UILabel *lb_betCount;  //下注数
@property (weak, nonatomic) IBOutlet UIButton *btn_lineDes;//line减
@property (weak, nonatomic) IBOutlet UIButton *btn_lineAdd;//line增
@property (weak, nonatomic) IBOutlet UIButton *btn_betDes;//bet减
@property (weak, nonatomic) IBOutlet UIButton *btn_betAdd;//bet增
@property (weak, nonatomic) IBOutlet UIView *v_slotContainer;//slot父视图
@property (weak, nonatomic) IBOutlet UIView *popBgView;
@property (weak, nonatomic) IBOutlet UIImageView *freeBgView;
@property (weak, nonatomic) IBOutlet UILabel *freeTimesLab;
@property (weak, nonatomic) IBOutlet UILabel *poolLab;

@property (strong, nonatomic)  UIButton *musicBtn;//音乐开关
@property (strong, nonatomic)  UIButton *betHistoryButton;//投注历史
@property (weak, nonatomic) IBOutlet UIView *toolBg;
@property (weak, nonatomic) IBOutlet UICollectionView *betHistoryList;

//撩一下 游戏 礼物红包等
@property (weak, nonatomic) IBOutlet UIView *toolBar;

//@property (weak, nonatomic) IBOutlet UICollectionView *betChipCollectionView; //下注列表

///视图整体弹框动画
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *KeyBTN;
@property (weak, nonatomic) IBOutlet UIButton *returnCancle;

@property(weak)id<lotteryBetViewDelegate>lotteryDelegate;

- (void)exitView;
- (void)setLotteryType:(NSInteger)lotteryType;
- (void)getPoolDataInfo;
- (void)appearToolBar;

// 來自主播開播
@property (assign, nonatomic) BOOL isFromLiveBroadcast;
@end

