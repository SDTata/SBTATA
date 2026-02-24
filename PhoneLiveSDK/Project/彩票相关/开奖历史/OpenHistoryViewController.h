//
//  OpenHistoryViewController.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
typedef void (^Callback)(void);

@interface OpenHistoryViewController : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *historyCollection;

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic,copy) Callback closeCallback;

- (void)exitView;
- (void)setLotteryType:(NSInteger)lotteryType;
@end

