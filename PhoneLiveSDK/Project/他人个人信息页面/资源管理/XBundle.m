//
//  XBundle.m
//  phonelive2
//
//  Created by test on 2022/1/14.
//  Copyright © 2022 toby. All rights reserved.
//

#import "XBundle.h"

@implementation XBundle
+ (NSBundle *)currentXibBundleWithResourceName:(NSString *)className{
#ifdef LIVE
    NSString *path =  [[NSBundle mainBundle]pathForResource:@"AnchorImgBundle" ofType:@"bundle"];
    NSBundle *xbundle = [NSBundle bundleWithPath:path];
    return xbundle;
#else
    NSString *path =  [[NSBundle mainBundle]pathForResource:@"ImgBundle" ofType:@"bundle"];
    NSBundle *xbundle = [NSBundle bundleWithPath:path];
    return xbundle;
#endif
}
+ (NSBundle *)mainBundle {
    return [XBundle currentXibBundleWithResourceName:@""];
}
@end
