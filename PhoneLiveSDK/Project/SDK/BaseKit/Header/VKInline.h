//
//  VKInline.h
//  VKCodeKit
//
//  Created by vick on 2020/10/26.
//

#import <objc/runtime.h>
#import <sys/time.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <mach/mach.h>
#import <mach-o/arch.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark -
#pragma mark - 系统参数
/** App名称*/
UIKIT_STATIC_INLINE NSString* vkAppName(void) {
    return NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
}
/** App包名*/
UIKIT_STATIC_INLINE NSString* vkBundleID(void) {
    return NSBundle.mainBundle.infoDictionary[@"CFBundleIdentifier"];
}
/** App图标*/
UIKIT_STATIC_INLINE UIImage* vkAppIcon(void) {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSArray *iconsArr = infoDict[@"CFBundleIcons"][@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"];
    NSString *iconLastName = [iconsArr lastObject];
    return [UIImage imageNamed:iconLastName];
}
/** App版本号*/
UIKIT_STATIC_INLINE NSString* vkAppVersionName(void) {
    return NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];;
}
/** App构建号*/
UIKIT_STATIC_INLINE NSString* vkAppVersion(void) {
    return NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
}
/** 系统版本号*/
UIKIT_STATIC_INLINE NSString* vkOSVersion(void) {
    return UIDevice.currentDevice.systemVersion;
}
/** 当前IP地址*/
UIKIT_STATIC_INLINE NSString* vkIpAddress(void) {
    NSString *address = @"0.0.0.0";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                NSString* ifname = [NSString stringWithUTF8String:temp_addr->ifa_name];
                    if(
                        // Check if interface is en0 which is the wifi connection the iPhone
                        // and the ethernet connection on the Apple TV
                        [ifname isEqualToString:@"en0"] ||
                        // Check if interface is en1 which is the wifi connection on the Apple TV
                        [ifname isEqualToString:@"en1"]
                    ) {
                        // Get NSString from C String
                        address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}


#pragma mark -
#pragma mark - 沙盒路径
UIKIT_STATIC_INLINE NSString* vkPathHome(void) {
    return NSHomeDirectory();
}
UIKIT_STATIC_INLINE NSString* vkPathTemp(void) {
    return NSTemporaryDirectory();
}
UIKIT_STATIC_INLINE NSString* vkPathDocument(void) {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}
UIKIT_STATIC_INLINE NSString* vkPathLibrary(void) {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}
UIKIT_STATIC_INLINE NSString* vkPathCache(void) {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}
UIKIT_STATIC_INLINE NSData *vkBundleFile(NSString *fileName) {
    NSArray *items = [fileName componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:items.firstObject ofType:items.lastObject];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}


#pragma mark -
#pragma mark - 缓存工具
/**NSUserDefaults存储*/
UIKIT_STATIC_INLINE void vkUserSet(NSString *key, id value) {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
UIKIT_STATIC_INLINE id vkUserGet(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
UIKIT_STATIC_INLINE void vkUserDel(NSString *key) {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}
/**文件归档*/
UIKIT_STATIC_INLINE void vkArchiveSet(NSString *key, id value) {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.db", key]];
    [NSKeyedArchiver archiveRootObject:value toFile:path];
}
UIKIT_STATIC_INLINE id vkArchiveGet(NSString *key) {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.db", key]];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}


#pragma mark -
#pragma mark - 消息通知
UIKIT_STATIC_INLINE void vkNoticeSend(NSString *name, NSDictionary *info) {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:info];
}
UIKIT_STATIC_INLINE void vkNoticeReceive(id observer, NSString *name, SEL sel) {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:sel name:name object:nil];
}
UIKIT_STATIC_INLINE void vkNoticeRemove(id observer) {
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}


#pragma mark -
#pragma mark - 时间处理
/**时间格式化*/
UIKIT_STATIC_INLINE NSDateFormatter* vkDateFormatter(NSString *dateFormat) {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    dateFormatter.dateFormat = dateFormat ? dateFormat : @"yyyy-MM-dd HH:mm:ss";
    return dateFormatter;
}
/**时间戳转时间*/
UIKIT_STATIC_INLINE NSString* vkDate(NSString *date, NSString *dateFormat) {
    NSDate *dateData = [NSDate dateWithTimeIntervalSince1970:date.longLongValue/1000];
    return [vkDateFormatter(dateFormat) stringFromDate:dateData];
}
/**当前时间戳*/
UIKIT_STATIC_INLINE NSString *vkTimestamp(void) {
    return [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970] * 1000)];
}
/**计算花费时间*/
UIKIT_STATIC_INLINE void vkTimeCost(void (^block)(void)) {
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    NSLog(@"time cost: %f ms",ms);
}


#pragma mark -
#pragma mark - GCD封装
UIKIT_STATIC_INLINE void vkGcdOnce(void (^block)(void)) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, block);
}
UIKIT_STATIC_INLINE void vkGcdAfter(CGFloat time, void (^block)(void)) {
    dispatch_time_t time_t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    dispatch_after(time_t, dispatch_get_main_queue(), block);
}
UIKIT_STATIC_INLINE void vkGcdGlobal(void (^block)(void)) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
UIKIT_STATIC_INLINE void vkGcdMain(void (^block)(void)) {
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
UIKIT_STATIC_INLINE void vkGcdGroup(void (^block)(void (^enter)(void), void (^leave)(void)), void (^notify)(void)) {
    dispatch_group_t group = dispatch_group_create();
    block(^{
        dispatch_group_enter(group);
    }, ^{
        dispatch_group_leave(group);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        notify();
    });
}
UIKIT_STATIC_INLINE dispatch_source_t vkGcdTimer(CGFloat time, void (^block)(void)) {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, time * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, block);
    return timer;
}
UIKIT_STATIC_INLINE void vkGcdTimerStart(dispatch_source_t timer) {
    if (timer) {
        dispatch_resume(timer);
    }
}
UIKIT_STATIC_INLINE void vkGcdTimerStop(dispatch_source_t timer) {
    if (timer) {
        dispatch_suspend(timer);
    }
}


#pragma mark -
#pragma mark - 颜色处理
UIKIT_STATIC_INLINE UIColor* vkColorRGBA(CGFloat r, CGFloat g, CGFloat b, CGFloat a) {
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}
UIKIT_STATIC_INLINE UIColor* vkColorRGB(CGFloat r, CGFloat g, CGFloat b) {
    return vkColorRGBA(r, g, b, 1.0);
}
UIKIT_STATIC_INLINE UIColor* vkColorHexA(NSInteger value, CGFloat a) {
    return [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16))/255.0 green:((float)((value & 0xFF00) >> 8))/255.0 blue:((float)(value & 0xFF))/255.0 alpha:a];
}
UIKIT_STATIC_INLINE UIColor* vkColorHex(NSInteger value) {
    return vkColorHexA(value, 1.0);
}
/**随机颜色*/
UIKIT_STATIC_INLINE UIColor* vkColorRandom(void) {
    return vkColorRGB(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256));
}
/**颜色转图片*/
UIKIT_STATIC_INLINE UIImage* vkColorImage(UIColor *color, CGSize size) {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark -
#pragma mark - 字体设置
UIKIT_STATIC_INLINE UIFont* vkFontName(CGFloat font, NSString *name) {
    return [UIFont fontWithName:name size:font];
}
UIKIT_STATIC_INLINE UIFont* vkFont(CGFloat font) {
    return [UIFont systemFontOfSize:font];
}
UIKIT_STATIC_INLINE UIFont* vkFontBold(CGFloat font) {
    return [UIFont boldSystemFontOfSize:font];
}
UIKIT_STATIC_INLINE UIFont* vkFontMedium(CGFloat font) {
    return [UIFont boldSystemFontOfSize:font];
}

#pragma mark -
#pragma mark - UI相关
/**StoryBoard vc*/
UIKIT_STATIC_INLINE id vkStoryBoardVc(NSString *boardName, NSString *className) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:boardName bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:className];
    return vc;
}
/**最上层控制器*/
UIKIT_STATIC_INLINE UIViewController *vkTopVC(void) {
  UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
  while (1) {
      if ([vc isKindOfClass:[UITabBarController class]]) {
          vc = ((UITabBarController*)vc).selectedViewController;
      }
      if ([vc isKindOfClass:[UINavigationController class]]) {
          vc = ((UINavigationController*)vc).visibleViewController;
      }
      if (vc.presentedViewController) {
          vc = vc.presentedViewController;
      } else {
          break;
      }
  }
  return vc;
}
UIKIT_STATIC_INLINE UITabBarController *vkTabBarVC(void) {
    return (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
}
/**系统弹窗*/
UIKIT_STATIC_INLINE UIAlertController * vkAlertController(NSString *title, NSString *message, NSArray *actions, UIAlertControllerStyle preferredStyle, void (^actionBlock)(NSInteger index)) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    [actions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (actionBlock) actionBlock(idx);
        }];
        [alert addAction:action];
    }];
    if (preferredStyle == UIAlertControllerStyleActionSheet) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
    }
    vkGcdAfter(0, ^{
        [vkTopVC() presentViewController:alert animated:YES completion:nil];
    });
    return alert;
}
/**列表弹窗*/
UIKIT_STATIC_INLINE UIAlertController * vkSheet(NSString *title, NSString *message, NSArray *actions, void (^actionBlock)(NSInteger index)) {
    return vkAlertController(title, message, actions, UIAlertControllerStyleActionSheet, actionBlock);
}
/**警告弹窗*/
UIKIT_STATIC_INLINE UIAlertController * vkAlert(NSString *title, NSString *message, NSArray *actions, void (^actionBlock)(NSInteger index)) {
    return vkAlertController(title, message, actions, UIAlertControllerStyleAlert, actionBlock);
}

/**打开外部链接*/
UIKIT_STATIC_INLINE void vkOpenURL(NSString *url) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
    });
}
/**调用系统分享*/
UIKIT_STATIC_INLINE void vkShare(NSString *name, UIImage *image, NSString *url, void (^block)(UIActivityType activityType, BOOL completed)) {
    NSURL *urlToShare = [NSURL URLWithString:url];
    NSArray *activityItems = @[name , image, urlToShare];
    UIActivityViewController *activityVc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVc.excludedActivityTypes=@[UIActivityTypePrint,
                                       UIActivityTypeCopyToPasteboard,
                                       UIActivityTypeAssignToContact,
                                       UIActivityTypeSaveToCameraRoll,
                                       UIActivityTypeAddToReadingList];
    [vkTopVC() presentViewController:activityVc animated:YES completion:nil];
    activityVc.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (block) block(activityType, completed);
    };
}
/**获取文字尺寸*/
UIKIT_STATIC_INLINE CGSize vkTextSize(NSString *text, UIFont *font, CGFloat maxWidth) {
    return [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                  attributes:@{NSFontAttributeName: font}
                                     context:nil].size;
}
/**获取文字宽度*/
UIKIT_STATIC_INLINE CGFloat vkTextWidth(NSString *text, UIFont *font) {
    return vkTextSize(text, font, CGFLOAT_MAX).width;
}
/**获取文字高度*/
UIKIT_STATIC_INLINE CGFloat vkTextHeight(NSString *text, UIFont *font, CGFloat maxWidth) {
    return vkTextSize(text, font, maxWidth).height;
}
/** 更改字符串特定字符颜色*/
UIKIT_STATIC_INLINE NSMutableAttributedString* vkAttributedTexts(NSString *text, NSArray *appointTexts, UIColor *color, UIFont *font) {
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:text];
    [appointTexts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:obj options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [regular matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *match in matches) {
            [content addAttribute:NSForegroundColorAttributeName value:color range:match.range];
            [content addAttribute:NSFontAttributeName value:font range:match.range];
        }
    }];
    return content;
}
/** 创建HTML富文本*/
UIKIT_STATIC_INLINE NSMutableAttributedString* vkAttributedHtmlText(NSString *text, UIColor *color, UIFont *font, CGFloat lineSpacing) {
    NSData *textData = [text dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType
    };
    NSAttributedString *string = [[NSAttributedString alloc] initWithData:textData options:options documentAttributes:nil error:nil];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    if (color) {
        [content addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, string.string.length)];
    }
    if (font) {
        [content addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.string.length)];
    }
    [content addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:NSMakeRange(0, string.string.length)];
    [content addAttribute:NSUnderlineColorAttributeName value:UIColor.clearColor range:NSMakeRange(0, string.string.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    [content addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.string.length)];
    
    return content;
}
/**创建富文本*/
UIKIT_STATIC_INLINE NSAttributedString* vkAttributedString(NSString *text, UIColor *color, UIFont *font) {
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: color
    };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark -
#pragma mark - 数据处理
/**对象转Json*/
UIKIT_STATIC_INLINE NSString* vkToJson(id object) {
    if (!object) return nil;
    if ([NSJSONSerialization isValidJSONObject:object]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
        if (!data) return nil;
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
}
/**Json转对象*/
UIKIT_STATIC_INLINE id vkFromJson(id object) {
    if (!object) return nil;
    if ([object isKindOfClass:[NSString class]]) {
        object = [object dataUsingEncoding:NSUTF8StringEncoding];
    }
    if (!object) return nil;
    return [NSJSONSerialization JSONObjectWithData:object options:NSJSONReadingMutableContainers error:nil];
}
/**随机字符串*/
UIKIT_STATIC_INLINE NSString* vkRandomString(NSString *text, NSInteger length) {
    if (!text) text = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (NSInteger i = 0; i < length; i++) {
        [randomString appendFormat:@"%c", [text characterAtIndex:arc4random_uniform((unsigned int)text.length)]];
    }
    return randomString;
}
/// 随机数字
UIKIT_STATIC_INLINE NSInteger vkRandomNumber(NSInteger from, NSInteger to) {
    return (NSInteger)(from + (arc4random() % (to - from + 1)));
}
/// 计算行数
UIKIT_STATIC_INLINE NSInteger vkLineCount(NSInteger count, NSInteger line) {
    if (count == 0 || line == 0) {
        return 0;
    }
    if (count % line == 0) {
        return count / line;
    } else {
        return count / line + 1;
    }
}
/// Block定义
typedef void (^VKBlock) (void);
typedef void (^VKDataBlock) (id data);
typedef void (^VKDatasBlock) (id data1, id data2);
typedef void (^VKBoolBlock) (BOOL flag);

#pragma clang diagnostic pop
