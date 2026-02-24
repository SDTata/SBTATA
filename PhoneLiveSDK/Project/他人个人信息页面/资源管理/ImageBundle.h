//
//  ImageBundle.h
//  phonelive2
//
//  Created by lucas on 2022/1/14.
//  Copyright © 2022 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageBundle : NSObject
+ (NSBundle *)currentImageBundle;
+ (UIImage *)imagewithBundleName:(NSString *)imgName;
@end

NS_ASSUME_NONNULL_END
