//
//  OpenAwardViewController.h
//

#import <UIKit/UIKit.h>
#import "EqualSpaceFlowLayoutEvolve.h"

@interface OpenAwardViewController : UIViewController<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

//@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *lotteryName;
@property (weak, nonatomic) IBOutlet UILabel *lotteryIssue;
@property (weak, nonatomic) IBOutlet UICollectionView *openResultCollection;

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *blueWinImgView;
@property (weak, nonatomic) IBOutlet UIImageView *redWinImgView;
@property (weak, nonatomic) IBOutlet UILabel *leftNiuLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightNiuLabel;


@property (weak, nonatomic) IBOutlet UILabel *leftBlueLabel;

@property (weak, nonatomic) IBOutlet UILabel *rightRedLabel;
@property(nonatomic,strong,readonly)NSString *issueStr;
- (void)exitView;
- (void)setOpenAwardInfo:(NSDictionary *)dict;
@end

