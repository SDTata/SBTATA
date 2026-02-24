//
//  PayTransferCollectionViewCell.h
//

#import <UIKit/UIKit.h>

@interface PayTransferCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *bankNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankOwnLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankGateLabel;

@property (weak, nonatomic) IBOutlet UIButton *bankNumBtn;
@property (weak, nonatomic) IBOutlet UIButton *bankOwnBtn;
@property (weak, nonatomic) IBOutlet UIButton *bankNameBtn;
@property (weak, nonatomic) IBOutlet UIButton *bankGateBtn;
@property (weak, nonatomic) IBOutlet UIButton *clickBtn;
@property (weak, nonatomic) IBOutlet UIImageView *subIcon;

@property (weak, nonatomic) IBOutlet UILabel *bankNumTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankUserNameTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankNameTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankPlaceTitleLabel;

- (void)setSelectedStatus:(BOOL)selected;
@end
