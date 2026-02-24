//
//  XHLaunchAdDownloaderManager.m
//  XHLaunchAdExample
//
//  Created by zhuxiaohui on 16/12/1.
//  Copyright © 2016年 it7090.com. All rights reserved.
//  代码地址:https://github.com/CoderZhuXH/XHLaunchAd

#import "XHLaunchAdDownloader.h"
#import "XHLaunchAdCache.h"
#import "XHLaunchAdConst.h"
#import "HttpDnsNSURLProtocolImpl.h"

#pragma mark - XHLaunchAdDownload

@interface XHLaunchAdDownload()

@property (strong, nonatomic) NSURLSession *session;
@property(strong,nonatomic)NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, assign) unsigned long long totalLength;
@property (nonatomic, assign) unsigned long long currentLength;
@property (nonatomic, copy) XHLaunchAdDownloadProgressBlock progressBlock;
@property (strong, nonatomic) NSURL *url;

@end
@implementation XHLaunchAdDownload

@end

#pragma mark -  XHLaunchAdImageDownload
@interface XHLaunchAdImageDownload()<NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate>

@property (nonatomic, copy ) XHLaunchAdDownloadImageCompletedBlock completedBlock;

@end
@implementation XHLaunchAdImageDownload

-(nonnull instancetype)initWithURL:(nonnull NSURL *)url delegateQueue:(nonnull NSOperationQueue *)queue progress:(nullable XHLaunchAdDownloadProgressBlock)progressBlock completed:(nullable XHLaunchAdDownloadImageCompletedBlock)completedBlock{
    self = [super init];
    if (self) {
        self.url = url;
        self.progressBlock = progressBlock;
        self.completedBlock = completedBlock;
        NSURLSessionConfiguration * sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForRequest = 15.0;
        sessionConfiguration.TLSMinimumSupportedProtocol = kTLSProtocol1;  // 支持更多TLS版本
        sessionConfiguration.TLSMaximumSupportedProtocol = kTLSProtocol13; // 支持到TLS 1.3
        NSMutableArray *protocolsArray = [NSMutableArray arrayWithArray:sessionConfiguration.protocolClasses];
        [protocolsArray insertObject:[HttpDnsNSURLProtocolImpl class] atIndex:0];
        [sessionConfiguration setProtocolClasses:protocolsArray];
        
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:queue];
        
        // 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *originalHost = request.URL.host;
        if (originalHost == nil) {
            NSString *fixedUrlString = request.URL.absoluteString ;
            fixedUrlString= [fixedUrlString stringByReplacingOccurrencesOfString:@"http:///" withString:@"http://"];
            fixedUrlString= [fixedUrlString stringByReplacingOccurrencesOfString:@"https:///" withString:@"https://"];
            
            if (([fixedUrlString hasPrefix:@"http:/"] && ![fixedUrlString hasPrefix:@"http://"])||([fixedUrlString hasPrefix:@"https:/"] && ![fixedUrlString hasPrefix:@"https://"])) {
                fixedUrlString = [fixedUrlString stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
                fixedUrlString = [fixedUrlString stringByReplacingOccurrencesOfString:@"https:/" withString:@"https://"];
                NSURL *fixedUrl = [NSURL URLWithString:fixedUrlString];
                originalHost = fixedUrl.host;
            }
        }
        
        // 自定义解析IP并替换原域名，同时添加Host头
        if (originalHost && ![request.URL.host containsString:@"127.0.0"]) {
            if ([SkyShield shareInstance].dohLists && [SkyShield shareInstance].dohLists.count > 0) {
                // 添加原始域名作为Host头
                [request addValue:request.URL.host forHTTPHeaderField:@"Host"];
                
                // 替换URL中的域名为解析后的IP
                NSString *requestUrlS = request.URL.absoluteString;
                if (requestUrlS) {
                    NSString *replaceHostUrl = [[SkyShield shareInstance] replaceUrlHostToDNS:requestUrlS];
                    NSURL *domainURL1 = [NSURL URLWithString:replaceHostUrl];
                    if (domainURL1) {
                        request.URL = domainURL1;
                    }
                }
            }
        }
        
        self.downloadTask = [self.session downloadTaskWithRequest:request];
        [self.downloadTask resume];
    }
    return self;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSData *data = [NSData dataWithContentsOfURL:location];
    UIImage *image = [UIImage imageWithData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.completedBlock) {
            self.completedBlock(image,data, nil);
            // 防止重复调用
            self.completedBlock = nil;
        }
        //下载完成回调
        if ([self.delegate respondsToSelector:@selector(downloadFinishWithURL:)]) {
            [self.delegate downloadFinishWithURL:self.url];
        }
    });
    //销毁
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.currentLength = totalBytesWritten;
    self.totalLength = totalBytesExpectedToWrite;
    if (self.progressBlock) {
        self.progressBlock(self.totalLength, self.currentLength);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error){
        XHLaunchAdLog(@"error = %@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completedBlock) {
                self.completedBlock(nil,nil, error);
            }
            self.completedBlock = nil;
        });
    }
}

//处理HTTPS请求的
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // 对于自定义解析的IP地址，信任所有证书
        SecTrustRef serverTrust = protectionSpace.serverTrust;
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

@end

#pragma makr - XHLaunchAdVideoDownload
@interface XHLaunchAdVideoDownload()<NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate>

@property (nonatomic, copy ) XHLaunchAdDownloadVideoCompletedBlock completedBlock;
@end
@implementation XHLaunchAdVideoDownload

-(nonnull instancetype)initWithURL:(nonnull NSURL *)url delegateQueue:(nonnull NSOperationQueue *)queue progress:(nullable XHLaunchAdDownloadProgressBlock)progressBlock completed:(nullable XHLaunchAdDownloadVideoCompletedBlock)completedBlock{
    self = [super init];
    if (self) {
        self.url = url;
        self.progressBlock = progressBlock;
        _completedBlock = completedBlock;
        NSURLSessionConfiguration * sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.TLSMinimumSupportedProtocol = kTLSProtocol1;  // 支持更多TLS版本
        sessionConfiguration.TLSMaximumSupportedProtocol = kTLSProtocol13; // 支持到TLS 1.3
        NSMutableArray *protocolsArray = [NSMutableArray arrayWithArray:sessionConfiguration.protocolClasses];
        [protocolsArray insertObject:[HttpDnsNSURLProtocolImpl class] atIndex:0];
        [sessionConfiguration setProtocolClasses:protocolsArray];
        
        sessionConfiguration.timeoutIntervalForRequest = 15.0;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:queue];
        
        // 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        NSString *originalHost = request.URL.host;
        if (originalHost == nil) {
            NSString *fixedUrlString = request.URL.absoluteString ;
            fixedUrlString= [fixedUrlString stringByReplacingOccurrencesOfString:@"http:///" withString:@"http://"];
            fixedUrlString= [fixedUrlString stringByReplacingOccurrencesOfString:@"https:///" withString:@"https://"];
            
            if (([fixedUrlString hasPrefix:@"http:/"] && ![fixedUrlString hasPrefix:@"http://"])||([fixedUrlString hasPrefix:@"https:/"] && ![fixedUrlString hasPrefix:@"https://"])) {
                fixedUrlString = [fixedUrlString stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
                fixedUrlString = [fixedUrlString stringByReplacingOccurrencesOfString:@"https:/" withString:@"https://"];
                NSURL *fixedUrl = [NSURL URLWithString:fixedUrlString];
                originalHost = fixedUrl.host;
            }
        }
        
        // 自定义解析IP并替换原域名，同时添加Host头
        if (originalHost && ![request.URL.host containsString:@"127.0.0"]) {
            if ([SkyShield shareInstance].dohLists && [SkyShield shareInstance].dohLists.count > 0) {
                // 添加原始域名作为Host头
                [request addValue:request.URL.host forHTTPHeaderField:@"Host"];
                
                // 替换URL中的域名为解析后的IP
                NSString *requestUrlS = request.URL.absoluteString;
                if (requestUrlS) {
                    NSString *replaceHostUrl = [[SkyShield shareInstance] replaceUrlHostToDNS:requestUrlS];
                    NSURL *domainURL1 = [NSURL URLWithString:replaceHostUrl];
                    if (domainURL1) {
                        request.URL = domainURL1;
                    }
                }
            }
        }
        
        self.downloadTask = [self.session downloadTaskWithRequest:request];
        [self.downloadTask resume];
    }
    return self;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSError *error=nil;
    NSURL *toURL = [NSURL fileURLWithPath:[XHLaunchAdCache videoPathWithURL:self.url]];

    [[NSFileManager defaultManager] copyItemAtURL:location toURL:toURL error:&error];//复制到缓存目录

    if(error)  XHLaunchAdLog(@"error = %@",error);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.completedBlock) {
            if(!error){
                self.completedBlock(toURL,nil);
            }else{
                self.completedBlock(nil,error);
            }
            // 防止重复调用
            self.completedBlock = nil;
        }
        //下载完成回调
        if ([self.delegate respondsToSelector:@selector(downloadFinishWithURL:)]) {
            [self.delegate downloadFinishWithURL:self.url];
        }
    });
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.currentLength = totalBytesWritten;
    self.totalLength = totalBytesExpectedToWrite;
    if (self.progressBlock) {
        self.progressBlock(self.totalLength, self.currentLength);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error){
        XHLaunchAdLog(@"error = %@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completedBlock) {
                self.completedBlock(nil, error);
            }
            self.completedBlock = nil;
        });
    }
}
@end

#pragma mark - XHLaunchAdDownloader
@interface XHLaunchAdDownloader()<XHLaunchAdDownloadDelegate>
@property (strong, nonatomic, nonnull) NSOperationQueue *downloadImageQueue;
@property (strong, nonatomic, nonnull) NSOperationQueue *downloadVideoQueue;
@property (strong, nonatomic) NSMutableDictionary *allDownloadDict;
@end

@implementation XHLaunchAdDownloader

+(nonnull instancetype )sharedDownloader{
    static XHLaunchAdDownloader *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[XHLaunchAdDownloader alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _downloadImageQueue = [NSOperationQueue new];
        _downloadImageQueue.maxConcurrentOperationCount = 6;
        _downloadImageQueue.name = @"com.it7090.XHLaunchAdDownloadImageQueue";
        _downloadVideoQueue = [NSOperationQueue new];
        _downloadVideoQueue.maxConcurrentOperationCount = 3;
        _downloadVideoQueue.name = @"com.it7090.XHLaunchAdDownloadVideoQueue";
        XHLaunchAdLog(@"XHLaunchAdCachePath:%@",[XHLaunchAdCache xhLaunchAdCachePath]);
    }
    return self;
}

- (void)downloadImageWithURL:(nonnull NSURL *)url progress:(nullable XHLaunchAdDownloadProgressBlock)progressBlock completed:(nullable XHLaunchAdDownloadImageCompletedBlock)completedBlock{
    NSString *key = [self keyWithURL:url];
    if(self.allDownloadDict[key]) return;
    XHLaunchAdImageDownload * download = [[XHLaunchAdImageDownload alloc] initWithURL:url delegateQueue:_downloadImageQueue progress:progressBlock completed:completedBlock];
    download.delegate = self;
    [self.allDownloadDict setObject:download forKey:key];
}

- (void)downloadImageAndCacheWithURL:(nonnull NSURL *)url completed:(void(^)(BOOL result))completedBlock{
    if(url == nil){
         if(completedBlock) completedBlock(NO);
         return;
    }
    [self downloadImageWithURL:url progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error) {
        if(error){
            if(completedBlock) completedBlock(NO);
        }else{
            [XHLaunchAdCache async_saveImageData:data imageURL:url completed:^(BOOL result, NSURL * _Nonnull URL) {
                if(completedBlock) completedBlock(result);
            }];
        }
    }];
}

-(void)downLoadImageAndCacheWithURLArray:(NSArray<NSURL *> *)urlArray{
    [self downLoadImageAndCacheWithURLArray:urlArray completed:nil];
}

- (void)downLoadImageAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray completed:(nullable XHLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock{
    if(urlArray.count==0) return;
    __block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
    dispatch_group_t downLoadGroup = dispatch_group_create();
    [urlArray enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        if(![XHLaunchAdCache checkImageInCacheWithURL:url]){
            dispatch_group_enter(downLoadGroup);
            [self downloadImageAndCacheWithURL:url completed:^(BOOL result) {
                dispatch_group_leave(downLoadGroup);
                [resultArray addObject:@{@"url":url.absoluteString,@"result":@(result)}];
            }];
        }else{
          [resultArray addObject:@{@"url":url.absoluteString,@"result":@(YES)}];
        }
    }];
    dispatch_group_notify(downLoadGroup, dispatch_get_main_queue(), ^{
        if(completedBlock) completedBlock(resultArray);
    });
}

- (void)downloadVideoWithURL:(nonnull NSURL *)url progress:(nullable XHLaunchAdDownloadProgressBlock)progressBlock completed:(nullable XHLaunchAdDownloadVideoCompletedBlock)completedBlock{
    NSString *key = [self keyWithURL:url];
    if(self.allDownloadDict[key]) return;
    XHLaunchAdVideoDownload * download = [[XHLaunchAdVideoDownload alloc] initWithURL:url delegateQueue:_downloadVideoQueue progress:progressBlock completed:completedBlock];
    download.delegate = self;
    [self.allDownloadDict setObject:download forKey:key];
}

- (void)downloadVideoAndCacheWithURL:(nonnull NSURL *)url completed:(void(^)(BOOL result))completedBlock{
    if(url == nil){
        if(completedBlock) completedBlock(NO);
        return;
    }
    [self downloadVideoWithURL:url progress:nil completed:^(NSURL * _Nullable location, NSError * _Nullable error) {
        if(error){
            if(completedBlock) completedBlock(NO);
        }else{
            if(completedBlock) completedBlock(YES);
        }
    }];
}

- (void)downLoadVideoAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray{
    [self downLoadVideoAndCacheWithURLArray:urlArray completed:nil];
}

- (void)downLoadVideoAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray completed:(nullable XHLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock{
    if(urlArray.count==0) return;
    __block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
    dispatch_group_t downLoadGroup = dispatch_group_create();
    WeakSelf
    [urlArray enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(![XHLaunchAdCache checkVideoInCacheWithURL:url]){
             dispatch_group_enter(downLoadGroup);
            [strongSelf downloadVideoAndCacheWithURL:url completed:^(BOOL result) {
               dispatch_group_leave(downLoadGroup);
                [resultArray addObject:@{@"url":url.absoluteString,@"result":@(result)}];
            }];
        }else{
           [resultArray addObject:@{@"url":url.absoluteString,@"result":@(YES)}];
        }
    }];
    dispatch_group_notify(downLoadGroup, dispatch_get_main_queue(), ^{
        if(completedBlock) completedBlock(resultArray);
    });
}

- (NSMutableDictionary *)allDownloadDict {
    if (!_allDownloadDict) {
        _allDownloadDict = [[NSMutableDictionary alloc] init];
    }
    return _allDownloadDict;
}

- (void)downloadFinishWithURL:(NSURL *)url{
    [self.allDownloadDict removeObjectForKey:[self keyWithURL:url]];
}

-(NSString *)keyWithURL:(NSURL *)url{
    return [XHLaunchAdCache md5String:url.absoluteString];
}

@end

