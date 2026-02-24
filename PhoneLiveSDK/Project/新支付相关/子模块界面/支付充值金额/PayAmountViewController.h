//
//  PayAmountViewController.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "PayBaseViewController.h"

@interface PayAmountViewController : PayBaseViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UITextFieldDelegate,UICollectionViewDataSource>

@property(nonatomic,assign)NSInteger currentViewType;

@property (weak, nonatomic) IBOutlet UICollectionView *gamesCollection;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountRangeLabel;
@property (weak, nonatomic) IBOutlet UITextField *amountValueTextField;
@property (weak, nonatomic) IBOutlet UIView *amountView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customAmountHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discountViewHeight;
@property (weak, nonatomic) IBOutlet UIView *discountView;
@property (weak, nonatomic) IBOutlet UILabel *discountDescLabel;
@property (weak, nonatomic) IBOutlet UIView *discountCalcView;
@property (weak, nonatomic) IBOutlet UILabel *discountCalcLabel;
@property (weak, nonatomic) IBOutlet UILabel *vippayCoinLab;
@property (weak, nonatomic) IBOutlet UILabel *vippayNameLab;


-(void)exitView;
//-(void)setData:(NSArray *)dict;

@end

