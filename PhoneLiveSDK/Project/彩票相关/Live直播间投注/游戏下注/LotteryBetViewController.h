//
//  LotteryBetViewController.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "EqualSpaceFlowLayoutEvolve.h"

@interface LotteryBetViewController : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property (assign, nonatomic)  BOOL isExit;

@property (strong, nonatomic) NSString *curIssue; // 当前期号

@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *lotteryName;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *wayBtnView;
@property (weak, nonatomic) IBOutlet UICollectionView *rightCollection;
@property (weak, nonatomic) IBOutlet UICollectionView *openResultCollection;
@property (weak, nonatomic) IBOutlet UICollectionView *betChipCollectionView;
@property (weak, nonatomic) IBOutlet UIView *chartView; //走势图
@property (weak, nonatomic) IBOutlet UIView *toolBg;  // 顶部按钮区域

@property (weak, nonatomic) IBOutlet UICollectionView *openResultList; //开奖历史
@property (weak, nonatomic) IBOutlet UICollectionView *betHistoryList; // 投注记录

@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel;
@property (weak, nonatomic) IBOutlet UIButton *chargeBtn;
@property (weak, nonatomic) IBOutlet UIButton *betBtn;

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *noView;
@property (weak, nonatomic) IBOutlet UILabel *noLab;

//撩一下 游戏 礼物红包等
@property (weak, nonatomic) IBOutlet UIView *toolBar;

@property (weak, nonatomic) IBOutlet UIButton *KeyBTN;
@property (weak, nonatomic) IBOutlet UIButton *returnCancle;

@property(weak)id<lotteryBetViewDelegate>lotteryDelegate;

- (void)exitView;
- (void)setLotteryType:(NSInteger)lotteryType;
- (void)appearToolBar;

// 來自主播開播
@property (assign, nonatomic) BOOL isFromLiveBroadcast;
@end

