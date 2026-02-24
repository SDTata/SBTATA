//
//  TopTodayCell.m
//  phonelive
//
//  Created by 400 on 2020/7/28.
//  Copyright © 2020 toby. All rights reserved.
//

#import "TopTodayCell.h"

@implementation TopTodayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImgView.layer.cornerRadius = 25;
    self.avatarImgView.layer.masksToBounds = YES;
    
    // Initialization code
}

-(void)setModel:(TopTodayModel *)model
{
    _model = model;
    UIColor *color = [UIColor lightGrayColor];
    switch (model.index) {
        case 0:
            color = [UIColor redColor];
            break;
        case 1:
            color = [UIColor systemPinkColor];
            break;
        case 2:
            color = [UIColor lightGrayColor];
            break;
        case 3:
            color = [UIColor grayColor];
            break;
        default:
            break;
    }
    self.leveLabel.textColor = color;
    self.leveLabel.text = minnum(model.index+1);
    
    if (model.photo!=nil&&model.photo.length>0) {
        [self.avatarImgView sd_setImageWithURL:[NSURL URLWithString:model.photo] placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
    }
    self.nickNameLabel.text = model.name;
    
    if (model && model.coin.length>0 && [model.coin doubleValue]>0.01) {
        NSString *currencyCoin = [YBToolClass getRateCurrency:minstr(model.coin) showUnit:YES];
        self.giftNumLabel.text = [NSString stringWithFormat:YZMsg(@"RankCell_Title_scroe%@"),currencyCoin];
    }else{
        self.giftNumLabel.text = @"";
    }
}

- (void)updateIsFirst:(BOOL)isFirst {
    if (isFirst) {
        self.giftNumLabel.text = YZMsg(@"Top rank");
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
