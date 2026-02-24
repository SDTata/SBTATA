//
//  CommonCollectionViewController2.h
//

#import <UIKit/UIKit.h>
#import "FLLayout.h"
#import "EqualSpaceFlowLayoutEvolve.h"

@interface CommonCollectionViewController2 : UIViewController<FLLayoutDatasource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>

typedef NS_ENUM(NSInteger,CollectionShowMode){
    CollectionShowMode_NOTITLE,    // 单页面 没有头视图
    CollectionShowMode_NORMAL,     // 多页面 没有头视图
    CollectionShowMode_SINGLE_PAGE // 单页面。但是有多个头视图
};

@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *lotteryName;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *wayBtnView;
@property (weak, nonatomic) IBOutlet UICollectionView *rightCollection;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;

@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel;
@property (weak, nonatomic) IBOutlet UIButton *chargeBtn;
@property (weak, nonatomic) IBOutlet UIButton *betBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchChipBtn;
@property (weak, nonatomic) IBOutlet UIButton *historyIssueBtn;
@property (weak, nonatomic) IBOutlet UIButton *betHistoryIssueBtn;

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

//
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionBottomSpace;

- (void)exitView;
- (void)setLotteryType:(NSInteger)lotteryType;
- (void)setShowMode:(CollectionShowMode)_showMode;
- (void)setLotterySectionOptions:(NSArray *)options;
- (void)setMaxZhu:(NSInteger)_maxZhu;
- (NSMutableArray *)getSelectedOptions;
- (void)clearSelectedStatus;
- (void)randomSelected:(NSInteger)minZhu;

- (void) setBottomSpace:(CGFloat) height;
@end
