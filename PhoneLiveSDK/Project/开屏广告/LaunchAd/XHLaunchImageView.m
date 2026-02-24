//
//  XHLaunchImageView.m
//  XHLaunchAdExample
//
//  Created by zhuxiaohui on 2016/6/28.
//  Copyright © 2016年 it7090.com. All rights reserved.
//  代码地址:https://github.com/CoderZhuXH/XHLaunchAd

#import "XHLaunchImageView.h"
#import "XHLaunchAdConst.h"


@interface XHLaunchImageView ()

@end

@implementation XHLaunchImageView
#pragma mark - private
- (instancetype)initWithSourceType:(SourceType)sourceType{
    self = [super init];
    if (self) {
        id ddd = [UIApplication sharedApplication].keyWindow;
        if (ddd == nil) {
            self.frame = [[UIScreen mainScreen] bounds];
        }else{
            self.frame = [UIApplication sharedApplication].keyWindow.bounds;
        }
       
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.contentMode = UIViewContentModeScaleAspectFill;
        switch (sourceType) {
            case SourceTypeLaunchImage:{
                self.image = [self imageFromLaunchImage];
            }
                break;
            case SourceTypeLaunchScreen:{
                self.image = [self imageFromLaunchScreen];
            }
                break;
            default:
                break;
        }
    }
    return self;
}

-(UIImage *)imageFromLaunchImage{
    UIImage *imageP = [self launchImageWithType:@"Portrait"];
    if(imageP) return imageP;
    UIImage *imageL = [self launchImageWithType:@"Landscape"];
    if(imageL)  return imageL;
    XHLaunchAdLog(@"获取LaunchImage失败!请检查是否添加启动图,或者规格是否有误.");
    return nil;
}

-(UIImage *)imageFromLaunchScreen{
    NSString *UILaunchStoryboardName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchStoryboardName"];
    if(UILaunchStoryboardName == nil){
        XHLaunchAdLog(@"从 LaunchScreen 中获取启动图失败!");
        return nil;
    }
    UIViewController *LaunchScreenSb = [[UIStoryboard storyboardWithName:UILaunchStoryboardName bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    if(LaunchScreenSb){
        UIView * view = LaunchScreenSb.view;
        if (view.subviews.count>0) {
            UIImage *image = ((UIImageView*)view.subviews.firstObject).image;
            self.contentMode =  ((UIImageView*)view.subviews.firstObject).contentMode;
            return image;
        }
    }
    XHLaunchAdLog(@"从 LaunchScreen 中获取启动图失败!");
    return nil;
}

-(UIImage*)imageFromView:(UIView*)view{
    //fix bug:https://github.com/CoderZhuXH/XHLaunchAd/issues/203
    if (CGRectIsEmpty(view.frame)) {
        return nil;
    }
    CGSize size = view.bounds.size;
    //参数1:表示区域大小 参数2:如果需要显示半透明效果,需要传NO,否则传YES 参数3:屏幕密度
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    }else{
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


-(UIImage *)launchImageWithType:(NSString *)type{
    //比对分辨率,获取启动图 fix #158:https://github.com/CoderZhuXH/XHLaunchAd/issues/158
    if ([DomainManager currentLaunchImgName]) {
        return [ImageBundle imagewithBundleName:[DomainManager currentLaunchImgName]];
    }else{
        return [self imageFromLaunchScreen];
    }
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGSize screenDipSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * screenScale, [UIScreen mainScreen].bounds.size.height * screenScale);
    NSString *viewOrientation = type;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict){
        UIImage *image = [UIImage imageNamed:dict[@"UILaunchImageName"]];
        CGSize imageDpiSize = CGSizeMake(CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage));
        if([viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]){
            if([dict[@"UILaunchImageOrientation"] isEqualToString:@"Landscape"]){
                imageDpiSize = CGSizeMake(imageDpiSize.height, imageDpiSize.width);
            }
            if(CGSizeEqualToSize(screenDipSize, imageDpiSize)){
                return image;
            }
        }
    }
    return nil;
}

@end
