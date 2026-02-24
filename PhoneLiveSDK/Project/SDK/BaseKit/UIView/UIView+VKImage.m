//
//  UIView+VKImage.m
//
//  Created by vick on 2023/10/20.
//

#import "UIView+VKImage.h"
#import "SDWebImage.h"

@implementation UIView (VKImage)

- (void)vk_setImageUrl:(NSString *)url {
    [self vk_setImageUrl:url defalutImage:[UIImage imageNamed:@"defaultImage"]];
}

- (void)vk_setGridGameUrl:(NSString *)url {
    [self vk_setImageUrl:url defalutImage:[ImageBundle imagewithBundleName:@"game_center_small_placeholder"]];
}

- (void)vk_setLongGameUrl:(NSString *)url {
    [self vk_setImageUrl:url defalutImage:[ImageBundle imagewithBundleName:@"game_center_big_placeholder"]];
}

- (void)vk_setImageUrl:(NSString *)url defalutImage:(UIImage *)image {
    if ([self isKindOfClass:[UIImageView class]]) {
        [(UIImageView *)self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:image];
    }
    else if ([self isKindOfClass:[UIButton class]]) {
        [(UIButton *)self sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:image];
    }
}

+ (void)vk_loadImageUrl:(NSString *)url completed:(void (^)(UIImage *, NSError *))completed {
    NSURL *aUrl = [NSURL URLWithString:url];
    [SDWebImageManager.sharedManager loadImageWithURL:aUrl options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        !completed ?: completed(image, error);
    }];
}

+ (UIImage *)vk_animatedGIFNamed:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        return [UIImage sd_imageWithGIFData:data];
    }
    return [UIImage imageNamed:name];
}

+ (NSUInteger)vk_imageCachaSize {
    return [SDImageCache.sharedImageCache totalDiskSize];
}

+ (void)vk_clearImageCacha {
    [SDImageCache.sharedImageCache clearMemory];
}

@end
