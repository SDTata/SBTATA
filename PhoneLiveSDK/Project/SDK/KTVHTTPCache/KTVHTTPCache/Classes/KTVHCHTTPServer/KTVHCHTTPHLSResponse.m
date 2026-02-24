//
//  KTVHCHTTPHLSResponse.m
//  KTVHTTPCache
//
//  Created by Gary Zhao on 2024/1/7.
//  Copyright © 2024 Single. All rights reserved.
//

#import "KTVHCHTTPHLSResponse.h"
#import "KTVHCHTTPConnection.h"
#import "KTVHCDataUnitPool.h"
#import "KTVHCDataStorage.h"
#import "KTVHCDownload.h"
#import "KTVHCPathTool.h"
#import "KTVHCLog.h"
#import <SkyShield/SkyShield.h>


// 自定义的 NSURLSessionDelegate 类，用于处理 SSL 证书验证挑战
@interface KTVHCTrustAllCertificatesSessionDelegate : NSObject <NSURLSessionDelegate>
@end

@implementation KTVHCTrustAllCertificatesSessionDelegate

// 处理 SSL 证书验证挑战 - 会话级别
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // 无条件信任所有证书
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        NSLog(@"KTVHCHTTPHLSResponse - Trust all certificates at session level for host: %@", challenge.protectionSpace.host);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

// 处理 SSL 证书验证挑战 - 任务级别
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // 无条件信任所有证书
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        NSLog(@"KTVHCHTTPHLSResponse - Trust all certificates at task level for URL: %@, host: %@", task.currentRequest.URL, challenge.protectionSpace.host);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

@end

@interface KTVHCHTTPHLSResponse ()

@property (nonatomic, weak) KTVHCHTTPConnection *connection;

@property (nonatomic) UInt64 readedLength;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) KTVHCDataUnit *unit;
@property (nonatomic, strong) NSURLSessionDataTask *task;

@end

@implementation KTVHCHTTPHLSResponse

- (instancetype)initWithConnection:(KTVHCHTTPConnection *)connection dataRequest:(KTVHCDataRequest *)dataRequest
{
    if (self = [super init]) {
        KTVHCLogAlloc(self);
        KTVHCLogHTTPHLSResponse(@"%p, Create response\nrequest : %@", self, dataRequest);
        self.connection = connection;
        self.unit = [[KTVHCDataUnitPool pool] unitWithURL:dataRequest.URL];
        if (self.unit.totalLength == 0) {
            static NSURLSession *session = nil;
            static KTVHCTrustAllCertificatesSessionDelegate *sessionDelegate = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                // 创建会信任所有证书的会话代理
                sessionDelegate = [[KTVHCTrustAllCertificatesSessionDelegate alloc] init];
                
                // 配置 NSURLSessionConfiguration
                NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                configuration.timeoutIntervalForRequest = 3;
                
                // 设置 TLS 最低安全级别，使用最宽松的安全设置
                configuration.TLSMinimumSupportedProtocolVersion = kTLSProtocol1;
                
                // 创建 NSURLSession，使用自定义的代理对象来处理 SSL 证书验证
                session = [NSURLSession sessionWithConfiguration:configuration
                                                     delegate:sessionDelegate
                                                delegateQueue:nil];
            });
            __weak typeof(self) weakSelf = self;
            NSURLRequest *request = [[KTVHCDownload download] requestWithDataRequest:dataRequest];
            self.task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf handleResponeWithData:data response:response error:error];
            }];
            [self.task resume];
        } else {
//            self.data = [NSData dataWithContentsOfURL:self.unit.completeURL];
//            NSString *string = [[NSString alloc] initWithData:self.data  encoding:NSUTF8StringEncoding];
//            if (![string containsString:@"#EXTM3U"]) {
                [self.unit workingRelease];
                [[KTVHCDataUnitPool pool] deleteUnitWithURL:dataRequest.URL];
               
                static NSURLSession *session = nil;
                static KTVHCTrustAllCertificatesSessionDelegate *sessionDelegate = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    // 创建会信任所有证书的会话代理
                    sessionDelegate = [[KTVHCTrustAllCertificatesSessionDelegate alloc] init];
                    
                    // 配置 NSURLSessionConfiguration
                    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                    configuration.timeoutIntervalForRequest = 3;
                    
                    // 设置 TLS 最低安全级别，使用最宽松的安全设置
                    configuration.TLSMinimumSupportedProtocolVersion = kTLSProtocol1;
                    
                    // 创建 NSURLSession，使用自定义的代理对象来处理 SSL 证书验证
                    session = [NSURLSession sessionWithConfiguration:configuration
                                                         delegate:sessionDelegate
                                                    delegateQueue:nil];
                });
                __weak typeof(self) weakSelf = self;
                NSURLRequest *request = [[KTVHCDownload download] requestWithDataRequest:dataRequest];
                self.task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [strongSelf handleResponeWithData:data response:response error:error];
                }];
                [self.task resume];
                
//            }else{
//                
////                [self.unit workingRelease];
////                [[KTVHCDataUnitPool pool] deleteUnitWithURL:dataRequest.URL];
//                [self.connection responseHasAvailableData:self];
//            }
           
        }
    }
    return self;
}

- (void)dealloc
{
    [self.unit workingRelease];
    [self.task cancel];
    KTVHCLogDealloc(self);
}

#pragma mark - HTTPResponse

- (void)handleResponeWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error
{
    if (error || data.length == 0 || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
        [self.unit workingRelease];
        [[KTVHCDataUnitPool pool] deleteUnitWithURL:self.unit.URL];
        [self.connection responseDidAbort:self];
        KTVHCLogHTTPHLSResponse(@"%p, Handle response error: %@\nresponse : %@", self, error, response);
    } else {
        NSString *path = [KTVHCPathTool filePathWithURL:self.unit.URL offset:0];
        data = [self handleResponeWithData:data];
        if ([data writeToFile:path atomically:YES]) {
            self.data = data;
            KTVHCDataUnitItem *unitItem = [[KTVHCDataUnitItem alloc] initWithPath:path offset:0];
            [unitItem updateLength:data.length];
            [self.unit insertUnitItem:unitItem];
            [self.unit updateResponseHeaders:((NSHTTPURLResponse *)response).allHeaderFields totalLength:data.length];
            [self.connection responseHasAvailableData:self];
        } else {
            [self.unit workingRelease];
            [[KTVHCDataUnitPool pool] deleteUnitWithURL:self.unit.URL];
            [self.connection responseDidAbort:self];
        }
    }
}

- (NSData *)handleResponeWithData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    KTVHCLogHTTPHLSResponse(@"%p, Handle response data : %@", self, string);
    NSArray *methods = [string componentsSeparatedByString:@"EXT-X-KEY:METHOD"];
    if (methods.count > 2) {
        // 验证M3U8文件
        if (![string containsString:@"#EXTM3U"]) {
            return nil;
        }

        // 获取原始域名和基础路径
        NSString *originalURLString = self.unit.URL.absoluteString;
        NSRange protocolRange = [originalURLString rangeOfString:@"://"];
        NSString *host = nil;
        NSString *basePath = nil;

        if (protocolRange.location != NSNotFound) {
            NSString *afterProtocol = [originalURLString substringFromIndex:protocolRange.location + protocolRange.length];
            NSRange lastSlashRange = [afterProtocol rangeOfString:@"/" options:NSBackwardsSearch];
            if (lastSlashRange.location != NSNotFound) {
                host = [afterProtocol substringToIndex:[afterProtocol rangeOfString:@"/"].location];
                basePath = [originalURLString substringToIndex:protocolRange.location + protocolRange.length + lastSlashRange.location];
            }
        }

        // 处理所有相对路径
        NSArray *lines = [string componentsSeparatedByString:@"\n"];
        NSMutableArray *newLines = [NSMutableArray array];

        for (NSString *line in lines) {
            NSString *newLine = line;

            if ([line hasPrefix:@"#EXT-X-KEY"]) {
                // 处理key文件路径
                NSRange uriRange = [line rangeOfString:@"URI=\""];
                if (uriRange.location != NSNotFound) {
                    NSInteger startIndex = uriRange.location + uriRange.length;
                    NSRange endQuoteRange = [line rangeOfString:@"\"" options:0 range:NSMakeRange(startIndex, line.length - startIndex)];
                    if (endQuoteRange.location != NSNotFound) {
                        NSString *keyPath = [line substringWithRange:NSMakeRange(startIndex, endQuoteRange.location - startIndex)];
                        NSString *fullKeyURL;
                        if ([keyPath hasPrefix:@"/"]) {
                            fullKeyURL = [NSString stringWithFormat:@"http://%@%@", host, keyPath];
                        } else if (![keyPath containsString:@"://"]) {
                            fullKeyURL = [NSString stringWithFormat:@"%@/%@", basePath, keyPath];
                        } else {
                            fullKeyURL = keyPath;
                        }
                        newLine = [line stringByReplacingCharactersInRange:NSMakeRange(startIndex, endQuoteRange.location - startIndex) withString:fullKeyURL];
                    }
                }
            } else if (![line hasPrefix:@"#"] && line.length > 0) {
                // 处理ts文件路径
                if ([line hasPrefix:@"/"]) {
                    newLine = [NSString stringWithFormat:@"http://%@%@", host, line];
                } else if (![line containsString:@"://"]) {
                    newLine = [NSString stringWithFormat:@"%@/%@", basePath, line];
                }
            }

            [newLines addObject:newLine];
        }

        NSString *newContent = [newLines componentsJoinedByString:@"\n"];
        return [newContent dataUsingEncoding:NSUTF8StringEncoding];
    }

    if ([string containsString:@"\nhttp"]) {
        NSMutableArray *array = [string componentsSeparatedByString:@"\n"].mutableCopy;
        for (NSUInteger index = 0; index < array.count; index++) {
            NSString *line = array[index];
            if ([line hasPrefix:@"http"]) {
                line = [@"./" stringByAppendingString:line];
                [array replaceObjectAtIndex:index withObject:line];
            }
        }
        string = [array componentsJoinedByString:@"\n"];
        data = [string dataUsingEncoding:NSUTF8StringEncoding];
        KTVHCLogHTTPHLSResponse(@"%p, Handle response data changed : %@", self, string);
    }else{
        if (![string containsString:@"#EXTM3U"]) {
            return nil;
        }
    }
    return data;
}

- (NSData *)readDataOfLength:(NSUInteger)length
{
    KTVHCLogHTTPHLSResponse(@"%p, Read data : %lld", self, (long long)self.data.length);
    self.readedLength = self.data.length;
    return self.data;
}

- (BOOL)delayResponseHeaders
{
    KTVHCLogHTTPHLSResponse(@"%p, Delay response : %d", self, self.self.data.length == 0);
    return self.data.length == 0;
}

- (UInt64)contentLength
{
    KTVHCLogHTTPHLSResponse(@"%p, Conetnt length : %lld", self, self.unit.totalLength);
    return self.data.length;
}

- (NSDictionary *)httpHeaders
{
    KTVHCLogHTTPHLSResponse(@"%p, Header\n%@", self, self.unit.responseHeaders);
    return self.unit.responseHeaders;
}

- (UInt64)offset
{
    KTVHCLogHTTPHLSResponse(@"%p, Offset : %lld", self, self.readedLength);
    return self.readedLength;
}

- (void)setOffset:(UInt64)offset
{
    KTVHCLogHTTPHLSResponse(@"%p, Set offset : %lld, %ld", self, offset, self.data.length);
}

- (BOOL)isDone
{
    KTVHCLogHTTPHLSResponse(@"%p, Check done : %lld", self, self.unit.totalLength);
    return self.readedLength > 0;
}

- (void)connectionDidClose
{
    KTVHCLogHTTPHLSResponse(@"%p, Connection did closed : %lld, %lld", self, self.unit.totalLength, self.unit.cacheLength);
    [self.task cancel];
}

@end
