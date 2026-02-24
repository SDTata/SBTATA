#import <UIKit/UIKit.h>
/******* 分享类头文件 ******/
//#import <ShareSDK/ShareSDK.h>
//#import "SBJson4.h"
#import "MBProgressHUD.h"
#import "hotModel.h"
/*******  分享 头文件结束 *********/
@interface fenXiangView : UIView
@property(nonatomic,strong)hotModel *zhuboModel;
-(void)GetModel:(hotModel *)model;
- (void)show;
@end


