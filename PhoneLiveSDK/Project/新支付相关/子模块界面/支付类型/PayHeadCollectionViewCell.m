//
//  PayHeadCollectionViewCell.m
//

#import "PayHeadCollectionViewCell.h"

@implementation PayHeadCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelectedStatus:(BOOL)selected{
//    if(selected){doSelect
//        NSLog([NSString stringWithFormat:@"第%d设置选中",self.clickBtn.tag]);
//    }else{
//        NSLog([NSString stringWithFormat:@"第%d设置不选中",self.clickBtn.tag]);
//    }
    
//    self.clickBtn.layer.borderWidth = selected?0:1;
    self.clickBtn.selected = selected;
}

@end
