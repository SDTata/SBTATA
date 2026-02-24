//
//  XBundle.h
//  phonelive2
//
//  Created by test on 2022/1/14.
//  Copyright © 2022 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#define XResourceBundle [XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]
NS_ASSUME_NONNULL_BEGIN

@interface XBundle : NSObject
+ (NSBundle *)currentXibBundleWithResourceName:(NSString *)className;
+ (NSBundle *)mainBundle;
@end

NS_ASSUME_NONNULL_END
