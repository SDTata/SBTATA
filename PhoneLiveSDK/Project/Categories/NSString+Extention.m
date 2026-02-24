//
//  NSString+Extention.m
//  phonelive
//
//  Created by 400 on 2020/8/27.
//  Copyright © 2020 toby. All rights reserved.
//

#import "NSString+Extention.h"
#import "HHTraceSDK.h"
#import "HHTools.h"
@implementation NSString (Extention)
+(ChannelsModel *)pasteChannelDispose{
    //识别剪贴板中的内容
    ChannelsModel *modelChannel = [ChannelsModel new];
    NSString *pasteString = @"";
    if ([StartGetHHTrace shareInstance].tidCopy == nil) {
        pasteString = [[HHTools shareInstance] getPasteboardString:nil];
//        NSString *regChannel = @"ios";
//        NSString *savedInstallStr = [common getInstallParams];
        if (pasteString.length>1) {
            [StartGetHHTrace shareInstance].tidCopy = pasteString;
        }
    }else{
        pasteString = [StartGetHHTrace shareInstance].tidCopy;
    }
   
    NSString *regChannel = @"ios";//[NSString stringWithFormat:@"defaulChannel-%@",[DomainManager sharedInstance].domainCode];
    NSString *savedInstallStr = [common getInstallParams];
    if(!savedInstallStr || savedInstallStr.length <= 0){
        if(pasteString && [pasteString hasPrefix:@"|||"]){
            [common saveInstallParams:pasteString];
            modelChannel.pasteString = pasteString;
            NSString *results = [pasteString substringFromIndex:3];
            NSData *jsonData = [results dataUsingEncoding:NSUTF8StringEncoding];//转化为data
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];//转化为字典
            if(info){
                NSString *channel = info[@"channel"];
                NSString *prarms = info[@"params"];
                if(channel && channel.length > 0){
                    regChannel = [NSString stringWithFormat:@"%@", channel];
                }
                modelChannel.channelCode = regChannel;
                modelChannel.paramsDic = prarms;
            }
        }
    }
    if(savedInstallStr || savedInstallStr.length > 0){
        if(savedInstallStr && [savedInstallStr hasPrefix:@"|||"]){
            modelChannel.pasteString = savedInstallStr;
            NSString *results = [savedInstallStr substringFromIndex:3];
            NSData *jsonData = [results dataUsingEncoding:NSUTF8StringEncoding];//转化为data
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];//转化为字典
            if(info){
                NSString *channel = info[@"channel"];
                NSString *prarms = info[@"params"];
                if(channel && channel.length > 0){
                    regChannel = [NSString stringWithFormat:@"%@", channel];
                }
                modelChannel.channelCode = regChannel;
                modelChannel.paramsDic = prarms;
            }
        }
    }
    return modelChannel;
}
- (BOOL)isPureInt{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (NSString*)reverseString {
    NSMutableString *reversedString = [NSMutableString string];
    NSInteger charIndex = [self length];
    while (charIndex > 0) {
        charIndex--;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reversedString appendString:[self substringWithRange:subStrRange]];
    }
    return reversedString;
}

+ (NSString *)toAmount:(NSString *)amount {
    if (!amount) {
        return @"0";
    }
    return amount;
}

- (NSString *)toDivide10 {
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:self];
    NSDecimalNumber *number10 = [NSDecimalNumber decimalNumberWithString:@"10.0"];
    number = [number decimalNumberByDividingBy:number10 withBehavior:[self getHandler:2]];
    return number.stringValue;
}

- (NSString *)toRate {
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:self];
    NSDecimalNumber *rateNumber = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
    if (rateNumber.floatValue > 0) {
        NSInteger decimalScale = 2;
        if (rateNumber.floatValue < 1 && number.floatValue <= 1) {
            decimalScale = 5;
        }
        number = [number decimalNumberByMultiplyingBy:rateNumber withBehavior:[self getHandler:decimalScale]];
    }
    return number.stringValue;
}

- (NSString *)toK {
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:self];
    if (fabs(number.floatValue) >= 1000) {
        NSDecimalNumber *number1000 = [NSDecimalNumber decimalNumberWithString:@"1000.0"];
        number = [number decimalNumberByDividingBy:number1000 withBehavior:[self getHandler:2]];
        return [NSString stringWithFormat:@"%@k", number.stringValue];
    }
    return number.stringValue;
}

- (NSString *)toUnit {
    return [NSString stringWithFormat:@"%@%@", [Config getRegionCurrenyChar] ?: @"", self];
}

- (NSDecimalNumberHandler *)getHandler:(NSInteger)scale {
    NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    return handler;
}

- (NSString *)toSub:(NSString *)value {
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:self];
    NSDecimalNumber *number10 = [NSDecimalNumber decimalNumberWithString:value];
    number = [number decimalNumberBySubtracting:number10 withBehavior:[self getHandler:2]];
    return number.stringValue;
}

@end
