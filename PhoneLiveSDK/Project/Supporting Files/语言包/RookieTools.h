//
//  RookieTools.h
//  SwitchLanguage
//
//  Created by Rookie on 2017/8/24.
//  Copyright © 2017年 Rookie. All rights reserved.
//



#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,AppLanguageType) {
    AppLanguageType_EN  = 1,
    AppLanguageType_CN_jian  = 2,
    AppLanguageType_CN_fan   = 3,
    AppLanguageType_JA   = 4,
    AppLanguageType_VN = 5,
    AppLanguageType_IN = 6
    
    
};
@interface RookieTools : NSObject

+(id)shareInstance;

/**
 *  返回table中指定的key的值
 *
 *  @param key   key
 *  @param table table
 *
 *  @return 返回table中指定的key的值
 */
-(NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table;
/**
 *  重置语言
 *
 *  @param language 新语言
 */
-(void)resetLanguage:(NSString*)language withFrom:(NSString *)appdelegate;

///启动app
-(void)languageChange;

///重新切换
-(void)resetLanguageNow:(NSString*)language;

-(AppLanguageType)currentLanguage;

+(NSString*)currentLanguageServer;

-(NSArray*)supportlanguages;

+(BOOL)isEmptyCharator;
@end
