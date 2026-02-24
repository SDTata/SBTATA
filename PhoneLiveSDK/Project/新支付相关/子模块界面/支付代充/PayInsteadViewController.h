//
//  PayInsteadViewController.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "PayBaseViewController.h"

@interface PayInsteadViewController : PayBaseViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *gamesCollection;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *tipView;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UIButton *accountCopyBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customAmountHeight;


-(void)exitView;
//-(void)setData:(NSArray *)dict;
@end

