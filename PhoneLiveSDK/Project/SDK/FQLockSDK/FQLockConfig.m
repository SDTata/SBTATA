//
//  FQLockConfig.m
//  PhoneLiveSDK
//
//  Created on 2025/04/07.
//

#import "FQLockConfig.h"

@implementation FQLockConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        // 设置默认值
        _lockType = FQLockTypeSetting;
        _lockViewBackgroundColor = [UIColor clearColor];
        _lockViewEdgeMargin = 50;
        _lockLeastCount = 4;
        _themeColor = [UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:1.0]; // #407bff
        
        // 新添加属性的默认值
        _lineWidth = 1.0;
        _dotRadius = 15.0;
        _dotInnerRadius = 5.0;
        _errorColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0]; // #FF4040
    }
    return self;
}

@end
