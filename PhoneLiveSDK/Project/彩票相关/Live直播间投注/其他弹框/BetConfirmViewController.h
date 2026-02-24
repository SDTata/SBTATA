//
//  ChipSwitchViewController.h
//

#import <UIKit/UIKit.h>
typedef void (^BetComplete)(NSInteger idx, NSUInteger num);

@interface BetConfirmViewController : UIViewController<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *betScale1Btn;
@property (weak, nonatomic) IBOutlet UIButton *betScale2Btn;
@property (weak, nonatomic) IBOutlet UIButton *betScale5Btn;
@property (weak, nonatomic) IBOutlet UIButton *betScale10Btn;
@property (weak, nonatomic) IBOutlet UIButton *betScale20Btn;
@property (weak, nonatomic) IBOutlet UILabel *lotteryInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *betMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *betCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel;
@property (weak, nonatomic) IBOutlet UIButton *betConfirmBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *betCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property(nonatomic,assign)BOOL isFromFollow;
@property (nonatomic,copy) BetComplete betBlock;

@property(nonatomic,assign)BOOL isShowTopList;

-(void)setOrderInfo:(NSDictionary *)dict;
@end

