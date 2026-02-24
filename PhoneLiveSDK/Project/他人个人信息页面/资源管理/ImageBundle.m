//
//  ImageBundle.m
//  phonelive2
//
//  Created by lucas on 2022/1/14.
//  Copyright © 2022 toby. All rights reserved.
//

#import "ImageBundle.h"

@implementation ImageBundle
+ (NSBundle *)currentImageBundle{
#ifdef LIVE
    NSString *path =  [[NSBundle mainBundle]pathForResource:@"AnchorImgBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    return bundle;
#else
    NSString *path =  [[NSBundle mainBundle]pathForResource:@"ImgBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    return bundle;
#endif
    
    
}

+ (UIImage *)imagewithBundleName:(NSString *)imgName{
    if ([PublicObj checkNull:imgName]) {
        return nil;
    }
    NSBundle * bundle = [self currentImageBundle];
    NSString * imgStr;
    UIImage * image;
#ifdef LIVE
    imgStr = [NSString stringWithFormat:@"AnchorImgBundle.bundle/%@",imgName];
    image = [UIImage imageNamed:imgStr];
    if (image && image.size.width > 0 && image.size.height > 0) {
        return image;
    }
  
#else
    imgStr = [NSString stringWithFormat:@"ImgBundle.bundle/%@",imgName];
    image = [UIImage imageNamed:imgStr];
    if (image && image.size.width > 0 && image.size.height > 0) {
        return image;
    }
    
   
#endif
    
    
    // 2. 根据屏幕倍图优先级尝试加载图片
    CGFloat screenScale = [UIScreen mainScreen].scale;
    NSArray *scales = screenScale >= 3.0 ? @[@3, @2, @1,@0] : @[@2, @3, @1,@0]; // iPhone 优先 @3x
    
    // 先尝试原始名称
    for (NSNumber *scale in scales) {
        NSString *scaledName = [NSString stringWithFormat:@"%@@%ldx", imgName, (long)scale.integerValue];
        if (scale.intValue == 0) {
            scaledName = [NSString stringWithFormat:@"%@", imgName];
        }
        
        NSString *imagePath = [bundle pathForResource:scaledName ofType:@"png"];
        if (imagePath) {
            image =  [UIImage imageWithContentsOfFile:imagePath];
            if (image && image.size.width > 0 && image.size.height > 0) {
                return image;
            }
        }
    }
    
   
    
    // 3. 尝试加载无倍图版本
    NSString *imagePath = [bundle pathForResource:imgName ofType:@"png"];
    
    if (imagePath) {
        image =  [UIImage imageWithContentsOfFile:imagePath];
        if (image && image.size.width > 0 && image.size.height > 0) {
            return image;
        }
    }
    
   
    image = [UIImage imageNamed:imgName inBundle:bundle withConfiguration:nil];
    if (image && image.size.width > 0 && image.size.height > 0) {
        return image;
    }
    imgStr = [NSString stringWithFormat:@"%@/%@",bundle.bundlePath.lastPathComponent,imgName];
    image = [UIImage imageNamed:imgStr];
    if (image && image.size.width > 0 && image.size.height > 0) {
        return image;
    }
    
    // ========== 针对中文文件名的额外加载方式 ==========
    
    // 4. 尝试不带扩展名的多种格式（处理中文路径）
    NSArray *imageTypes = @[@"png", @"jpg", @"jpeg", @"gif"];
    for (NSString *type in imageTypes) {
        NSString *path = [bundle pathForResource:imgName ofType:type];
        if (path) {
            // 使用 URL 编码处理中文路径
            NSURL *imageURL = [NSURL fileURLWithPath:path];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            if (imageData) {
                image = [UIImage imageWithData:imageData];
                if (image && image.size.width > 0 && image.size.height > 0) {
                    return image;
                }
            }
        }
    }
    
    // 5. 遍历 bundle 内所有资源文件查找（处理中文文件名）
    NSArray *bundleContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundle.bundlePath error:nil];
    for (NSString *fileName in bundleContents) {
        // 去掉扩展名比较
        NSString *nameWithoutExt = [fileName stringByDeletingPathExtension];
        
        // 处理带倍图后缀的文件名
        NSString *cleanName = nameWithoutExt;
        if ([nameWithoutExt hasSuffix:@"@2x"]) {
            cleanName = [nameWithoutExt substringToIndex:nameWithoutExt.length - 3];
        } else if ([nameWithoutExt hasSuffix:@"@3x"]) {
            cleanName = [nameWithoutExt substringToIndex:nameWithoutExt.length - 3];
        }
        
        if ([cleanName isEqualToString:imgName]) {
            NSString *fullPath = [bundle.bundlePath stringByAppendingPathComponent:fileName];
            image = [UIImage imageWithContentsOfFile:fullPath];
            if (image && image.size.width > 0 && image.size.height > 0) {
                return image;
            }
        }
    }
    
    // 6. 使用 NSBundle 的 URLForResource 处理中文路径
    for (NSString *type in imageTypes) {
        NSURL *imageURL = [bundle URLForResource:imgName withExtension:type];
        if (imageURL) {
            image = [UIImage imageWithContentsOfFile:imageURL.path];
            if (image && image.size.width > 0 && image.size.height > 0) {
                return image;
            }
        }
    }
    
    // 7. 尝试带倍图后缀的中文文件名
    for (NSNumber *scale in scales) {
        NSString *scaledName = scale.intValue == 0 ? imgName : [NSString stringWithFormat:@"%@@%ldx", imgName, (long)scale.integerValue];
        
        for (NSString *type in imageTypes) {
            NSURL *imageURL = [bundle URLForResource:scaledName withExtension:type];
            if (imageURL) {
                image = [UIImage imageWithContentsOfFile:imageURL.path];
                if (image && image.size.width > 0 && image.size.height > 0) {
                    return image;
                }
            }
        }
    }
    
    return nil;
}
@end
