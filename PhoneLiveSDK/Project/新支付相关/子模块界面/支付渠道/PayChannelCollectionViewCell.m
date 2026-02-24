//
//  PayChannelCollectionViewCell.m
//

#import "PayChannelCollectionViewCell.h"

@implementation PayChannelCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelectedStatus:(BOOL)selected{
//    if(selected){
//        NSLog([NSString stringWithFormat:@"第%d设置选中",self.clickBtn.tag]);
//    }else{
//        NSLog([NSString stringWithFormat:@"第%d设置不选中",self.clickBtn.tag]);
//    }
    
//    self.clickBtn.layer.borderWidth = selected?0:1;
    self.clickBtn.selected = selected;
//    if(selected){
//        self.title.textColor = [UIColor colorWithRed:233/255.0 green:84/255.0 blue:103/255.0 alpha:1];
//    }else{
//        self.title.textColor = [UIColor colorWithRed:111/255.0 green:113/255.0 blue:120/255.0 alpha:1];
//    }
    
}

@end
