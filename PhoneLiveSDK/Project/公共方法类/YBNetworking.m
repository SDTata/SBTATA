//
//  YBNetworking.m
//  iphoneLive
//
//  Created by YunBao on 2018/6/6.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "YBNetworking.h"
#import "AFNetworking.h"
#import <FFAES/FFAES.h>
#import <UMCommon/UMCommon.h>
@interface YBNetworking()
{
    DataForUpload *dataModels;
}
@end



@implementation YBNetworking

MJExtensionCodingImplementation

static YBNetworking* httpManager = nil;


+(YBNetworking *)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        httpManager = [[YBNetworking alloc] init];
    });
    return httpManager;
}

//网络类初始化
- (id)init{
    self = [super init];
    if(self)
    {
        _manager = [AFHTTPSessionManager manager];
    }
    return self;
}
-(AFHTTPSessionManager*)manager
{
    return [DomainManager AFHTTPManager];
}

+(NSString*)encodePath:(NSString *)path withForm:(NSDictionary*)form  withDic:(NSDictionary*)subDic
{
    
    NSString *ivStr =[YBToolClass returnLetter:16];
    NSString *sla = [YBToolClass returnLetter:16];
    NSTimeInterval logTime = [YBToolClass LocalTime];
    NSString *timeSp = [NSString stringWithFormat:@"%.0f", logTime];
    NSString *rc2S = [NSString stringWithFormat:@"FUCKYOU|%@|%@|%@|%@|%@",timeSp,sla,path,[YBToolClass queryStringFromDictionary:form],[YBToolClass queryStringFromDictionary:subDic]];
    NSString *aes = aesEncryptString(rc2S, @"pKSgtybLRv4AwBnG", ivStr);
    NSString *resultStr = [NSString stringWithFormat:@"%@%@",ivStr,aes];
    return resultStr;
}
+(id)decodeResponseString:(NSString*)content
{
    if (content.length>16) {
        NSString *ivStr = [content substringToIndex:16];
        NSString *decodeStr = [content substringFromIndex:16];
        NSString *decodeContentStr = aesDecryptString(decodeStr,@"pKSgtybLRv4AwBnG",ivStr);
        if (decodeContentStr == nil || decodeContentStr.length<1) {
            return content;
        }
        NSDictionary *subDResu =[decodeContentStr mj_JSONObject];
        if (subDResu && subDResu.allKeys.count>0) {
            return subDResu;
        }else{
            return decodeContentStr;
        }
    }else{
        return content;
    }
    
}
//2717315919

-(void)postNetworkWithUrl:(NSString *)url withBaseDomian:(BOOL)baseDomain andParameter:(NSDictionary *)dic data:(DataForUpload*)dataModel success:(networkSuccessBlock)sucBack fail:(networkFailBlock)failBack{
    [self postNetworkWithUrl:url withBaseDomian:baseDomain andParameter:dic data:dataModel progress:nil success:sucBack fail:failBack];
    
}

-(void)postNetworkWithUrl:(NSString *)url withBaseDomian:(BOOL)baseDomain andParameter:(NSDictionary *)dic data:(DataForUpload*)dataModel progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress success:(networkSuccessBlock)sucBack fail:(networkFailBlock)failBack{

    if ([DomainManager sharedInstance].baseAPIString == nil) {
        WeakSelf
        [[DomainManager sharedInstance] getHostCallback:^(NSString *bestDomain) {
            STRONGSELF
            [strongSelf postNetworkWithUrl:url withBaseDomian:baseDomain andParameter:dic data:nil success:sucBack fail:failBack];
        } logs:nil];
        return;
    }
    if (url==nil) {
        return;
    }
    if (url.length>5) {
        NSString *firstStr = [url substringWithRange:NSMakeRange(0, 5)];
        if ([firstStr rangeOfString:@"http"].location!=NSNotFound) {
            baseDomain = NO;
        }else{
            baseDomain = YES;
        }
    }
    
    NSMutableDictionary *pDic = [dic mutableCopy];
    if (baseDomain) {
        url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=%@",url];
    }
    //语言
    if (![url containsString:[NSString stringWithFormat:@"&l=%@",[YBNetworking currentLanguageServer]]]) {
        url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    }
    
    if (pDic == nil) {
        pDic = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *dicNew = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[Config getOwnID]!=nil?[Config getOwnID]:@"",@"uid",[Config getOwnToken]!= nil?[Config getOwnToken]:@"",@"token", nil];
    [pDic addEntriesFromDictionary:dicNew];
    
    
    NSString *sign = [YBToolClass getRequestSign:url params:pDic];
    pDic[@"_sign"] = sign;
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    __block DataForUpload *dataModels = dataModel;
    
    BOOL openCryption = serverVersion.length>0;
    if ([url containsString:@"Live.createRoom"]||[url containsString:@"User.updateAvatar"]||[url containsString:@"ShortVideo.uploadCover"]||serverVersion.length<1) {
        openCryption = NO;
    }
    
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionaryWithDictionary: @{@"eh":[YBNetworking encodePath:[url stringByReplacingOccurrencesOfString:[DomainManager sharedInstance].domainGetString withString:@""] withForm:@{} withDic:pDic]}];
    NSString *urlCryption = [DomainManager sharedInstance].domainGetString;
    NSString *urlRequest = openCryption?urlCryption:url;
    NSURL *urlRe = [NSURL URLWithString:urlRequest];
    if (urlRe) {
        if ([SkyShield shareInstance].dohLists && [SkyShield shareInstance].dohLists.count>0) {
            if (urlRe.host && ![urlRe.host containsString:@"127.0.0"]) {
                [headerDic setObject:urlRe.host forKey:@"Host"];
               
                NSString *requestUrlS = urlRe.absoluteString;
                if (requestUrlS) {
                    urlRequest = [[SkyShield shareInstance] replaceUrlHostToDNS:requestUrlS];
                }
            }
        }
    }
     WeakSelf
    [self.manager POST:urlRequest parameters:openCryption?nil:pDic headers:headerDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [YBNetworking sharedManager].manager.requestSerializer.timeoutInterval = 20;
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (dataModels!=nil && dataModels.datas != nil) {
            [formData appendPartWithFileData:dataModels.datas name:dataModels.name fileName:dataModels.filename mimeType:dataModels.mimeType];
        }
    } progress:uploadProgress success:^(NSURLSessionDataTask *task, id responseObject1) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSDictionary *headers = [httpResponse allHeaderFields];
        NSDictionary *responseObject;
        if ([[headers objectForKey:@"be"] boolValue]) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject1 encoding:NSUTF8StringEncoding];
            responseObject = [YBNetworking decodeResponseString:responseStr];
            if ([responseObject isKindOfClass:[NSString class]]) {
                responseObject = [responseObject1 mj_JSONObject];
            }
        }else{
            if (openCryption) {
                responseObject = @{@"ret":@404};
                [[DomainManager sharedInstance] getHostCallback:^(NSString *bestDomain) {
                    
                } logs:nil];
                
            }else{
                responseObject = [responseObject1 mj_JSONObject];
            }
         
        }
        VKLOG(@"✅请求POST地址：%@\n✅请求参数：%@\n✅请求结果：%@", url, pDic, responseObject);
        NSNumber *number = [responseObject valueForKey:@"ret"] ;
        if([number isEqualToNumber:[NSNumber numberWithInt:200]])
        {
            NSArray *data = [responseObject valueForKey:@"data"];
            int code = [minstr([data valueForKey:@"code"]) intValue];
            NSArray *info = [data valueForKey:@"info"];
            dispatch_main_async_safe((^{
                sucBack(code,info,minstr([data valueForKey:@"msg"]));
                if (code == 700) {
                    [MBProgressHUD hideHUD];
                    if (![PublicObj checkNull:[data valueForKey:@"msg"]]) {
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@.",minstr([data valueForKey:@"msg"])]];
                    }
                    
                    [[YBToolClass sharedInstance] quitLogin:YES];
                }else{
                    
                }
            }));
        }else{
            dispatch_main_async_safe((^{
                if ([task.currentRequest.URL.absoluteString rangeOfString:@"Login.guestLogin"].location!=NSNotFound){
                    if (failBack) {
                        failBack([responseObject valueForKey:@"msg"]);
                    }
                }
                if ([Config getOwnID]<=0 && [[responseObject valueForKey:@"msg"] isKindOfClass:[NSString class]] && [[responseObject valueForKey:@"msg"] rangeOfString:@"uid = 0"].location!=NSNotFound) {
                    if (failBack) {
                        failBack([responseObject valueForKey:@"msg"]);
                    }
                    
                    [MBProgressHUD hideHUD];
                    return;
                }
                [MBProgressHUD hideHUD];
                if (![PublicObj checkNull:[responseObject valueForKey:@"msg"]]) {
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@~",minstr([responseObject valueForKey:@"msg"])]];
                    if (failBack) {
                        failBack([responseObject valueForKey:@"msg"]);
                    }
                }
                
            }));
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error)     {
        
        VKLOG(@"❌请求POST地址：%@\n❌请求参数：%@\n❌请求失败：%@\n❌请求失败信息：%@", url, pDic, error.localizedDescription, error);
        NSDictionary *dict = @{@"uid":[Config getOwnID]?:@"",@"url" : url, @"msg" :error.localizedDescription,@"msgR":error.description,@"msgcode":minnum(error.code)};
        [MobClick event:@"errorMsg" attributes:dict];
        
        // [MBProgressHUD showError:YZMsg(@"网络错误")];
        //必须判断failback是否存在
        dispatch_main_async_safe(^{
            if (failBack) {
                failBack(error);
            }
            NSString *url = task.currentRequest.URL.absoluteString;
            
            if (error.code<500) {
                [[DomainManager sharedInstance] getHostCallback:^(NSString *bestDomain) {
                    if (([url rangeOfString:@"Home.getHot"].location!=NSNotFound | [url rangeOfString:@"Home.getLiveListByType"].location!=NSNotFound |[url rangeOfString:@"Home.getFollow"].location!=NSNotFound) && [[dic objectForKey:@"p"] integerValue] != 1) {
                        if (failBack) {
                            failBack(error);
                        }
                        return;
                    }
                    if (error.code == -1005||error.code == -1003||error.code == -1001||error.code == 22) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            if (([url rangeOfString:@"getConfig"].location!=NSNotFound)|
                                ([url rangeOfString:@"getBaseInfo"].location!=NSNotFound)|
                                ([url rangeOfString:@"getDomainList"].location!=NSNotFound)|
                                ([url rangeOfString:@"getHot"].location!=NSNotFound)|
                                ([url rangeOfString:@"getLiveListByType"].location!=NSNotFound)|
                                ([url rangeOfString:@"getFollow"].location!=NSNotFound)|
                                ([url rangeOfString:@"getClassLive"].location!=NSNotFound)|
                                ([url rangeOfString:@"profitList"].location!=NSNotFound)|
                                ([url rangeOfString:@"consumeList"].location!=NSNotFound)|
                                ([url rangeOfString:@"getFollowsList"].location!=NSNotFound)|
                                ([url rangeOfString:@"getFansList"].location!=NSNotFound)|
                                ([url rangeOfString:@"getLiverecord"].location!=NSNotFound)|
                                ([url rangeOfString:@"ShortVideo.playVideo"].location!=NSNotFound)|
                                ([url rangeOfString:@"Skit.playSkit"].location!=NSNotFound)|
                                ([url rangeOfString:@"Movie.playMovie"].location!=NSNotFound)|
                                ([url rangeOfString:@"getPerSetting"].location!=NSNotFound)|
                                ([url rangeOfString:@"roomCharge"].location!=NSNotFound)|
                                ([url rangeOfString:@"timeCharge"].location!=NSNotFound)|
                                ([url rangeOfString:@"sendBarrage"].location!=NSNotFound)|
                                ([url rangeOfString:@"getGiftList"].location!=NSNotFound)|
                                ([url rangeOfString:@"getCoin"].location!=NSNotFound)|
                                ([url rangeOfString:@"GetUserLabel"].location!=NSNotFound)|
                                ([url rangeOfString:@"GetMyLabel"].location!=NSNotFound)|
                                ([url rangeOfString:@"getUserHome"].location!=NSNotFound)|
                                ([url rangeOfString:@"getProfit"].location!=NSNotFound)|
                                ([url rangeOfString:@"GetUserAccountList"].location!=NSNotFound)|
                                ([url rangeOfString:@"getBalance"].location!=NSNotFound)|
                                ([url rangeOfString:@"getBalanceNew"].location!=NSNotFound)|
                                ([url rangeOfString:@"getWithdraw"].location!=NSNotFound)|
                                ([url rangeOfString:@"search"].location!=NSNotFound)|
                                ([url rangeOfString:@"getUserLists"].location!=NSNotFound)|
                                ([url rangeOfString:@"Guard.getList"].location!=NSNotFound)|
                                ([url rangeOfString:@"Guard.GetGuardList"].location!=NSNotFound)|
                                ([url rangeOfString:@"Red.GetRedList"].location!=NSNotFound)|
                                ([url rangeOfString:@"GetRedRobList"].location!=NSNotFound)|
                                ([url rangeOfString:@"Message.GetList"].location!=NSNotFound)|
                                ([url rangeOfString:@"getPopularizeInfo"].location!=NSNotFound)|
                                ([url rangeOfString:@"getPlats"].location!=NSNotFound)|
                                ([url rangeOfString:@"getGameWithdrawHistory"].location!=NSNotFound)|
                                ([url rangeOfString:@"getLotteryList"].location!=NSNotFound)|
                                ([url rangeOfString:@"getBetViewInfo"].location!=NSNotFound)|
                                ([url rangeOfString:@"getOpenHistory"].location!=NSNotFound)|
                                ([url rangeOfString:@"getOpenAwardList"].location!=NSNotFound)|
                                ([url rangeOfString:@"getPayConfig"].location!=NSNotFound)|
                                ([url rangeOfString:@"getDayGiftRank"].location!=NSNotFound)|
                                ([url rangeOfString:@"getLiveStatus"].location!=NSNotFound)|
                                ([url rangeOfString:@"getHomeBetViewInfo"].location!=NSNotFound)|
                                ([url rangeOfString:@"checkActive"].location!=NSNotFound)|
                                ([url rangeOfString:@"getTaskList"].location!=NSNotFound)|
                                ([url rangeOfString:@"Live.changeLive"].location!=NSNotFound)){
                                if (sucBack) {
                                    
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        
                                        [YBNetworking sharedManager].manager.requestSerializer.timeoutInterval = 10;
                                        [[YBNetworking sharedManager]postNetworkWithUrl:url withBaseDomian:baseDomain andParameter:dic data:nil success:sucBack fail:failBack];
                                    });
                                }
                            }
                        });
                    }
                } logs:nil];
            }
            
        });
    }];
}


/**
 * 获得接口名称
 * @param url 全地址(eg:xxx/api/public/?service=Video.getRecommendVideos&uid=12470&type=0&p=1)
 * @return 返回的接口名(eg:Video.getRecommendVideos)
 */
-(NSString *)getFunName:(NSString *)url{
    if (![url containsString:@"&"]) {
        url = [url stringByAppendingFormat:@"&"];
    }
    NSRange startRange = [url rangeOfString:@"="];
    NSRange endRange = [url rangeOfString:@"&"];
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    NSString *result = [url substringWithRange:range];
    return result;
}

+(void)getNetWorkWithUrl:(NSString *)url andParameter:(NSDictionary *)dic success:(networkSuccessBlock)sucBack fail:(networkFailBlock)failBack {
    [[YBNetworking sharedManager]getWithURL:url Dic:dic success:sucBack fail:failBack];
    
}

-(void)getWithURL:(NSString *)url Dic:(NSDictionary *)dic success:(networkSuccessBlock)sucBack fail:(networkFailBlock)failBack
{
    if ([DomainManager sharedInstance].baseAPIString == nil) {
        WeakSelf
        [[DomainManager sharedInstance] getHostCallback:^(NSString *bestDomain) {
            STRONGSELF
            [strongSelf getWithURL:url Dic:dic success:sucBack fail:failBack];
        } logs:nil];
        return;
    }
    if (url==nil) {
        return;
    }
    BOOL baseDomain = NO;
    if (url.length>5) {
        NSString *firstStr = [url substringWithRange:NSMakeRange(0, 5)];
        if ([firstStr rangeOfString:@"http"].location!=NSNotFound) {
            baseDomain = NO;
        }else{
            baseDomain = YES;
        }
    }
    
    NSMutableDictionary *pDic = [dic mutableCopy];
    if (baseDomain) {
        url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=%@",url];
    }
    //语言
    url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    if (pDic == nil) {
        pDic = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *dicNew = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[Config getOwnID]!=nil?minstr([Config getOwnID]):@"",@"uid",[Config getOwnToken]!= nil?minstr([Config getOwnToken]):@"",@"token", nil];
    [pDic addEntriesFromDictionary:dicNew];
    
    NSString *sign = [YBToolClass getRequestSign:url params:pDic];
    pDic[@"_sign"] = sign;
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    BOOL openCryption = serverVersion.length>0;
    if ([url containsString:@"Live.createRoom"]||[url containsString:@"User.updateAvatar"]||[url containsString:@"ShortVideo.uploadCover"]||serverVersion.length<1) {
        openCryption = NO;
    }
    
    
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionaryWithDictionary: @{@"eh":[YBNetworking encodePath:[url stringByReplacingOccurrencesOfString:[DomainManager sharedInstance].domainGetString withString:@""] withForm:pDic withDic:@{}]}];
    NSString *urlCryption = [DomainManager sharedInstance].domainGetString;
    NSString *urlRequest = openCryption?urlCryption:url;
    NSURL *urlRe = [NSURL URLWithString:urlRequest];
    if (urlRe) {
        if ([SkyShield shareInstance].dohLists && [SkyShield shareInstance].dohLists.count>0) {
            if (urlRe.host && ![urlRe.host containsString:@"127.0.0"]) {
                [headerDic setObject:urlRe.host forKey:@"Host"];
               
                NSString *requestUrlS = urlRe.absoluteString;
                if (requestUrlS) {
                    urlRequest = [[SkyShield shareInstance] replaceUrlHostToDNS:requestUrlS];
                }
            }
        }
    }
    [self.manager GET:urlRequest parameters:openCryption?nil:pDic headers:headerDic progress:nil success:^(NSURLSessionDataTask *task, id responseObject1) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSDictionary *headers = [httpResponse allHeaderFields];
        NSDictionary *responseObject;
        if ([[headers objectForKey:@"be"] boolValue]) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject1 encoding:NSUTF8StringEncoding];
            responseObject = [YBNetworking decodeResponseString:responseStr];
            if ([responseObject isKindOfClass:[NSString class]]) {
                responseObject = [responseObject1 mj_JSONObject];
            }
        }else{
            if (openCryption) {
                responseObject = nil;
                [[DomainManager sharedInstance] getHostCallback:^(NSString *bestDomain) {
                    
                } logs:nil];
            }else{
                responseObject = [responseObject1 mj_JSONObject];
            }
          
        }
        
        VKLOG(@"✅请求GET地址：%@\n✅请求头：%@\n✅请求参数：%@\n✅请求结果：%@", url, task.originalRequest.allHTTPHeaderFields, pDic, responseObject);
        
        NSNumber *number = [responseObject valueForKey:@"ret"] ;
        if([number isEqualToNumber:[NSNumber numberWithInt:200]])
        {
            NSArray *data = [responseObject valueForKey:@"data"];
            int code = [minstr([data valueForKey:@"code"]) intValue];
            NSArray *info = [data valueForKey:@"info"];
            sucBack(code,info,minstr([data valueForKey:@"msg"]));
            if (code == 700) {
                [MBProgressHUD hideHUD];
                if (![PublicObj checkNull:[data valueForKey:@"msg"]]) {
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@.",minstr([data valueForKey:@"msg"])]];
                }
                
                [[YBToolClass sharedInstance] quitLogin:YES];
            }
        }else{
            if ([Config getOwnID]<=0 && [[responseObject valueForKey:@"msg"] isKindOfClass:[NSString class]] && [[responseObject valueForKey:@"msg"] rangeOfString:@"uid = 0"].location!=NSNotFound) {
                [MBProgressHUD hideHUD];
                if (failBack) {
                    failBack([responseObject valueForKey:@"msg"]);
                }
                return;
            }
            [MBProgressHUD hideHUD];
            if (![PublicObj checkNull:[responseObject valueForKey:@"msg"]]) {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@~",minstr([responseObject valueForKey:@"msg"])]];
            }
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error)     {
        VKLOG(@"❌请求GET地址：%@\n❌请求头：%@\n❌请求参数：%@\n❌请求失败：%@\n❌请求失败信息：%@", url, task.originalRequest.allHTTPHeaderFields, pDic, error.localizedDescription, error);
        NSString *url = task.currentRequest.URL.absoluteString;
        NSDictionary *dict = @{@"uid":[Config getOwnID]?:@"",@"url" : url, @"msg" :error.localizedDescription,@"msgR":error.description,@"msgcode":minnum(error.code)};
        [MobClick event:@"errorMsg" attributes:dict];
        if (error.code<500) {
            [[DomainManager sharedInstance] getHostCallback:^(NSString *bestDomain) {
                if (([url rangeOfString:@"Home.getHot"].location!=NSNotFound | [url rangeOfString:@"Home.getLiveListByType"].location!=NSNotFound |[url rangeOfString:@"Home.getFollow"].location!=NSNotFound) && [[dic objectForKey:@"p"] integerValue] != 1) {
                    if (failBack) {
                        failBack(error);
                    }
                    return;
                }
                if (error.code == -1005||error.code == -1003||error.code == -1001||error.code == 22) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (([url rangeOfString:@"getConfig"].location!=NSNotFound)|
                            ([url rangeOfString:@"getBaseInfo"].location!=NSNotFound)|
                            ([url rangeOfString:@"getDomainList"].location!=NSNotFound)|
                            ([url rangeOfString:@"getHot"].location!=NSNotFound)|
                            ([url rangeOfString:@"getLiveListByType"].location!=NSNotFound)|
                            ([url rangeOfString:@"getFollow"].location!=NSNotFound)|
                            ([url rangeOfString:@"getClassLive"].location!=NSNotFound)|
                            ([url rangeOfString:@"profitList"].location!=NSNotFound)|
                            ([url rangeOfString:@"ShortVideo.playVideo"].location!=NSNotFound)|
                            ([url rangeOfString:@"Skit.playSkit"].location!=NSNotFound)|
                            ([url rangeOfString:@"Movie.playMovie"].location!=NSNotFound)|
                            ([url rangeOfString:@"consumeList"].location!=NSNotFound)|
                            ([url rangeOfString:@"getFollowsList"].location!=NSNotFound)|
                            ([url rangeOfString:@"getFansList"].location!=NSNotFound)|
                            ([url rangeOfString:@"getLiverecord"].location!=NSNotFound)|
                            ([url rangeOfString:@"getPerSetting"].location!=NSNotFound)|
                            ([url rangeOfString:@"roomCharge"].location!=NSNotFound)|
                            ([url rangeOfString:@"timeCharge"].location!=NSNotFound)|
                            ([url rangeOfString:@"sendBarrage"].location!=NSNotFound)|
                            ([url rangeOfString:@"getGiftList"].location!=NSNotFound)|
                            ([url rangeOfString:@"getCoin"].location!=NSNotFound)|
                            ([url rangeOfString:@"GetUserLabel"].location!=NSNotFound)|
                            ([url rangeOfString:@"GetMyLabel"].location!=NSNotFound)|
                            ([url rangeOfString:@"getUserHome"].location!=NSNotFound)|
                            ([url rangeOfString:@"getProfit"].location!=NSNotFound)|
                            ([url rangeOfString:@"GetUserAccountList"].location!=NSNotFound)|
                            ([url rangeOfString:@"getBalance"].location!=NSNotFound)|
                            ([url rangeOfString:@"getBalanceNew"].location!=NSNotFound)|
                            ([url rangeOfString:@"getWithdraw"].location!=NSNotFound)|
                            ([url rangeOfString:@"search"].location!=NSNotFound)|
                            ([url rangeOfString:@"getUserLists"].location!=NSNotFound)|
                            ([url rangeOfString:@"Guard.getList"].location!=NSNotFound)|
                            ([url rangeOfString:@"Guard.GetGuardList"].location!=NSNotFound)|
                            ([url rangeOfString:@"Red.GetRedList"].location!=NSNotFound)|
                            ([url rangeOfString:@"GetRedRobList"].location!=NSNotFound)|
                            ([url rangeOfString:@"Message.GetList"].location!=NSNotFound)|
                            ([url rangeOfString:@"getPopularizeInfo"].location!=NSNotFound)|
                            ([url rangeOfString:@"getPlats"].location!=NSNotFound)|
                            ([url rangeOfString:@"getGameWithdrawHistory"].location!=NSNotFound)|
                            ([url rangeOfString:@"getLotteryList"].location!=NSNotFound)|
                            ([url rangeOfString:@"getBetViewInfo"].location!=NSNotFound)|
                            ([url rangeOfString:@"getOpenHistory"].location!=NSNotFound)|
                            ([url rangeOfString:@"getOpenAwardList"].location!=NSNotFound)|
                            ([url rangeOfString:@"getPayConfig"].location!=NSNotFound)|
                            ([url rangeOfString:@"getDayGiftRank"].location!=NSNotFound)|
                            ([url rangeOfString:@"getLiveStatus"].location!=NSNotFound)|
                            ([url rangeOfString:@"getHomeBetViewInfo"].location!=NSNotFound)|
                            ([url rangeOfString:@"checkActive"].location!=NSNotFound)|
                            ([url rangeOfString:@"getTaskList"].location!=NSNotFound)|
                            ([url rangeOfString:@"Live.changeLive"].location!=NSNotFound)){
                            if (sucBack) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                   
                                    [YBNetworking sharedManager].manager.requestSerializer.timeoutInterval = 10;
                                    [[YBNetworking sharedManager]getWithURL:url Dic:dic success:sucBack fail:failBack];
                                });
                            }
                        }
                    });
                }
            } logs:nil];
        }
      
        
        
        if (failBack) {
            failBack(error);
        }
    }];
}
+(NSString*)currentLanguageServer
{
    return [RookieTools currentLanguageServer];
}

@end

@implementation DataForUpload

@end
