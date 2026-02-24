//
//  PayTransferCollectionViewCell.m
//

#import "PayTransferCollectionViewCell.h"

@implementation PayTransferCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.bankNumBtn setTitle:YZMsg(@"publictool_copy") forState:UIControlStateNormal];
    self.bankNumBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.bankNumBtn.titleLabel.minimumScaleFactor = 0.5;
    [self.bankOwnBtn setTitle:YZMsg(@"publictool_copy") forState:UIControlStateNormal];
    self.bankOwnBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.bankOwnBtn.titleLabel.minimumScaleFactor = 0.5;
    [self.bankNameBtn setTitle:YZMsg(@"publictool_copy") forState:UIControlStateNormal];
    self.bankNameBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.bankNameBtn.titleLabel.minimumScaleFactor = 0.5;
    [self.bankGateBtn setTitle:YZMsg(@"publictool_copy") forState:UIControlStateNormal];
    self.bankGateBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.bankGateBtn.titleLabel.minimumScaleFactor = 0.5;
    
    self.bankNumTitleLabel.text = YZMsg(@"Transfer_bankNumberTitle");
    self.bankUserNameTitleLabel.text = YZMsg(@"Transfer_bankUserNameTitle");
    self.bankNameTitleLabel.text = YZMsg(@"Transfer_bankNameTitle");
    self.bankPlaceTitleLabel.text = YZMsg(@"Transfer_bankPlaceTitle");
    
    [self.bankNumBtn addTarget:self action:@selector(doCopyBankNum:) forControlEvents:UIControlEventTouchUpInside];
    [self.bankOwnBtn addTarget:self action:@selector(doCopyBankOwn:) forControlEvents:UIControlEventTouchUpInside];
    [self.bankNameBtn addTarget:self action:@selector(doCopyBankName:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)doCopyBankNum:(UIButton *)sender {
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    paste.string = self.bankNumLabel.text;
    [MBProgressHUD showSuccess:YZMsg(@"publictool_copy_success")];
}
- (void)doCopyBankOwn:(UIButton *)sender {
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    paste.string = self.bankOwnLabel.text;
    [MBProgressHUD showSuccess:YZMsg(@"publictool_copy_success")];
}
- (void)doCopyBankName:(UIButton *)sender {
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    paste.string = self.bankNameLabel.text;
    [MBProgressHUD showSuccess:YZMsg(@"publictool_copy_success")];
}

- (void)setSelectedStatus:(BOOL)selected{
//    if(selected){
//        NSLog([NSString stringWithFormat:@"第%d设置选中",self.clickBtn.tag]);
//    }else{
//        NSLog([NSString stringWithFormat:@"第%d设置不选中",self.clickBtn.tag]);
//    }
    
    self.clickBtn.layer.borderWidth = selected?0:2;
    self.subIcon.hidden = !selected;
    
}

@end
