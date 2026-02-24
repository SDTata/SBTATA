//
//  PayInsteadCollectionViewCell.m
//
#import <WebKit/WebKit.h>​​​​​​​
#import "PayInsteadCollectionViewCell.h"

@implementation PayInsteadCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.edutitleLable.text= YZMsg(@"PayInsteadCell_canPayamount");
    self.QQLabel.text =YZMsg(@"PayInsteadCell_contactNow");
    self.weChatLabel.text = YZMsg(@"PayInsteadCell_contactNow");
    self.aliPayLabel.text = YZMsg(@"PayInsteadCell_contactNow");
    
    
    [self.QQBtn addTarget:self action:@selector(doCallQQ:) forControlEvents:UIControlEventTouchUpInside];
    [self.weChatBtn addTarget:self action:@selector(doCallweChat:) forControlEvents:UIControlEventTouchUpInside];
    [self.aliPayBtn addTarget:self action:@selector(doCallAlipay:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)doCallQQ:(UIButton *)sender {
    // 判断手机是否安装QQ
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
        NSLog(@"install--");
    }else{
        [MBProgressHUD showError:YZMsg(@"PayInsteadCell_installQQ")];
        return;
    }
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    paste.string = self.QQ;
    
    UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"PayInsteadCell_desTitle") message:YZMsg(@"PayInsteadCell_desQQDetail") preferredStyle:UIAlertControllerStyleAlert];
    WeakSelf
    UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        // 提供uin, 你所要联系人的QQ号码
        NSString *qqstr = [NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web",self.QQ];
        NSURL *url = [NSURL URLWithString:qqstr];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
    }];
    [alertC addAction:suerA];
    if(currentVC.presentedViewController == nil){
        [currentVC presentViewController:alertC animated:YES completion:nil];
    }
    

}
- (void)doCallweChat:(UIButton *)sender {
    // 判断手机是否安装微信
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
        NSLog(@"install--");
    }else{
        [MBProgressHUD showError:YZMsg(@"PayInsteadCell_installWechat")];
        return;
    }
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    paste.string = self.weChat;
    UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"PayInsteadCell_desTitle") message:YZMsg(@"PayInsteadCell_desWechatDetail") preferredStyle:UIAlertControllerStyleAlert];
    WeakSelf
    UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSString *str =@"weixin://qr/JnXv90fE6hqVrQOU9yA0";
        NSURL *url = [NSURL URLWithString:str];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
    }];
    [alertC addAction:suerA];
    if (currentVC.presentedViewController == nil){
        [currentVC presentViewController:alertC animated:YES completion:nil];
    }
}
- (void)doCallAlipay:(UIButton *)sender {
    // 判断手机是否安装微信
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipayqr://"]]) {
        NSLog(@"install--");
    }else{
        [MBProgressHUD showError:YZMsg(@"PayInsteadCell_installAlipay")];
        return;
    }
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    paste.string = self.alipay;
    UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"PayInsteadCell_desTitle") message:YZMsg(@"PayInsteadCell_desAlipayDetail") preferredStyle:UIAlertControllerStyleAlert];
    WeakSelf
    UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSString *str =@"alipayqr://platformapi/startapp?saId=20000116";
        NSURL *url = [NSURL URLWithString:str];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
    }];
    [alertC addAction:suerA];
    if (currentVC.presentedViewController == nil) {
        [currentVC presentViewController:alertC animated:YES completion:nil];
    }
    
}

- (void)setBtnEnable:(BOOL)enable{
//    self.QQBtn.userInteractionEnabled = enable;
//    self.weChatBtn.userInteractionEnabled = enable;
//    self.aliPayBtn.userInteractionEnabled = enable;
    [self.QQBtn setEnabled:enable];
    [self.weChatBtn setEnabled:enable];
    [self.aliPayBtn setEnabled:enable];
    
    [self.QQLabel setEnabled:enable];
    [self.weChatLabel setEnabled:enable];
    [self.aliPayLabel setEnabled:enable];
}

@end
