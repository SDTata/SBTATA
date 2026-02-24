//
//  BetOptionCollectionViewCell2.h
//

#import <UIKit/UIKit.h>

@interface BetOptionCollectionViewCell2 : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *result1Imageview;
@property (weak, nonatomic) IBOutlet UILabel *titile;
@property (weak, nonatomic) IBOutlet UILabel *rate;
@property (weak, nonatomic) IBOutlet UIButton *tipBtn;
@property (nonatomic, weak) NSString *way;
@property (nonatomic, weak) NSString *type;

- (void)setupDisplay;
- (void) setText:(NSString *)text;
- (void)setNumber:(NSString*)number lotteryType:(NSInteger)lotteryType;
@end
