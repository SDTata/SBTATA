//
//  DramaPreload.m
//  phonelive2
//
//  Created by s5346 on 2024/6/13.
//  Copyright © 2024 toby. All rights reserved.
//

#import "DramaPreload.h"
#import "KTVHTTPCache.h"
#import "M3U8PlaylistModel.h"
#import "VideoProgressManager.h"

@interface DramaPreload () <KTVHCDataLoaderDelegate>

@property (nonatomic, strong) NSMutableArray<KTVHCDataLoader *> *loaders;

@end

@implementation DramaPreload

- (instancetype)init {
    if (self = [super init]) {
        self.loaders = [NSMutableArray array];
    }
    return self;
}

- (void)addModel:(DramaVideoInfoModel*)model {
    if (model.play_url.length <= 0) {
        WeakSelf
        [self requestVideo:model.video_id completion:^(NSString *url, int ticketCount, BOOL success) {
            if (!success || url.length <= 0) {
                return;
            }
            model.play_url = url;
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf addPreload:model];
        }];
        return;
    }
    [self addPreload:model];
}

- (void)requestVideo:(NSString*)skitId completion:(nullable void (^)(NSString *url, int ticketCount, BOOL success))completion {
    NSDictionary *dic = @{
        @"skit_id": skitId
    };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.watchSkit" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if (![info isKindOfClass:[NSDictionary class]]) {
                completion(@"", 0, NO);
                return;
            }

            NSDictionary *dic = info[@"skit_info"];
            if (![dic isKindOfClass:[NSDictionary class]]) {
                completion(@"", 0, NO);
                return;
            }

            NSString *url = minstr(dic[@"url"]);
            int ticketCount = [minstr(info[@"skit_ticket_count"]) intValue];
            completion(url, ticketCount, YES);
        } else {
            completion(@"", 0, NO);
        }
    } fail:^(NSError * _Nonnull error) {
        completion(@"", 0, NO);
    }];
}

- (void)addPreload:(DramaVideoInfoModel*)infoModel {
    NSURL *addUrl = [NSURL URLWithString:infoModel.play_url];
    NSMutableArray *loaders = [NSMutableArray array];

    NSDictionary *headers = @{
        // Set preload length if needed.
        // @"Range" : @"bytes=0-1"
    };

    if ([addUrl.absoluteString containsString:@".m3u"]) {
        NSError *error = nil;
        M3U8PlaylistModel *model = [[M3U8PlaylistModel alloc]
                    initWithURL:addUrl
                      error:&error];

        NSURL *originalURL = model.originalURL;
        if (originalURL == nil) {
            originalURL = model.mainMediaPl.originalURL;
        }
        if (originalURL == nil) {
            return;
        }

        NSString *originalURLString = originalURL.absoluteString;
        NSString *downloadUrl = @"";
        if ([originalURLString hasPrefix:@"http://"]) {
            NSURLComponents *components = [NSURLComponents componentsWithString:originalURLString];

            if (components.scheme && components.host) {
                NSString *fullDomain = [NSString stringWithFormat:@"%@://%@", components.scheme, components.host];
                downloadUrl = fullDomain;
            }
        } else {
            NSURLComponents *components = [NSURLComponents componentsWithString:originalURL.absoluteString];
            NSMutableArray<NSString *> *pathComponents = [[components.path pathComponents] mutableCopy];
            if (pathComponents.count > 1) {
                [pathComponents removeLastObject];
            }
            components.path = [NSString pathWithComponents:pathComponents];
            downloadUrl = components.string;
        }

        // 觀看進度
        DramaProgressModel *progressModel = [VideoProgressManager loadProgress:infoModel.skit_id episodeNumber:infoModel.episode_number];
        NSInteger myProgress = progressModel.currentTime;

        // 計算影片時間
        int currentIndex = 0;
        NSTimeInterval duration = 0;
        for (int i = 0; i<model.mainMediaPl.segmentList.count; i++) {
            M3U8SegmentInfo *info = [model.mainMediaPl.segmentList segmentInfoAtIndex:i];
            int indexDuration = duration + info.duration;
            if (indexDuration > myProgress) {
                break;
            }
            currentIndex = i;
            duration = indexDuration;
        }


        NSMutableArray *urlArray = [NSMutableArray array];
        NSArray<NSURL*> *allSegmentURLs = model.mainMediaPl.allSegmentURLs;
        int maxCount = MAX(1, round(allSegmentURLs.count / 10.0));
        for (int i = currentIndex; i<allSegmentURLs.count; i++) {
            if (i >= currentIndex + maxCount) {
                break;
            }
            NSURL *mainUrl = allSegmentURLs[i];
            NSString *urlString = mainUrl.relativeString;
            NSString *addUrl = [downloadUrl stringByAppendingPathComponent:urlString];
            NSURL *url = [NSURL URLWithString:addUrl];
            [urlArray addObject:url];
        }

        for (NSURL *url in urlArray) {
            KTVHCDataRequest *request = [[KTVHCDataRequest alloc] initWithURL:url headers:headers];
            KTVHCDataLoader *loader = [KTVHTTPCache cacheLoaderWithRequest:request];
            loader.object = infoModel;
            loader.delegate = self;
            [loaders addObject:loader];
        }
    } else {
        KTVHCDataRequest *request = [[KTVHCDataRequest alloc] initWithURL:addUrl headers:headers];
        KTVHCDataLoader *loader = [KTVHTTPCache cacheLoaderWithRequest:request];
        loader.object = infoModel;
        loader.delegate = self;
        [loaders addObject:loader];
    }

    self.loaders = loaders;
    [self.loaders.firstObject prepare];
}

- (void)dealloc {
    for (KTVHCDataLoader *obj in self.loaders) {
        [obj close];
    }
}

#pragma mark - KTVHCDataLoaderDelegate
- (void)ktv_loaderDidFinish:(KTVHCDataLoader *)loader
{
    NSUInteger index = [self.loaders indexOfObject:loader] + 1;
    if (index < self.loaders.count) {
        [[self.loaders objectAtIndex:index] prepare];
    }
}

- (void)ktv_loader:(KTVHCDataLoader *)loader didFailWithError:(NSError *)error
{
    NSUInteger index = [self.loaders indexOfObject:loader] + 1;
    if (index < self.loaders.count) {
        [[self.loaders objectAtIndex:index] prepare];
    }
}

- (void)ktv_loader:(KTVHCDataLoader *)loader didChangeProgress:(double)progress {
    DramaVideoInfoModel *model = loader.object;
    NSLog(@">>>>>>%@ %@ %f", model.name, loader.request.URL.absoluteString, progress);
}

@end
