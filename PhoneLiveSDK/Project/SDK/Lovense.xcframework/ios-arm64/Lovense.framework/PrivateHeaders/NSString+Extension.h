//
//  NSString+Extension.h
//  Lovense
//
//  Created by 陈自豪 on 2023/5/26.
//  Copyright © 2023 lovense. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface  NSString (Extension)

/// JSON  -> Dictionary
/// - Parameter jsonString: jsonStr
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

/// 字符串转md5字符串
- (NSString *) md5;
// 获取随机字符
+ (NSString *)randomStringWithLength:(int)len;
// 获取时间戳
+ (NSString *)timeIntervalString;
// pattern文件存储地址
+ (NSString *) patternFileSavePath;
@end

NS_ASSUME_NONNULL_END
