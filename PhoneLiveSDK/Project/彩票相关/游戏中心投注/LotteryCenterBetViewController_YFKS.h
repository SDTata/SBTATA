//
//  LotteryBetViewController_YFKS.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "EqualSpaceFlowLayoutEvolve.h"
#import "BetDefineNotification.h"
#import "BetBubbleView.h"

@interface LotteryCenterBetViewController_YFKS : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

///公共部分处理

@property (weak, nonatomic) IBOutlet UICollectionView *openResultCollection; //开奖结果

@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel; //用户余额

@property (weak, nonatomic) IBOutlet UIButton *continueBtn; //续投按钮

@property (weak, nonatomic) IBOutlet UIView *chargeView;//充值

@property (weak, nonatomic) IBOutlet UIView *betHistoryIssueView; //开奖结果记录视图

@property (weak, nonatomic) IBOutlet UIButton *betHistoryButton; //我的历史投注
@property (weak, nonatomic) IBOutlet UIButton *musicBtn;//音乐开关

@property (weak, nonatomic) IBOutlet UICollectionView *betChipCollectionView; //下注列表
@property (weak, nonatomic) IBOutlet UIView *betBgView;
///一分快三游戏部分
@property (weak, nonatomic) IBOutlet UIImageView *shaiguImgView;
@property (weak, nonatomic) IBOutlet UIView *bet_big_View;
@property (weak, nonatomic) IBOutlet UIView *bet_small_View;
@property (weak, nonatomic) IBOutlet UIView *bet_single_View;
@property (weak, nonatomic) IBOutlet UIView *bet_double_View;
@property (weak, nonatomic) IBOutlet UIView *bet_bao1_View;
@property (weak, nonatomic) IBOutlet UIView *bet_bao6_View;
@property (weak, nonatomic) IBOutlet UIView *bet_bao2_View;
@property (weak, nonatomic) IBOutlet UIView *bet_bao3_View;
@property (weak, nonatomic) IBOutlet UIView *bet_bao4_View;
@property (weak, nonatomic) IBOutlet UIView *bet_bao5_View;
@property (weak, nonatomic) IBOutlet UIView *bet_baozi_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum4_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum5_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum6_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum7_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum8_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum9_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum10_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum11_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum12_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum13_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum14_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum15_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum16_View;
@property (weak, nonatomic) IBOutlet UIView *bet_sum17_View;
@property (weak, nonatomic) IBOutlet UIView *bet_dui1_View;
@property (weak, nonatomic) IBOutlet UIView *bet_dui2_View;
@property (weak, nonatomic) IBOutlet UIView *bet_dui3_View;
@property (weak, nonatomic) IBOutlet UIView *bet_dui4_View;
@property (weak, nonatomic) IBOutlet UIView *bet_dui5_View;
@property (weak, nonatomic) IBOutlet UIView *bet_dui6_View;
@property (weak, nonatomic) IBOutlet UIView *bet_dian1_View;
@property (weak, nonatomic) IBOutlet UIView *bet_dian2_View;
@property (weak, nonatomic) IBOutlet UIView *bet_dian3_View;
@property (weak, nonatomic) IBOutlet UIView *bet_dian4_View;
@property (weak, nonatomic) IBOutlet UIView *bet_dian5_View;
@property (weak, nonatomic) IBOutlet UIView *bet_dian6_View;


///视图整体弹框动画
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

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

