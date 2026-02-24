//
//  LobbyBetConfirmViewController.h
//

#import <UIKit/UIKit.h>
typedef void (^BetComplete)(NSInteger idx, NSUInteger num);

@interface LobbyBetConfirmViewController : UIViewController<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIButton *emptyBtn;
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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;

@property (nonatomic,copy) BetComplete betBlock;

-(void)setOrderInfo:(NSDictionary *)dict betScale:(NSInteger)betScale;
@end

