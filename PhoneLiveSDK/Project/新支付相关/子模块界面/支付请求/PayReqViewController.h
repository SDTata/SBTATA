//
//  PayReqViewController.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "PayBaseViewController.h"

@interface PayReqViewController : PayBaseViewController

@property (weak, nonatomic) IBOutlet UICollectionView *gamesCollection;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *reqBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIView *psdView;
@property (weak, nonatomic) IBOutlet UILabel *psdNameLab;
@property (strong, nonatomic) UITextField *psdTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customAmountHeight;

-(void)exitView;
-(void)setReqKey:(NSArray *)arr;
-(void)setBalanceQuota:(NSString*)quota;
@end

