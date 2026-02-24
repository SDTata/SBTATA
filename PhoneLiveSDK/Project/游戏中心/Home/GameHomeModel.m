//
//  GameHomeModel.m
//  phonelive2
//
//  Created by vick on 2024/10/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "GameHomeModel.h"

@implementation GameListModel

- (void)setUrlName:(NSString *)urlName {
    _urlName = urlName;
    
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:[urlName.toURL absoluteString]];
    if (cachedImage) {
        _imageScale = cachedImage.size.height / cachedImage.size.width;
    }
}

@end


@implementation GameTypeModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"sub": [GameListModel class]
    };
}

- (void)mj_didConvertToObjectWithKeyValues:(NSDictionary *)keyValues {
    [_sub setValue:@(_gridCount) forKeyPath:@"gridCount"];
}

@end


@implementation GameHomeModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"sub": [GameTypeModel class]
    };
}

@end
