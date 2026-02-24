//
//  PayChannelCollectionViewCell.h
//

#import <UIKit/UIKit.h>

@interface PayChannelCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *dicsontBG;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftImgV;

@property (weak, nonatomic) IBOutlet UIButton *clickBtn;

- (void)setSelectedStatus:(BOOL)selected;
@end
