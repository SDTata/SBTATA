//
//  IssueCollectionViewCell2.h
//

#import <UIKit/UIKit.h>

@interface IssueCollectionViewCell2 : UICollectionViewCell

//@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage; // 背景图
//@property (weak, nonatomic) IBOutlet UIImageView *foregroundImage; // 前景图
//@property (weak, nonatomic) IBOutlet UIImageView *cardImage; // 前景图
@property (weak, nonatomic) IBOutlet UIImageView *result1Imageview;
@property (weak, nonatomic) IBOutlet UILabel *titile;
@property (weak, nonatomic) IBOutlet UILabel *extendLabel;

-(void)setNumber:(NSString*)number lotteryType:(NSInteger)lotteryType extinfo:(id)extinfo;
-(void)setAnalysis:(NSString *)resultStr;

@end
