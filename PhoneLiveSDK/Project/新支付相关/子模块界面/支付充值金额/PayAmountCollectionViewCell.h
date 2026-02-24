//
//  PayAmountCollectionViewCell.h
//

#import <UIKit/UIKit.h>

@interface PayAmountCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightSubLabelConstraint;

@property (weak, nonatomic) IBOutlet UIButton *clickBtn;

- (void)setSelectedStatus:(BOOL)selected;
@end
