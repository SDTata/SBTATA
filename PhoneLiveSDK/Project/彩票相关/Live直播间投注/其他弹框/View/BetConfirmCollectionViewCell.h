//
//  BetOptionCollectionViewCell.h
//

#import <UIKit/UIKit.h>

@interface BetConfirmCollectionViewCell : UICollectionViewCell

//@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *betWayLabel;
@property (weak, nonatomic) IBOutlet UILabel *betDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@property (weak, nonatomic) IBOutlet UILabel *betCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *betCountNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *betScaleLabel;
@property (weak, nonatomic) IBOutlet UILabel *betScaleNameLabel;

@end
