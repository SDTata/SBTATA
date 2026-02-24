//
//  BetOptionCollectionViewCell.m
//

#import "BetConfirmCollectionViewCell.h"

@implementation BetConfirmCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.betCountNameLabel.text = YZMsg(@"LobbyBetCell_Unit_Count");
//    self.betScaleNameLabel.text = YZMsg(@"BetCell_double");
    [self.removeButton setTitle:YZMsg(@"BetCell_remove") forState:UIControlStateNormal];
    self.removeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.removeButton.titleLabel.minimumScaleFactor = 0.4;
    // Initialization code
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
//    if(selected){
//        self.imageView.backgroundColor=[UIColor redColor];
//        self.titile.textColor=[UIColor whiteColor];
//    }else{
//        self.imageView.backgroundColor=[UIColor whiteColor];
//        self.titile.textColor=[UIColor redColor];
//    }
    
    // Configure the view for the selected state
}

@end
