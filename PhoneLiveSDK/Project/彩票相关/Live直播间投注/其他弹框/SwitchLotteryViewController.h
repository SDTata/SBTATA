//
//  SwitchLotteryViewController.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "BetDefineNotification.h"



@interface SwitchLotteryViewController : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>


@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, assign) NSInteger gameTag;


@property (nonatomic,assign)BOOL isFromGameCenter;
@property(weak)id<lotteryBetViewDelegate>lotteryDelegate;

//-(void)exitView;
-(void)getPoolDataInfo;
-(void)lotteryCancless;
- (void)doExitView;
@end

