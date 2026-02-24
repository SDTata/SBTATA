//
//  NSMutableAttributedString+VKUtil.m
//  dev
//
//  Created by vick on 2021/7/12.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "NSMutableAttributedString+VKUtil.h"
#import <objc/runtime.h>

@implementation NSMutableAttributedString (VKUtil)

- (void)setVk_font:(UIFont *)vk_font {
    objc_setAssociatedObject(self, @selector(vk_font), vk_font, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIFont *)vk_font {
    return objc_getAssociatedObject(self, @selector(vk_font));
}

- (void)vk_appendString:(id)string {
    if (!string) return;
    if ([string isKindOfClass:NSString.class]) {
        string = [NSAttributedString.alloc initWithString:string];
    }
    NSMutableAttributedString *result = [NSMutableAttributedString.alloc initWithAttributedString:string];
    if (self.vk_font) {
        [result addAttribute:NSFontAttributeName value:self.vk_font range:NSMakeRange(0, result.length)];
    }
    [self appendAttributedString:result];
}

- (void)vk_appendString:(id)string color:(UIColor *)color {
    if (!string) return;
    if ([string isKindOfClass:NSString.class]) {
        string = [NSAttributedString.alloc initWithString:string];
    }
    NSMutableAttributedString *result = [NSMutableAttributedString.alloc initWithAttributedString:string];
    if (self.vk_font) {
        [result addAttribute:NSFontAttributeName value:self.vk_font range:NSMakeRange(0, result.length)];
    }
    if (color) {
        [result addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, result.length)];
    }
    [self appendAttributedString:result];
}

- (void)vk_appendString:(id)string color:(UIColor *)color font:(UIFont *)font {
    if (!string) return;
    if ([string isKindOfClass:NSString.class]) {
        string = [NSAttributedString.alloc initWithString:string];
    }
    NSMutableAttributedString *result = [NSMutableAttributedString.alloc initWithAttributedString:string];
    if (font) {
        [result addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, result.length)];
    }
    if (color) {
        [result addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, result.length)];
    }
    [self appendAttributedString:result];
}

- (void)vk_appendImage:(id)image {
    [self vk_appendImage:image size:CGSizeZero];
}

- (void)vk_appendImage:(id)image size:(CGSize)size {
    [self vk_appendImageData:image size:size];
}

- (void)vk_appendSpace:(CGFloat)width {
    UIGraphicsBeginImageContext(CGSizeMake(width, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self vk_appendImageData:image size:CGSizeMake(width, 1)];
}

- (void)vk_appendImageData:(id)imageData size:(CGSize)size {
    UIImage *image = imageData;
    if ([imageData isKindOfClass:NSString.class]) {
        image = [UIImage imageNamed:imageData];
    }
    if ([imageData isKindOfClass:NSData.class]) {
        image = [UIImage imageWithData:imageData];
    }
    if (!image) {
        return;
    }
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    CGFloat scale = (imageWidth / imageHeight);
    if (size.width > 0 || size.height > 0) {
        imageHeight = size.height;
        imageWidth = size.width;
    } else {
        imageHeight = self.vk_font.pointSize;
        imageWidth = scale * imageHeight;
    }
    CGFloat textPaddingTop = (self.vk_font.lineHeight - self.vk_font.pointSize) / 2;
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, -textPaddingTop, imageWidth, imageHeight);
    NSAttributedString *imageAttachment = [NSAttributedString attributedStringWithAttachment:attachment];
    [self appendAttributedString:imageAttachment];
}

- (void)vk_appendImage:(id)imageData size:(CGSize)size tapAction:(void(^)(void))action{
    UIImage *image = imageData;
    if ([imageData isKindOfClass:NSString.class]) {
        image = [UIImage imageNamed:imageData];
    }
    if ([imageData isKindOfClass:NSData.class]) {
        image = [UIImage imageWithData:imageData];
    }
    if (!image) {
        return;
    }
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    CGFloat scale = (imageWidth / imageHeight);
    if (size.width > 0 || size.height > 0) {
        imageHeight = size.height;
        imageWidth = size.width;
    } else {
        imageHeight = self.vk_font.pointSize;
        imageWidth = scale * imageHeight;
    }
    CGFloat textPaddingTop = (self.vk_font.lineHeight - self.vk_font.pointSize) / 2;
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, -textPaddingTop, imageWidth, imageHeight);
    NSAttributedString *imageAttachment = [NSAttributedString attributedStringWithAttachment:attachment];
    [self appendAttributedString:imageAttachment];
}

- (void)vk_setStrings:(NSArray *)strings color:(UIColor *)color font:(UIFont *)font {
    [strings enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:obj options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [regular matchesInString:self.string options:0 range:NSMakeRange(0, self.string.length)];
        for (NSTextCheckingResult *match in matches) {
            [self addAttribute:NSForegroundColorAttributeName value:color range:match.range];
            [self addAttribute:NSFontAttributeName value:font range:match.range];
        }
    }];
}

- (void)vk_setLineSpacing:(CGFloat)lineSpacing alignment:(NSTextAlignment)alignment {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.alignment = alignment;
    [self addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.string.length)];
}

@end
