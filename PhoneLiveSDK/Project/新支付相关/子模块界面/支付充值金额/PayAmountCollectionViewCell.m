//
//  PayAmountCollectionViewCell.m
//

#import "PayAmountCollectionViewCell.h"

@implementation PayAmountCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.clickBtn.backgroundColor = RGB(243, 239, 248);
    self.title.textColor = [UIColor blackColor];
    UIImage *imgResize = [[ImageBundle imagewithBundleName:@"zf_xz1"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 25, 25) resizingMode:UIImageResizingModeStretch];
    [self.clickBtn  setBackgroundImage:imgResize forState:UIControlStateSelected];
    
}



- (void)setSelectedStatus:(BOOL)selected{

    self.clickBtn.selected = selected;
}

@end
