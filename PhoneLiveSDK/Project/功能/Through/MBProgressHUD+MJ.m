
#import "MBProgressHUD+MJ.h"

@implementation MBProgressHUD (MJ)
#pragma mark 显示信息
+ (MBProgressHUD *)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow ;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    hud.label.adjustsFontSizeToFitWidth = YES;
    hud.label.minimumScaleFactor = 0.5;
    hud.label.numberOfLines = 2;
    // 设置图片
    
    hud.customView = [[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;

    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:1];
    return hud;
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (MBProgressHUD *)showSuccess:(NSString *)success toView:(UIView *)view
{
    return [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view =  [UIApplication sharedApplication].keyWindow ;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    hud.label.adjustsFontSizeToFitWidth = YES;
    hud.label.minimumScaleFactor = 0.5;
    hud.label.numberOfLines = 2;
    // YES代表需要蒙版效果
    hud.dimBackground = NO;
    
    [hud hideAnimated:YES afterDelay:5];
    
    return hud;
}
+ (void)showSuccess:(NSString *)success
{
    [self hideHUD];
    [self showSuccess:success toView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showError:(NSString *)error
{
    [self hideHUD];
//    [self showError:error toView:[UIApplication sharedApplication].keyWindow];
    [self showError:error withView:nil];
}
+ (void)showError:(NSString *)error withView:(UIView *)view{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = error;
    hud.label.adjustsFontSizeToFitWidth = YES;
    hud.label.minimumScaleFactor = 0.5;
    hud.label.numberOfLines = 2;
    hud.label.font = [UIFont systemFontOfSize:13];
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = [UIColor blackColor];
    hud.bezelView.alpha = 1;
    hud.userInteractionEnabled = NO;
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2.5];
}
+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:[UIApplication sharedApplication].keyWindow];
}
+ (void)hideHUDForView:(UIView *)view
{
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showBottomMessage:(NSString *)message {
    [self hideHUD];
    MBProgressHUD *hud = [self showSuccess:message toView:[UIApplication sharedApplication].keyWindow];
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(0.f, VK_SCREEN_H/3);
    hud.margin = 10;
    hud.bezelView.color = [UIColor blackColor];
    hud.label.numberOfLines = 0;
    hud.label.textColor = UIColor.whiteColor;
}

@end
