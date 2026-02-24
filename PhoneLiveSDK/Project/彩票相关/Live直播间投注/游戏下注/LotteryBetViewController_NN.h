//
//  LotteryBetViewController_NN.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "EqualSpaceFlowLayoutEvolve.h"

@interface LotteryBetViewController_NN : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
@property (assign, nonatomic)  BOOL isExit;

@property (strong, nonatomic) NSString *curIssue; // 当前期号

@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *lotteryName;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *wayBtnView;
@property (weak, nonatomic) IBOutlet UICollectionView *rightCollection;
@property (weak, nonatomic) IBOutlet UICollectionView *betChipCollectionView;

// NN start
@property (weak, nonatomic) IBOutlet UILabel *blueResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *redResultLabel;
// NN end

@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel;
@property (weak, nonatomic) IBOutlet UIButton *chargeBtn;
@property (weak, nonatomic) IBOutlet UIButton *betBtn;


@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *toolBg;
@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UICollectionView *openResultList;
@property (weak, nonatomic) IBOutlet UICollectionView *betHistoryList;
@property (weak, nonatomic) IBOutlet UIView *noView;
@property (weak, nonatomic) IBOutlet UILabel *noLab;

//撩一下 游戏 礼物红包等
@property (weak, nonatomic) IBOutlet UIView *toolBar;

@property (weak, nonatomic) IBOutlet UIButton *KeyBTN;
@property (weak, nonatomic) IBOutlet UIButton *returnCancle;

@property (weak, nonatomic) IBOutlet UIImageView *blue1;
@property (weak, nonatomic) IBOutlet UIImageView *blue2;
@property (weak, nonatomic) IBOutlet UIImageView *blue3;
@property (weak, nonatomic) IBOutlet UIImageView *blue4;
@property (weak, nonatomic) IBOutlet UIImageView *blue5;
@property (weak, nonatomic) IBOutlet UIImageView *red1;
@property (weak, nonatomic) IBOutlet UIImageView *red2;
@property (weak, nonatomic) IBOutlet UIImageView *red3;
@property (weak, nonatomic) IBOutlet UIImageView *red4;
@property (weak, nonatomic) IBOutlet UIImageView *red5;

@property(weak)id<lotteryBetViewDelegate>lotteryDelegate;

- (void)exitView;
- (void)setLotteryType:(NSInteger)lotteryType;
- (void)appearToolBar;

// 來自主播開播
@property (assign, nonatomic) BOOL isFromLiveBroadcast;
@end

