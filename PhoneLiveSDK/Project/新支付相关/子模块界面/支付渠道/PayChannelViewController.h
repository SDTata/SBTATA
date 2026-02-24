//
//  PayChannelViewController.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "PayBaseViewController.h"

@interface PayChannelViewController : PayBaseViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *gamesCollection;

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCoinLab;
@property (weak, nonatomic) IBOutlet UILabel *coinNamelab;
@property (strong, nonatomic) NSDictionary *channelData;
-(void)exitView;
-(void)setData:(NSArray *)dict;
@end

