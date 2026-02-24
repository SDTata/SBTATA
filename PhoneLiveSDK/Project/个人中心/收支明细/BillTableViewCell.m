//
//  BillTableViewCell.m
//  phonelive2
//
//  Created by 400 on 2021/6/26.
//  Copyright © 2021 toby. All rights reserved.
//

#import "BillTableViewCell.h"
@implementation BillTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDicContent:(NSDictionary *)dicContent
{
    _dicContent = dicContent;
    _title1.text = _dicContent[@"desc"];
    _subtitle1.text = _dicContent[@"addtime"];
    NSString *nickNameto = _dicContent[@"tonickname"];
    
    if (nickNameto && nickNameto.length>0) {
        _title2.text = YZMsg(@"BillVC_Anthor_name");
        _subtitle2.text = nickNameto;
    }else{
        _title2.text = @"";
        _subtitle2.text = @"";
    }
    
    NSString *totalcoin = [NSString stringWithFormat:@"%@", _dicContent[@"totalcoin"]];
    totalcoin = [totalcoin stringByReplacingOccurrencesOfString:@"," withString:@""];
    _title3.text = [YBToolClass getRateCurrency:totalcoin showUnit:YES];
    
    NSString *after_coin = [NSString stringWithFormat:@"%@", _dicContent[@"after_coin"]];
    after_coin = [after_coin stringByReplacingOccurrencesOfString:@"," withString:@""];
    _subtitle3.text = [YBToolClass getRateCurrency:after_coin showUnit:YES];
    
}

@end
