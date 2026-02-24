//
//  HHTools.m
//  HSShareSDK
//
//  Created by aa on 2020/10/15.
//

#import "HHTools.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

//#define Purl @"http://192.168.31.143:8680/"//测试
//#define Purl @"http://18.166.115.70:16888/"//70
//#define Purl @"http://101.36.110.143:16888/"//预发布
//#define Purl @"https://report.piweipaihz.com/" //正式
//#define Purl @"https://api.tianmaoyihao10.com/" //正式
//#define BucketKey @"hellobucket12456789ojbkhahahahaa"

//盘口标示
#define Identify  [[NSBundle mainBundle].infoDictionary objectForKey:@"com.HHTrace.merchant_flag"]==nil?@"":[[NSBundle mainBundle].infoDictionary objectForKey:@"com.HHTrace.merchant_flag"]


@interface HHTools ()
@property(nonatomic,strong)NSString *pasteboardSt;
@end
static HHTools *_instance;

@implementation HHTools

/**
 初始化
 */
+ (HHTools *)shareInstance{
    
    @synchronized(self)
    {
        if (_instance == nil)
        {
            _instance = [[HHTools alloc]init];
            _instance.pasteboardSt = [[NSUserDefaults standardUserDefaults]objectForKey:@"pasteboardSt_hhtraceSDK"];
//            _instance.hostUrl = Purl;
        }
        return _instance;
    }
}


//    https://前缀 + bucketname.s3.ap-east-1.amazonaws.com/盘口标识.json  //阿里
//    https://storage.googleapis.com/前缀 + bucketname/盘口标识.json      //谷歌
//    https://前缀 + bucketname + 阿里云bucket域名/盘口标识.json            //亚马逊

//获取动态地址type 1 阿里 2 谷歌 3 亚马逊
//+(NSString*)getinitUrlWithType:(NSInteger)type{
//    if (type==1) {
//        return [NSString stringWithFormat:@"https://%@.oss-cn-hongkong.aliyuncs.com/%@.json?_t=abc%@",[HHTools getBucketNameString],Identify,[HHTools gs_getCurrentTimeBySecond]];
//    }else if (type==2) {
//        return [NSString stringWithFormat:@"https://storage.googleapis.com/%@/%@.json?_t=abc%@",[HHTools getBucketNameString],Identify,[HHTools gs_getCurrentTimeBySecond]];
//    }else{
//        return [NSString stringWithFormat:@"https://%@.s3.ap-east-1.amazonaws.com/%@.json?_t=abc%@",[HHTools getBucketNameString],Identify,[HHTools gs_getCurrentTimeBySecond]];
//    }
//}

//请求阿里
+(void)getAlidynAddress:(SuccessBlock)successBlock{
    if ([HHTools shareInstance].hostUrl.length>0) {
        successBlock([HHTools shareInstance].hostUrl);
        return;
    }
//    NSString *mutableUrl = [HHTools getinitUrlWithType:1];
//    NSLog(@"----阿里资源地址:%@----",mutableUrl);
//    NSURLRequest *urlRequest =  [NSMutableURLRequest requestWithURL:[NSURL URLWithString:mutableUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
//    NSURLSession *urlSession = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"----阿里域名地址获取失败----");
//            NSLog(@"%@",error);
//            [HHTools getGoogledynAddress:^(NSString *urlString) {
//                successBlock(urlString);
//            }];
//        } else {
//            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//            if (httpResponse.statusCode == 200) {
//                NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                str = [HHTools DecryptString:str];
//                if (str.length>0) {
//                    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
//                    NSError *err;
//                    id dic = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                                        options:NSJSONReadingMutableContainers
//                                                                          error:&err];
//                    NSLog(@"----阿里域名地址:%@",dic);
//                    if ([dic isKindOfClass:[NSArray class]]) {
//                        if ([dic count]>0) {
//                            successBlock([dic firstObject]);
//                        }
//                        else{
//                            NSLog(@"----阿里域名地址数组为空----");
//                            [HHTools getGoogledynAddress:^(NSString *urlString) {
//                                successBlock(urlString);
//                            }];
//                        }
//                    }else{
//                        NSLog(@"----阿里域名地址错误:约定是数组，返回不是数组----");
//                        [HHTools getGoogledynAddress:^(NSString *urlString) {
//                            successBlock(urlString);
//                        }];
//                    }
//                }else{
//                    NSLog(@"----阿里域名地址解密失败----");
//                    [HHTools getGoogledynAddress:^(NSString *urlString) {
//                        successBlock(urlString);
//                    }];
//                }
//            }
//            else{
//                NSLog(@"----%ld----阿里域名地址获取失败----",(long)httpResponse.statusCode);
//                [HHTools getGoogledynAddress:^(NSString *urlString) {
//                    successBlock(urlString);
//                }];
//            }
//        }
//    }];
//    [dataTask resume];
}

//请求谷歌
//+(void)getGoogledynAddress:(SuccessBlock)successBlock{
//    NSString *mutableUrl = [HHTools getinitUrlWithType:2];
//    NSLog(@"----谷歌资源地址:%@----",mutableUrl);
//    NSURLRequest *urlRequest =  [NSMutableURLRequest requestWithURL:[NSURL URLWithString:mutableUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
//    NSURLSession *urlSession = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"----谷歌域名地址获取失败----");
//            NSLog(@"%@",error);
//            [HHTools getAwsdynAddress:^(NSString *urlString) {
//                successBlock(urlString);
//            }];
//        } else {
//            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//            if (httpResponse.statusCode == 200) {
//                NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                str = [HHTools DecryptString:str];
//                if (str.length>0) {
//                    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
//                    NSError *err;
//                    id dic = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                                        options:NSJSONReadingMutableContainers
//                                                                          error:&err];
//                    NSLog(@"----谷歌域名地址:%@",dic);
//                    if ([dic isKindOfClass:[NSArray class]]) {
//                        if ([dic count]>0) {
//                            successBlock([dic firstObject]);
//                        }
//                        else{
//                            NSLog(@"----谷歌域名地址数组为空----");
//                            [HHTools getAwsdynAddress:^(NSString *urlString) {
//                                successBlock(urlString);
//                            }];
//                        }
//                    }else{
//                        NSLog(@"----谷歌域名地址错误:约定是数组，返回不是数组----");
//                        [HHTools getAwsdynAddress:^(NSString *urlString) {
//                            successBlock(urlString);
//                        }];
//                    }
//                }else{
//                    NSLog(@"----谷歌域名地址解密失败----");
//                    [HHTools getAwsdynAddress:^(NSString *urlString) {
//                        successBlock(urlString);
//                    }];
//                }
//            }
//            else{
//                NSLog(@"----%ld----谷歌域名地址获取失败----",(long)httpResponse.statusCode);
//                [HHTools getAwsdynAddress:^(NSString *urlString) {
//                    successBlock(urlString);
//                }];
//            }
//        }
//    }];
//    [dataTask resume];
//}

////请求亚马逊
//+(void)getAwsdynAddress:(SuccessBlock)successBlock{
//    NSString *mutableUrl = [HHTools getinitUrlWithType:3];
//    NSLog(@"----亚马逊资源地址:%@----",mutableUrl);
//    NSURLRequest *urlRequest =  [NSMutableURLRequest requestWithURL:[NSURL URLWithString:mutableUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
//    NSURLSession *urlSession = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"----亚马逊域名地址获取失败----");
//            NSLog(@"%@",error);
//            [HHTools getStringSuccess:^(NSString *urlString) {
//                successBlock(urlString);
//            }];
//        } else {
//            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//            if (httpResponse.statusCode == 200) {
//                NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                str = [HHTools DecryptString:str];
//                if (str.length>0) {
//                    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
//                    NSError *err;
//                    id dic = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                                        options:NSJSONReadingMutableContainers
//                                                                          error:&err];
//                    NSLog(@"----亚马逊域名地址:%@",dic);
//                    if ([dic isKindOfClass:[NSArray class]]) {
//                        if ([dic count]>0) {
//                            successBlock([dic firstObject]);
//                        }
//                        else{
//                            NSLog(@"----亚马逊域名地址数组为空----");
//                            [HHTools getStringSuccess:^(NSString *urlString) {
//                                successBlock(urlString);
//                            }];
//                        }
//                    }else{
//                        NSLog(@"----亚马逊域名地址错误:约定是数组，返回不是数组----");
//                        [HHTools getStringSuccess:^(NSString *urlString) {
//                            successBlock(urlString);
//                        }];
//                    }
//                }else{
//                    NSLog(@"----亚马逊域名地址解密失败----");
//                    [HHTools getStringSuccess:^(NSString *urlString) {
//                        successBlock(urlString);
//                    }];
//                }
//            }else{
//                NSLog(@"----%ld----亚马逊域名地址获取失败----",(long)httpResponse.statusCode);
//                [HHTools getStringSuccess:^(NSString *urlString) {
//                    successBlock(urlString);
//                }];
//            }
//        }
//    }];
//    [dataTask resume];
//}

//GET请求
//+ (void)getStringSuccess:(SuccessBlock)successBlock{
//
//    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"https://dfhecb4tdxiq2.cloudfront.net/%@.url",[[NSBundle mainBundle].infoDictionary objectForKey:@"com.HHTrace.APP_KEY"]]];
//    NSLog(@"----备用资源地址:%@----",mutableUrl);
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:mutableUrl]];
//    NSURLSession *urlSession = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"----备用域名地址获取失败----");
//            NSLog(@"%@",error);
//        } else {
//            NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"----备用域名地址:%@----",str);
//            if (str) {
//                successBlock(str);
//            }else{
//                NSLog(@"----备用域名解析错误----");
//            }
//        }
//    }];
//    [dataTask resume];
//}
//GET请求
+ (void)getWithUrlString:(NSString *)url parameters:(id)parameters success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock
{
    [HHTools getAlidynAddress:^(NSString *urlString) {
        NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@%@",urlString,url]];
        if ([parameters allKeys]) {
            [mutableUrl appendString:@"?"];
            for (id key in parameters) {
                NSString *value = [[parameters objectForKey:key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [mutableUrl appendString:[NSString stringWithFormat:@"%@=%@&", key, value]];
            }
        }
        NSString *urlEnCode = [[mutableUrl substringToIndex:mutableUrl.length - 1] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlEnCode]];
        NSURLSession *urlSession = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                failureBlock(error);
//                [HHTools shareInstance].hostUrl = @"";
            } else {
                NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;
                if (res.statusCode==200) {
                    [HHTools shareInstance].hostUrl = urlString;
                }else{
//                    [HHTools shareInstance].hostUrl = @"";
                }
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                successBlock(dic);
                NSLog(@"%@请求返回参数:%@   %ld  --%@",url,dic,(long)res.statusCode,error.description);
            }
        }];
        [dataTask resume];
    }];
}

//POST请求 使用NSMutableURLRequest可以加入请求头
+ (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock
{

    [HHTools getAlidynAddress:^(NSString *urlString) {
        NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@%@",urlString,url]];
        //如果想要设置网络超时的时间的话，可以使用下面的方法：
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:mutableUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        
        //设置请求类型
        request.HTTPMethod = @"POST";
        //把参数放到请求体内
        NSString *postStr = [HHTools parseParams:parameters];
        request.HTTPBody = [postStr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                failureBlock(error);
//                [HHTools shareInstance].hostUrl = @"";
            } else {
                NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (res.statusCode==200) {
                    [HHTools shareInstance].hostUrl = urlString;
                    successBlock(dic);
                    NSLog(@"%@请求返回参数:%@   %ld",url,dic,(long)res.statusCode);
                }else{
//                    [HHTools shareInstance].hostUrl = @"";
                    failureBlock(error);
                    NSLog(@"%@请求返回参数:%@   %ld  --%@",url,dic,(long)res.statusCode,error.description);
                }
            }
        }];
        [dataTask resume];  //开始请求
    }];
   
}

//重新封装参数 加入app相关信息
+ (NSString *)parseParams:(NSDictionary *)params
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSString *keyValueFormat;
    NSMutableString *result = [NSMutableString new];
    //实例化一个key枚举器用来存放dictionary的key
   
   //加密处理 将所有参数加密后结果当做参数传递
   //parameters = @{@"i":@"加密结果 抽空加入"};
   
    NSEnumerator *keyEnum = [parameters keyEnumerator];
    id key;
    while (key = [keyEnum nextObject]) {
        keyValueFormat = [NSString stringWithFormat:@"%@=%@&", key, [params valueForKey:key]];
        [result appendString:keyValueFormat];
    }
    NSString *resultS = [NSString stringWithString:result];
    resultS = [resultS substringWithRange:NSMakeRange(0, resultS.length-1)];
    return resultS;
}

//bucketname 加密字符串
//+(NSString *)getBucketNameString{
//
//    return [HHTools md5:[NSString stringWithFormat:@"%@%@",[HHTools getCurrentDateString],BucketKey]];
//}

////获取当前日期
//+(NSString *)getCurrentDateString{
//
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    //----------格式,hh与HH的区别:分别表示12小时制,24小时制
//    [formatter setDateFormat:@"yyyyMMddHH"]; //yyyyMMddHHmmss  yyyymmddhhmmss
//    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];//东八区时间
//    NSDate *datenow = [NSDate date];
//    //----------将nsdate按formatter格式转成nsstring
//    NSString *currentTimeString = [formatter stringFromDate:datenow];
//    NSLog(@"----%@----",currentTimeString);
//    return currentTimeString;
//}


//+ (NSString *)md5:(NSString *)string {
//    const char *cStr = [string UTF8String];
//    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
//    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
//    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
//        [result appendFormat:@"%02x", digest[i]];
//    }
//    if (result.length>26) {
//        NSMutableString *str = [NSMutableString stringWithString:result];
//        NSLog(@"---BucketName_origin:%@",str);
//        NSLog(@"---BucketName_final:%@",[str substringWithRange:NSMakeRange(8,18)]);
//        return [str substringWithRange:NSMakeRange(8,18)];
//    }
//    return @"";
//}


//+ (NSString *)DecryptString:(NSString *)secretStr
//{
//    //先对加密的字符串进行base64解码
//    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:secretStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
//
//    char keyPtr[kCCKeySizeAES256 + 1];
//    bzero(keyPtr, sizeof(keyPtr));
//    [BucketKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
//
//    NSUInteger dataLength = [decodeData length];
//    size_t bufferSize = dataLength + kCCBlockSizeAES128;
//    void *buffer = malloc(bufferSize);
//    size_t numBytesDecrypted = 0;
//    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCKeySizeAES256, NULL, [decodeData bytes], dataLength, buffer, bufferSize, &numBytesDecrypted);
//    if (cryptStatus == kCCSuccess) {
//        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
//        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        return result;
//    }
//    else
//    {
//        free(buffer);
//        return nil;
//    }
//}

//+ (NSString *)gs_getCurrentTimeBySecond {
//
//    double currentTime =  [[NSDate date] timeIntervalSince1970];
//
//    NSString *strTime = [NSString stringWithFormat:@"%.0f",currentTime];
//
//    return strTime;
//
//}

-(NSString*)getPasteboardString:(SuccessBlock)successBlock;
{

    if (self.pasteboardSt==nil) {
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if (@available(iOS 14.0, *)) {
            NSSet *patterns = [NSSet setWithObject:UIPasteboardDetectionPatternProbableWebURL];
            
            WeakSelf
            [[UIPasteboard generalPasteboard] detectPatternsForPatterns:patterns completionHandler:^(NSSet<UIPasteboardDetectionPattern> * _Nullable detectedPatterns, NSError * _Nullable error) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                // 仅在需要时读取剪切板
                NSString *clipboardText = pasteboard.string;
                if (clipboardText==nil) {
                    clipboardText = @"";
                }
                strongSelf.pasteboardSt = clipboardText;
                
                [[NSUserDefaults standardUserDefaults]setObject:strongSelf.pasteboardSt forKey:@"pasteboardSt_hhtraceSDK"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (successBlock) {
                        successBlock(strongSelf.pasteboardSt);
                    }
                });
                
            }];
        } else {
            if (pasteboard.string == nil) {
                self.pasteboardSt = @"";
            }else{
                self.pasteboardSt = pasteboard.string;
            }
            
            if (successBlock) {
                successBlock(self.pasteboardSt);
            }
            [[NSUserDefaults standardUserDefaults]setObject:self.pasteboardSt forKey:@"pasteboardSt_hhtraceSDK"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
       
    }else{
        
        if (successBlock) {
            successBlock(self.pasteboardSt);
        }
        
    }
    
    return self.pasteboardSt;
    
    
}



//#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
//- (NSString *)getPasteboardString:(SuccessBlock)successBlock {
//    if (self.pasteboardSt != nil) {
//        if (successBlock) {
//            successBlock(self.pasteboardSt);
//        }
//        return self.pasteboardSt;
//    }
//
//    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//
//    if (@available(iOS 16.0, *)) {
//        NSArray<NSItemProvider *> *providers = pasteboard.itemProviders;
//        BOOL foundTextProvider = NO;
//        for (NSItemProvider *provider in providers) {
//            if ([provider hasItemConformingToTypeIdentifier:UTTypePlainText.identifier]) {
//                foundTextProvider = YES;
//                [provider loadItemForTypeIdentifier:UTTypePlainText.identifier options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Nullable error) {
//                    NSString *result = @"";
//                    if ([(NSObject *)item isKindOfClass:[NSString class]]) {
//                        result = (NSString *)item;
//                    }
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        self.pasteboardSt = result ?: @"";
//                        [[NSUserDefaults standardUserDefaults] setObject:self.pasteboardSt forKey:@"pasteboardSt_hhtraceSDK"];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
//                        if (successBlock) {
//                            successBlock(self.pasteboardSt);
//                        }
//                    });
//                }];
//                break;
//            }
//        }
//        if (!foundTextProvider) {
//            // 找不到文本内容时，回调空字符串
//            self.pasteboardSt = @"";
//            [[NSUserDefaults standardUserDefaults] setObject:self.pasteboardSt forKey:@"pasteboardSt_hhtraceSDK"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            if (successBlock) {
//                successBlock(self.pasteboardSt);
//            }
//        }
//        return nil; // 异步回调，先返回nil
//    }
//    else if (@available(iOS 14.0, *)) {
//        NSSet *patterns = [NSSet setWithObject:UIPasteboardDetectionPatternProbableWebURL];
//        WeakSelf
//        [pasteboard detectPatternsForPatterns:patterns completionHandler:^(NSSet<UIPasteboardDetectionPattern> * _Nullable detectedPatterns, NSError * _Nullable error) {
//            STRONGSELF
//            if (!strongSelf) return;
//            NSString *clipboardText = pasteboard.string ?: @"";
//            strongSelf.pasteboardSt = clipboardText;
//            [[NSUserDefaults standardUserDefaults] setObject:clipboardText forKey:@"pasteboardSt_hhtraceSDK"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (successBlock) {
//                    successBlock(clipboardText);
//                }
//            });
//        }];
//        return nil; // 异步回调，先返回nil
//    }
//    else {
//        NSString *clipboardText = pasteboard.string ?: @"";
//        self.pasteboardSt = clipboardText;
//        [[NSUserDefaults standardUserDefaults] setObject:clipboardText forKey:@"pasteboardSt_hhtraceSDK"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        if (successBlock) {
//            successBlock(clipboardText);
//        }
//        return clipboardText;
//    }
//}
@end
