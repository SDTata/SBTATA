//
//  PayHeadViewController.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "PayBaseViewController.h"

@interface PayHeadViewController : PayBaseViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *gamesCollection;

@property (weak, nonatomic) IBOutlet UIView *contentView;



-(void)exitView;
-(void)setChargeData:(NSArray *)dict;
@end

