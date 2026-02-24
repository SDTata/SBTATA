//
//  LobbyBetConfirmCollectionViewCell.m
//

#import "LobbyBetConfirmCollectionViewCell.h"

@implementation LobbyBetConfirmCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.betCountNameLabel.text = YZMsg(@"LobbyBetCell_Unit_Count");
    
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
