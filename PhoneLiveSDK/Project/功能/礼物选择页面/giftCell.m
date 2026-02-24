//
//  giftCell.m
//  yunbaolive
//
//  Created by Boom on 2018/10/12.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "giftCell.h"

@implementation giftCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _giftTypeImg1.image = [ImageBundle imagewithBundleName:YZMsg(@"giftCell_haoIcon")];
    _giftTypeImg2.image = [ImageBundle imagewithBundleName:YZMsg(@"giftCell_hotIcon")];
    // Initialization code
}
-(void)setModel:(liwuModel *)model{
    _model = model;
    [self.giftIcon sd_setImageWithURL:[NSURL URLWithString:_model.imagePath] placeholderImage:nil];
    _giftNameL.text = _model.giftname;
    if (![_model isKindOfClass:[NSDictionary class]]) {
        NSString *currencyCoin = [YBToolClass getRateCurrency:_model.price showUnit:YES];
        _giftCoinL.text = [NSString stringWithFormat:@"%@",currencyCoin];
    }
    
    if ([_model.mark isEqual:@"1"]) {
        _giftTypeImg2.image = [ImageBundle imagewithBundleName:YZMsg(@"giftCell_hotIcon")];
    }else if ([_model.mark isEqual:@"2"]){
        _giftTypeImg2.image = [ImageBundle imagewithBundleName:YZMsg(@"giftCell_guardIcon")];
    }else{
        _giftTypeImg2.image = [UIImage new];
    }
    if ([_model.type isEqual:@"1"]) {
        _giftTypeImg1.hidden = NO;
    }else{
        _giftTypeImg1.hidden = YES;
    }

}
@end
