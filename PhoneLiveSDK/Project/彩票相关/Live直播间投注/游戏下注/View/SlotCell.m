//
//  SlotCell.m
//  SlotDemo
//
//  Created by test on 2021/12/29.
//

#import "SlotCell.h"
@interface SlotCell()
@property (weak, nonatomic) IBOutlet UIImageView *iv_icon;
@property (weak, nonatomic) IBOutlet UILabel *lb_tag;

@end
@implementation SlotCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
- (void)setData:(NSString *)data{
    _data = data;
    self.iv_icon.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lb_showimg_%@",data]];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
