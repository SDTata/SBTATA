//
//  LobbyOpenHistoryViewController.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"

@interface LobbyOpenHistoryViewController : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *historyCollection;

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *switchTypeView;

- (void)exitView;
- (void)setLotteryType:(NSInteger)lotteryType;
@end

