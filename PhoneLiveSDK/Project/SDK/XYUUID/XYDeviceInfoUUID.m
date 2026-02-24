//
//  XYDeviceInfoUUID.m
//  XYUUID
//
//  Created by steve on 2016/7/21.
//  Copyright © 2020 guojunliu.github.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYDeviceInfoUUID.h"
#import <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
@implementation XYDeviceInfoUUID

static XYDeviceInfoUUID* manager = nil;

/** 单例类方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[super allocWithZone:NULL] init];
        }
        
    });
    return manager;
}

static NSString *systemBootTime(){
    struct timeval boottime;
    size_t len = sizeof(boottime);
    int mib[2] = { CTL_KERN, KERN_BOOTTIME };
    
    if( sysctl(mib, 2, &boottime, &len, NULL, 0) < 0 )
    {
        return @"";
    }
    time_t bsec = boottime.tv_sec / 10000;
    
//    time_t bsec = 1476249507 / 10000;   //  2016/10/11 13:18:27
//    time_t bsec = 1476249507 / 10000;   //  2015/10/11 13:18:27
    
    NSString *bootTime = [NSString stringWithFormat:@"%ld",bsec];
    
    return bootTime;
}

static NSString *countryCode() {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    return countryCode;
}

static NSString *language() {
    NSString *language;
    NSLocale *locale = [NSLocale currentLocale];
    if ([[NSLocale preferredLanguages] count] > 0) {
        NSString *languageCode = [NSLocale preferredLanguages][0];// 返回的也是国际通用语言Code+国际通用国家地区代码
        NSString *countryCode = [NSString stringWithFormat:@"-%@", [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
        if (languageCode) {
            languageCode = [languageCode stringByReplacingOccurrencesOfString:countryCode withString:@""];
        }
        language = languageCode;
    } else {
        language = [locale objectForKey:NSLocaleLanguageCode];
    }
    
    return language;
}

static NSString *systemVersion() {
    return [[UIDevice currentDevice] systemVersion];
}

static NSString *deviceName(){
    return [[UIDevice currentDevice] name];
}


static const char *SIDFAModel =       "hw.model";
static const char *SIDFAMachine =     "hw.machine";
static NSString *getSystemHardwareByName(const char *typeSpecifier) {
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    NSString *results = [NSString stringWithUTF8String:answer];
    free(answer);
    return results;
}

static NSUInteger getSysInfo(uint typeSpecifier) {
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

static NSString *carrierInfo() {
    NSMutableString* cInfo = [NSMutableString string];
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    NSString *carrierName = [carrier carrierName];
    if (carrierName != nil){
        [cInfo appendString:carrierName];
    }
    
    NSString *mcc = [carrier mobileCountryCode];
    if (mcc != nil){
        [cInfo appendString:mcc];
    }
    
    NSString *mnc = [carrier mobileNetworkCode];
    if (mnc != nil){
        [cInfo appendString:mnc];
    }
    
    return cInfo;
}


static NSString *systemHardwareInfo(){
    NSString *model = getSystemHardwareByName(SIDFAModel);
    NSString *machine = getSystemHardwareByName(SIDFAMachine);
    NSString *carInfo = carrierInfo();
    NSUInteger totalMemory = getSysInfo(HW_PHYSMEM);
    
    return [NSString stringWithFormat:@"%@,%@,%@,%td",model,machine,carInfo,totalMemory];
}



static NSString *systemFileTime(){
    NSFileManager *file = [NSFileManager defaultManager];
    NSDictionary *dic= [file attributesOfItemAtPath:@"System/Library/CoreServices" error:nil];
    return [NSString stringWithFormat:@"%@,%@",[dic objectForKey:NSFileCreationDate],[dic objectForKey:NSFileModificationDate]];
}

static NSString *disk(){
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSString *diskSize = [[fattributes objectForKey:NSFileSystemSize] stringValue];
    return diskSize;
}

static void MD5_16(NSString *source, unsigned char *ret){
    const char* str = [source UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    for(int i = 4; i < CC_MD5_DIGEST_LENGTH - 4; i++) {
        ret[i-4] = result[i];
    }
}

static NSString *combineTwoFingerPrint(unsigned char *fp1,unsigned char *fp2){
    NSMutableString *hash = [NSMutableString stringWithCapacity:36];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i+=1)
    {
        if (i==4 || i== 6 || i==8 || i==10)
            [hash appendString:@"-"];
        
        if (i < 8) {
            [hash appendFormat:@"%02X",fp1[i]];
        }else{
            [hash appendFormat:@"%02X",fp2[i-8]];
        }
    }
    
    return hash;
}

+ (NSString *)createDeviceInfoUUID {
//    NSString *sysBootTime = systemBootTime();
//    NSString *countryC= countryCode();
//    NSString *languge = language();
//    NSString *deviceN = deviceName();
//    NSString *sysVer = systemVersion();
    
    NSString *deviceModel = [[UIDevice currentDevice] model];
    
    NSString *systemHardware = systemHardwareInfo();
    NSString *systemFT = systemFileTime();
    NSString *diskS = disk();
    NSString *ipAddress = [XYDeviceInfoUUID getLocalIPAddress:YES];
    NSString *fingerPrintUnstablePart = [NSString stringWithFormat:@"%f,%f,%f,%@,%@", SCREEN_WIDTH, SCREEN_HEIGHT, statusbarHeight,deviceModel,ipAddress];
    
    NSString *fingerPrintStablePart = [NSString stringWithFormat:@"%@,%@,%@", systemHardware, systemFT, diskS];
    
    unsigned char fingerPrintUnstablePartMD5[CC_MD5_DIGEST_LENGTH/2];
    MD5_16(fingerPrintUnstablePart,fingerPrintUnstablePartMD5);
    
    unsigned char fingerPrintStablePartMD5[CC_MD5_DIGEST_LENGTH/2];
    MD5_16(fingerPrintStablePart,fingerPrintStablePartMD5);
    
    NSString *simulateIDFA = combineTwoFingerPrint(fingerPrintStablePartMD5,fingerPrintUnstablePartMD5);
    return simulateIDFA;
}
+ (NSString *)getLocalIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+(void)getWANIPAddress:(void (^)(NSString * _Nullable))completionHandler
{
    
    if([XYDeviceInfoUUID sharedInstance].ip4String!= nil && [XYDeviceInfoUUID sharedInstance].ip4String.length>1){
//        return [XYDeviceInfoUUID sharedInstance].ip4String;
        completionHandler([XYDeviceInfoUUID sharedInstance].ip4String);
        return;
    }
   
    __block BOOL isCallback = false;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([XYDeviceInfoUUID sharedInstance].ip4String== nil || ([XYDeviceInfoUUID sharedInstance].ip4String!= nil && [XYDeviceInfoUUID sharedInstance].ip4String.length<1)){
            if(!isCallback){
                isCallback = true;
                completionHandler([XYDeviceInfoUUID getLocalIPAddress:YES]);
            }
            
        }
    });
    
    WeakSelf
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       STRONGSELF
        if(strongSelf == nil){
            return;
        }
        NSError *error;
        NSURL *ipURL = [NSURL URLWithString:@"http://ip-api.com/json/?lang=zh-CN"];
        NSMutableString *ip = [NSMutableString stringWithContentsOfURL:ipURL encoding:NSUTF8StringEncoding error:&error];
        if(ip != nil){
            NSData * data = [ip dataUsingEncoding:NSUTF8StringEncoding];
            if(data != nil){
                NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if(dict!= nil){
                    NSString *countryCode = [dict objectForKey:@"countryCode"];
                    if(countryCode!= nil && countryCode.length){
                        [XYDeviceInfoUUID sharedInstance].locale = countryCode;
                    }
                    NSString *ipStr = [dict objectForKey:@"query"];
                    if([XYDeviceInfoUUID checkIPAddreddIsValid:ipStr ipv4Type:YES]){
                        [XYDeviceInfoUUID sharedInstance].ip4String = ipStr;
//                        return ipStr ? ipStr : @"";
                        if(!isCallback){
                            isCallback = true;
                            dispatch_main_async_safe(^{
                                completionHandler(ipStr);
                            });
                            
                        }
                        
                        return;
                    }
                   
                }
            }
            
        }
        
        ipURL = [NSURL URLWithString:@"https://www.taobao.com/help/getip.php"];
        ip = [NSMutableString stringWithContentsOfURL:ipURL encoding:NSUTF8StringEncoding error:&error];
        //判断返回字符串是否为所需数据
        if (ip!= nil && [ip hasPrefix:@"ipCallback({ip:"] && ip.length>16) {
            //对字符串进行处理，然后进行json解析
            //删除字符串多余字符串
            NSRange range = NSMakeRange(0, 16);
            [ip deleteCharactersInRange:range];
            if(ip.length>3){
                NSString * nowIp =[ip substringToIndex:ip.length-3];
                if([XYDeviceInfoUUID checkIPAddreddIsValid:nowIp ipv4Type:YES]){
                    [XYDeviceInfoUUID sharedInstance].ip4String = nowIp;
//                    return nowIp ? nowIp : @"";
                    if(!isCallback){
                        isCallback = true;
                        dispatch_main_async_safe(^{
                            completionHandler(nowIp);
                        });
                    }
                    return;
                }
            }
            
            
        }
        
        ipURL = [NSURL URLWithString:@"https://ip.qiyutech.tech"];
        ip = [NSMutableString stringWithContentsOfURL:ipURL encoding:NSUTF8StringEncoding error:&error];
        //判断返回字符串是否为所需数据
        if([XYDeviceInfoUUID checkIPAddreddIsValid:ip ipv4Type:YES]){
            [XYDeviceInfoUUID sharedInstance].ip4String = ip;
            //            return ip ? ip : @"";
            if(!isCallback){
                isCallback = true;
                dispatch_main_async_safe(^{
                    completionHandler(ip);
                });
            }
            return;
        }
        
        if(!isCallback){
            isCallback = true;
            dispatch_main_async_safe(^{
                completionHandler([XYDeviceInfoUUID getLocalIPAddress:YES]);
            });
        }
       
    });
}

/**
 判断ip地址是否有效
 @param ipAddress ip地址
 @param isIPV4 YES是ipv4地址，NO是ipv6地址
 */
+(BOOL)checkIPAddreddIsValid:(NSString*)ipAddress ipv4Type:(BOOL)isIPV4
{
    if (ipAddress== nil || (ipAddress!= nil && ipAddress.length == 0)) {
        return NO;
    }
    
    NSString*strReguEx = nil;
    
    if (isIPV4) {
        
        if(ipAddress != nil &&[ipAddress containsString:@"127.0.0"]){
            return  NO;
        }
        strReguEx = @"^(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3}$";
    }else{
        strReguEx = @"^((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:)|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}(:[0-9A-Fa-f]{1,4}){1,2})|(([0-9A-Fa-f]{1,4}:){4}(:[0-9A-Fa-f]{1,4}){1,3})|(([0-9A-Fa-f]{1,4}:){3}(:[0-9A-Fa-f]{1,4}){1,4})|(([0-9A-Fa-f]{1,4}:){2}(:[0-9A-Fa-f]{1,4}){1,5})|([0-9A-Fa-f]{1,4}:(:[0-9A-Fa-f]{1,4}){1,6})|(:(:[0-9A-Fa-f]{1,4}){1,7})|(([0-9A-Fa-f]{1,4}:){6}(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3})|(([0-9A-Fa-f]{1,4}:){5}:(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3})|(([0-9A-Fa-f]{1,4}:){4}(:[0-9A-Fa-f]{1,4}){0,1}:(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3})|(([0-9A-Fa-f]{1,4}:){3}(:[0-9A-Fa-f]{1,4}){0,2}:(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3})|(([0-9A-Fa-f]{1,4}:){2}(:[0-9A-Fa-f]{1,4}){0,3}:(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3})|([0-9A-Fa-f]{1,4}:(:[0-9A-Fa-f]{1,4}){0,4}:(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3})|(:(:[0-9A-Fa-f]{1,4}){0,5}:(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3}))$";
    }
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:strReguEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        return firstMatch;
    }
    return NO;
}

@end
