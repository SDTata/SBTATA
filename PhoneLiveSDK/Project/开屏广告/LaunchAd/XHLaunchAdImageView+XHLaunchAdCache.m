//
//  XHLaunchAdImageView+XHLaunchAdCache.m
//  XHLaunchAdExample
//
//  Created by zhuxiaohui on 2017/9/18.
//  Copyright © 2017年 it7090.com. All rights reserved.
//  代码地址:https://github.com/CoderZhuXH/XHLaunchAd

#import "XHLaunchAdImageView+XHLaunchAdCache.h"
#import "XHLaunchAdConst.h"
#import <FFAES/FFAES.h>
#import "LiveGifImage.h"


@implementation XHLaunchAdImageView (XHLaunchAdCache)
- (void)xh_setImageWithURL:(nonnull NSURL *)url{
    [self xh_setImageWithURL:url placeholderImage:nil];
}

- (void)xh_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder{
    [self xh_setImageWithURL:url placeholderImage:placeholder options:XHLaunchAdImageDefault];
}

-(void)xh_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(XHLaunchAdImageOptions)options{
    [self xh_setImageWithURL:url placeholderImage:placeholder options:options completed:nil];
}

- (void)xh_setImageWithURL:(nonnull NSURL *)url completed:(nullable XHExternalCompletionBlock)completedBlock {
    
    [self xh_setImageWithURL:url placeholderImage:nil completed:completedBlock];
}

- (void)xh_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable XHExternalCompletionBlock)completedBlock{
    [self xh_setImageWithURL:url placeholderImage:placeholder options:XHLaunchAdImageDefault completed:completedBlock];
}

-(void)xh_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(XHLaunchAdImageOptions)options completed:(nullable XHExternalCompletionBlock)completedBlock{
    [self xh_setImageWithURL:url placeholderImage:placeholder GIFImageCycleOnce:NO options:options GIFImageCycleOnceFinish:nil completed:completedBlock ];
}

- (void)xh_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder GIFImageCycleOnce:(BOOL)GIFImageCycleOnce options:(XHLaunchAdImageOptions)options GIFImageCycleOnceFinish:(void(^_Nullable)(void))cycleOnceFinishBlock completed:(nullable XHExternalCompletionBlock)completedBlock {
    if(placeholder) self.image = placeholder;
    if(!url) return;
    WeakSelf
    [[XHLaunchAdImageManager sharedManager] loadImageWithURL:url options:options progress:nil completed:^(UIImage * _Nullable image,  NSData *_Nullable imageData, NSError * _Nullable error, NSURL * _Nullable imageURL) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(!error){
            if ([url.lastPathComponent containsString:@"aes"]) {
                imageData = [FFAES decryptData:imageData key:KAESKEY];
            }
            
            if(XHISGIFTypeWithData(imageData)){
                strongSelf.image = nil;
                LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:imageData];
                [imgAnima setAnimatedImageLoopCount:0];
                strongSelf.image = imgAnima;
                __weak typeof(self) weakSelf1 = strongSelf;
//                strongSelf.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
//                    if(GIFImageCycleOnce){
//                        if (weakSelf1) {
//                            [weakSelf1 stopAnimating];
//                        }
//                        XHLaunchAdLog(@"GIF不循环,播放完成");
//                        if(cycleOnceFinishBlock) cycleOnceFinishBlock();
//                    }
//                };
            }else{
                strongSelf.image = image;
//                strongSelf.image = nil;
            }
        }
        if(completedBlock) completedBlock(image,imageData,error,imageURL);
    }];
}

@end
