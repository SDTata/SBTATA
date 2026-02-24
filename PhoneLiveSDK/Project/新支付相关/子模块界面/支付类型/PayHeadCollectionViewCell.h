//
//  PayHeadCollectionViewCell.h
//

#import <UIKit/UIKit.h>

@interface PayHeadCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UIImageView *subLogo;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UIButton *clickBtn;

- (void)setSelectedStatus:(BOOL)selected;
@end
