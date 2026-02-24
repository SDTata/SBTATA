//
//  BetOptionCollectionViewCell.h
//

#import <UIKit/UIKit.h>

@interface BetOptionCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titile;
@property (weak, nonatomic) IBOutlet UILabel *rate;
@property (weak, nonatomic) IBOutlet UIButton *tipBtn;
@property (nonatomic, weak) NSString *way;
@end
