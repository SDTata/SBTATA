//
//  HomeRecommendGameModel.m
//  phonelive2
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeRecommendGameModel.h"

@implementation HomeRecommendGame

- (void)setIcon:(NSString *)icon {
    _icon = icon;
    
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:[icon.toURL absoluteString]];
    if (cachedImage) {
        _imageScale = cachedImage.size.height / cachedImage.size.width;
    }
}

@end

@implementation HomeRecommendGameModel

+ (NSDictionary*)mj_replacedKeyFromPropertyName {
    return @{@"className": @"class"};
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"data" : [HomeRecommendGame class]};
}

- (BOOL)isScroll {
    if (self.layout_column == 0) {
        return YES;
    }

    return NO;
}

@end
