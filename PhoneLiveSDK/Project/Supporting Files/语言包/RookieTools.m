//
//  RookieTools.m
//  SwitchLanguage
//
//  Created by Rookie on 2017/8/24.
//  Copyright © 2017年 Rookie. All rights reserved.
//

#import "RookieTools.h"
#import "ZYTabBarController.h"
#import <UIKit/UIKit.h>
#import "MJRefreshConfig.h"
//#import "ShowMessageVC.h"

static RookieTools *shareTool = nil;

@interface RookieTools()

@property(nonatomic,strong)NSBundle *bundle;
@property(nonatomic,copy)NSString *language;

@end

@implementation RookieTools
+ (void)load {
    // 交换MJ的国际化方法
    Method mjMethod = class_getClassMethod([NSBundle class],@selector(mj_localizedStringForKey:value:));
    Method myMethod = class_getClassMethod(self, @selector(hook_mj_localizedStringForKey:value:));
    method_exchangeImplementations(mjMethod, myMethod);
}
/// hook刷新控件的提示文字
+ (NSString *)hook_mj_localizedStringForKey:(NSString *)key value:(NSString *)value {
    NSString * languageStr =[[NSUserDefaults standardUserDefaults] objectForKey:CurrentLanguage];
    if ([languageStr hasPrefix:@"en"]) {
        languageStr = @"en";
    } else if ([languageStr hasPrefix:@"zh"]) {
        if ([languageStr rangeOfString:@"Hans"].location != NSNotFound) {
            languageStr = @"zh-Hans"; // 简体中文
        } else { // zh-Hant\zh-HK\zh-TW
            languageStr = @"zh-Hant"; // 繁體中文
        }
    } else if ([languageStr hasPrefix:@"ko"]) {
        languageStr = @"ko";
    } else if ([languageStr hasPrefix:@"ru"]) {
        languageStr = @"ru";
    } else if ([languageStr hasPrefix:@"uk"]) {
        languageStr = @"uk";
    } else if ([languageStr hasPrefix:@"vi"]) {
        languageStr = @"vi";
    } else if ([languageStr hasPrefix:@"id"]) {
        languageStr = @"id";
    } else {
        languageStr = @"en";
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mj_refreshBundle] pathForResource:languageStr ofType:@"lproj"]];
    return [bundle localizedStringForKey:key value:nil table:@"Localizable"];
}

+(id)shareInstance {
    @synchronized (self) {
        if (shareTool == nil) {
            shareTool = [[RookieTools alloc]init];
        }
    }
    return shareTool;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone {
    if (shareTool == nil) {
        shareTool = [super allocWithZone:zone];
    }
    return shareTool;
}

-(NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table {
    if (self.bundle) {
        return NSLocalizedStringFromTableInBundle(key, table, self.bundle, @"");
    }
    return NSLocalizedStringFromTable(key, table, @"");
}

-(void)resetLanguage:(NSString *)language withFrom:(NSString *)appdelegate{
    if ([minstr(language) isEqualToString:self.language]) {
        return;
    }
    [MJRefreshConfig defaultConfig].languageCode  = language;
    if ([minstr(language) isEqualToString:@"kor"]) {
        language = @"ko";
    }
    NSString *path = [XResourceBundle pathForResource:language ofType:@"lproj"];
    self.bundle = [NSBundle bundleWithPath:path];
    
    self.language = language;
    
    if (![minstr(appdelegate) isEqualToString:@"appdelegate"]) {
        [self resetRootViewController];
    }
    
}
-(void)resetRootViewController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    ZYTabBarController *root = [[ZYTabBarController alloc]init];
    window.rootViewController = root;
//    [root changeLanguage];
    
}

-(void)languageChange{
   
    NSString * languageStr =[[NSUserDefaults standardUserDefaults] objectForKey:CurrentLanguage];
    if ([PublicObj checkNull:languageStr]) {
        NSString *languageCode = [NSLocale preferredLanguages][0];// 返回的也是国际通用语言Code+国际通用国家地区代码
        NSString *countryCode = [NSString stringWithFormat:@"-%@", [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
        if (languageCode) {
            languageCode = [languageCode stringByReplacingOccurrencesOfString:countryCode withString:@""];
        }
        languageStr = languageCode;
        
        NSString *LanguageCurrent = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LanguageCurrent"];
        if (![PublicObj checkNull:LanguageCurrent]) {
            languageStr = LanguageCurrent;
        }
    }
    
    if ([languageStr isEqualToString:Language_ZH_CN]||[languageStr isEqualToString:Language_ZHT_CN]||[languageStr isEqualToString:Language_EN]||[languageStr isEqualToString:Language_JA]||[languageStr isEqualToString:Language_VI]||[languageStr isEqualToString:Language_ID]) {
        [[NSUserDefaults standardUserDefaults] setObject:languageStr forKey:CurrentLanguage];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:Language_EN forKey:CurrentLanguage];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[RookieTools shareInstance] resetLanguage:[[NSUserDefaults standardUserDefaults] objectForKey:CurrentLanguage] withFrom:@"appdelegate"];
   
}

-(void)resetLanguageNow:(NSString*)language{
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:CurrentLanguage];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[RookieTools shareInstance] resetLanguage:language withFrom:@"now"];
}
-(AppLanguageType)currentLanguage
{
    NSString *languageCurrent = [[NSUserDefaults standardUserDefaults] objectForKey:CurrentLanguage];
    if ([languageCurrent isEqualToString:Language_ZH_CN]) {
        return AppLanguageType_CN_jian;
    }else if([languageCurrent isEqualToString:Language_ZHT_CN]){
        return AppLanguageType_CN_fan;
    }else if ([languageCurrent isEqualToString:Language_EN]){
        return AppLanguageType_EN;
    }else if ([languageCurrent isEqualToString:Language_JA]){
        return AppLanguageType_JA;
    }else if ([languageCurrent isEqualToString:Language_VI]){
        return AppLanguageType_VN;
    }else if ([languageCurrent isEqualToString:Language_ID]){
        return AppLanguageType_IN;
    }
    return AppLanguageType_EN;
}
static NSString *languageCN = @"zh-cn";
static NSString *languageEN = @"en";
static NSString *languageFAN = @"zh-cht";
static NSString *languageJA = @"jp";
static NSString *languageVN = @"vn";
static NSString *languageIN = @"id";

+(NSString*)currentLanguageServer{
    
    if ([[RookieTools shareInstance] currentLanguage] == AppLanguageType_CN_jian ) {
        return languageCN;
    }else if ([[RookieTools shareInstance] currentLanguage] == AppLanguageType_EN){
        return languageEN;
    }else if ([[RookieTools shareInstance] currentLanguage] == AppLanguageType_CN_fan){
        return languageFAN;
    }else if ([[RookieTools shareInstance] currentLanguage] == AppLanguageType_JA){
        return languageJA;
    }else if ([[RookieTools shareInstance] currentLanguage] == AppLanguageType_VN){
        return languageVN;
    }else if ([[RookieTools shareInstance] currentLanguage] == AppLanguageType_IN){
        return languageIN;
    }
    return languageEN;
}
-(NSArray*)supportlanguages
{
    NSArray *languages = @[Language_EN,Language_ZH_CN,Language_ZHT_CN,Language_JA,Language_VI,Language_ID];
    return languages;
}
+(BOOL)isEmptyCharator{
    if ([[RookieTools currentLanguageServer] isEqualToString:@"en"]||[[RookieTools currentLanguageServer] isEqualToString:@"vn"]||[[RookieTools currentLanguageServer] isEqualToString:@"id"]) {
        return YES;
    }else{
        return NO;
    }
}

@end
