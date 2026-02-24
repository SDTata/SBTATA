//
//  IssueCollectionViewCell.h
//

#import <UIKit/UIKit.h>

@interface IssueCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage; // 背景图
@property (weak, nonatomic) IBOutlet UIImageView *foregroundImage; // 前景图
@property (weak, nonatomic) IBOutlet UIImageView *cardImage; // 前景图
@property (weak, nonatomic) IBOutlet UILabel *titile;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundImageLeadiingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundImageTrailingConstraint;

@property(nonatomic,assign)BOOL isOldType;
@property(nonatomic,assign)BOOL isSpareType;
-(void)setNumber:(NSString*)number lotteryType:(NSInteger)lotteryType isFullscreen:(BOOL)isFullscreen;
-(void)setNumber:(NSString*)number lotteryType:(NSInteger)lotteryType;

@end
