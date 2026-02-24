//
//  XHLaunchAd.m
//  XHLaunchAdExample
//
//  Created by zhuxiaohui on 2016/6/13.
//  Copyright © 2016年 it7090.com. All rights reserved.
//  代码地址:https://github.com/CoderZhuXH/XHLaunchAd

#import "XHLaunchAd.h"
#import "XHLaunchAdView.h"
#import "XHLaunchAdImageView+XHLaunchAdCache.h"
#import "XHLaunchAdDownloader.h"
#import "XHLaunchAdCache.h"
#import "XHLaunchAdController.h"
#import <FFAES/FFAES.h>
#import "LiveGifImage.h"
typedef NS_ENUM(NSInteger, XHLaunchAdType) {
    XHLaunchAdTypeImage,
    XHLaunchAdTypeVideo
};

static NSInteger defaultWaitDataDuration = 3;
static  SourceType _sourceType = SourceTypeLaunchImage;
@interface XHLaunchAd()

@property(nonatomic,assign)XHLaunchAdType launchAdType;
@property(nonatomic,assign)NSInteger waitDataDuration;
@property(nonatomic,strong)XHLaunchImageAdConfiguration * imageAdConfiguration;
@property(nonatomic,strong)XHLaunchVideoAdConfiguration * videoAdConfiguration;
@property(nonatomic,strong)XHLaunchAdButton * skipButton;
@property(nonatomic,strong)XHLaunchAdVideoView * adVideoView;
@property(nonatomic,strong)UIWindow * window;
@property(nonatomic,strong)XHLaunchImageView *launchImageView;
@property(nonatomic,copy)dispatch_source_t waitDataTimer;
@property(nonatomic,copy)dispatch_source_t skipTimer;
@property (nonatomic, assign) BOOL detailPageShowing;
@property(nonatomic,assign) CGPoint clickPoint;
@end

@implementation XHLaunchAd
+(void)setLaunchSourceType:(SourceType)sourceType{
    _sourceType = sourceType;
}
+(void)setWaitDataDuration:(NSInteger )waitDataDuration{
    XHLaunchAd *launchAd = [XHLaunchAd shareLaunchAd];
    launchAd.waitDataDuration = waitDataDuration;
}
+(XHLaunchAd *)imageAdWithImageAdConfiguration:(XHLaunchImageAdConfiguration *)imageAdconfiguration{
    return [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:nil];
}

+(XHLaunchAd *)imageAdWithImageAdConfiguration:(XHLaunchImageAdConfiguration *)imageAdconfiguration delegate:(id)delegate{
    XHLaunchAd *launchAd = [XHLaunchAd shareLaunchAd];
    if(delegate) launchAd.delegate = delegate;
    launchAd.imageAdConfiguration = imageAdconfiguration;
    return launchAd;
}

+(XHLaunchAd *)videoAdWithVideoAdConfiguration:(XHLaunchVideoAdConfiguration *)videoAdconfiguration{
    return [XHLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguration delegate:nil];
}

+(XHLaunchAd *)videoAdWithVideoAdConfiguration:(XHLaunchVideoAdConfiguration *)videoAdconfiguration delegate:(nullable id)delegate{
    XHLaunchAd *launchAd = [XHLaunchAd shareLaunchAd];
    if(delegate) launchAd.delegate = delegate;
    launchAd.videoAdConfiguration = videoAdconfiguration;
    return launchAd;
}

+(void)downLoadImageAndCacheWithURLArray:(NSArray <NSURL *> * )urlArray{
    [self downLoadImageAndCacheWithURLArray:urlArray completed:nil];
}

+ (void)downLoadImageAndCacheWithURLArray:(NSArray <NSURL *> * )urlArray completed:(nullable XHLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock{
    if(urlArray.count==0) return;
    [[XHLaunchAdDownloader sharedDownloader] downLoadImageAndCacheWithURLArray:urlArray completed:completedBlock];
}

+(void)downLoadVideoAndCacheWithURLArray:(NSArray <NSURL *> * )urlArray{
    [self downLoadVideoAndCacheWithURLArray:urlArray completed:nil];
}

+(void)downLoadVideoAndCacheWithURLArray:(NSArray <NSURL *> * )urlArray completed:(nullable XHLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock{
    if(urlArray.count==0) return;
    [[XHLaunchAdDownloader sharedDownloader] downLoadVideoAndCacheWithURLArray:urlArray completed:completedBlock];
}
+(void)removeAndAnimated:(BOOL)animated{
    [[XHLaunchAd shareLaunchAd] removeAndAnimated:animated];
}

+(BOOL)checkImageInCacheWithURL:(NSURL *)url{
    return [XHLaunchAdCache checkImageInCacheWithURL:url];
}

+(BOOL)checkVideoInCacheWithURL:(NSURL *)url{
    return [XHLaunchAdCache checkVideoInCacheWithURL:url];
}
+(void)clearDiskCache{
    [XHLaunchAdCache clearDiskCache];
}

+(void)clearDiskCacheWithImageUrlArray:(NSArray<NSURL *> *)imageUrlArray{
    [XHLaunchAdCache clearDiskCacheWithImageUrlArray:imageUrlArray];
}

+(void)clearDiskCacheExceptImageUrlArray:(NSArray<NSURL *> *)exceptImageUrlArray{
    [XHLaunchAdCache clearDiskCacheExceptImageUrlArray:exceptImageUrlArray];
}

+(void)clearDiskCacheWithVideoUrlArray:(NSArray<NSURL *> *)videoUrlArray{
    [XHLaunchAdCache clearDiskCacheWithVideoUrlArray:videoUrlArray];
}

+(void)clearDiskCacheExceptVideoUrlArray:(NSArray<NSURL *> *)exceptVideoUrlArray{
    [XHLaunchAdCache clearDiskCacheExceptVideoUrlArray:exceptVideoUrlArray];
}

+(float)diskCacheSize{
    return [XHLaunchAdCache diskCacheSize];
}

+(NSString *)xhLaunchAdCachePath{
    return [XHLaunchAdCache xhLaunchAdCachePath];
}

+(NSString *)cacheImageURLString{
    return [XHLaunchAdCache getCacheImageUrl];
}

+(NSString *)cacheVideoURLString{
    return [XHLaunchAdCache getCacheVideoUrl];
}

#pragma mark - 过期
/** 请使用removeAndAnimated: */
+(void)skipAction{
    [[XHLaunchAd shareLaunchAd] removeAndAnimated:YES];
}
/** 请使用setLaunchSourceType: */
+(void)setLaunchImagesSource:(LaunchImagesSource)launchImagesSource{
    switch (launchImagesSource) {
        case LaunchImagesSourceLaunchImage:
            _sourceType = SourceTypeLaunchImage;
            break;
        case LaunchImagesSourceLaunchScreen:
            _sourceType = SourceTypeLaunchScreen;
            break;
        default:
            break;
    }
}

#pragma mark - private
+(XHLaunchAd *)shareLaunchAd{
    static XHLaunchAd *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[XHLaunchAd alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupLaunchAd];
        WeakSelf
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf setupLaunchAdEnterForeground];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf removeOnly];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:XHLaunchAdDetailPageWillShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf.detailPageShowing = YES;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:XHLaunchAdDetailPageShowFinishNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf.detailPageShowing = NO;
        }];
    }
    return self;
}

-(void)setupLaunchAdEnterForeground{
    switch (_launchAdType) {
        case XHLaunchAdTypeImage:{
            if(!_imageAdConfiguration.showEnterForeground || _detailPageShowing) return;
            [self setupLaunchAd];
            [self setupImageAdForConfiguration:_imageAdConfiguration];
        }
            break;
        case XHLaunchAdTypeVideo:{
            if(!_videoAdConfiguration.showEnterForeground || _detailPageShowing) return;
            [self setupLaunchAd];
            [self setupVideoAdForConfiguration:_videoAdConfiguration];
        }
            break;
        default:
            break;
    }
}

-(void)setupLaunchAd{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [XHLaunchAdController new];
    window.rootViewController.view.backgroundColor = [UIColor clearColor];
    window.rootViewController.view.userInteractionEnabled = NO;
    window.windowLevel = UIWindowLevelStatusBar + 1;
    window.hidden = NO;
    window.alpha = 1;
    _window = window;
    /** 添加launchImageView */
    _launchImageView = [[XHLaunchImageView alloc] initWithSourceType:_sourceType];
    [_window addSubview:_launchImageView];

}

/**图片*/
-(void)setupImageAdForConfiguration:(XHLaunchImageAdConfiguration *)configuration{
    if(_window == nil) return;
    [self removeSubViewsExceptLaunchAdImageView];
    XHLaunchAdImageView *adImageView = [[XHLaunchAdImageView alloc] init];
    adImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_window insertSubview:adImageView belowSubview:_launchImageView];
    /** frame */
    if(configuration.frame.size.width>0 && configuration.frame.size.height>0) adImageView.frame = configuration.frame;
    if(configuration.contentMode) adImageView.contentMode = configuration.contentMode;
    /** webImage */
    if(configuration.imageNameOrURLString.length && XHISURLString(configuration.imageNameOrURLString)){
        [XHLaunchAdCache async_saveImageUrl:configuration.imageNameOrURLString];
        /** 自设图片 */
        if ([self.delegate respondsToSelector:@selector(xhLaunchAd:launchAdImageView:URL:)]) {
            [self.delegate xhLaunchAd:self launchAdImageView:adImageView URL:[NSURL URLWithString:configuration.imageNameOrURLString]];
            XHWeakSelf
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.launchImageView.alpha = 0.0;
            }];
        }else{
            if(!configuration.imageOption) configuration.imageOption = XHLaunchAdImageDefault;
            XHWeakSelf
            
            [adImageView sd_setImageWithURL:[NSURL URLWithString:configuration.imageNameOrURLString] placeholderImage:_launchImageView.image completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    weakSelf.launchImageView.alpha = 0.0;
                }];
                if(!error){
                   
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
                    if ([weakSelf.delegate respondsToSelector:@selector(xhLaunchAd:imageDownLoadFinish:)]) {
                        [weakSelf.delegate xhLaunchAd:self imageDownLoadFinish:image];
                    }
#pragma clang diagnostic pop
                }
            }];
//            if(configuration.imageOption == XHLaunchAdImageCacheInBackground){
//                /** 缓存中未有 */
//                if(![XHLaunchAdCache checkImageInCacheWithURL:[NSURL URLWithString:configuration.imageNameOrURLString]]){
//                    [self removeAndAnimateDefault]; return; /** 完成显示 */
//                }
//            }
        }
    }else{
        if(configuration.imageNameOrURLString.length){
            NSData *data = XHDataWithFileName(configuration.imageNameOrURLString);
            if ([configuration.imageNameOrURLString.lastPathComponent containsString:@"aes"]) {
                data = [self vk_imageDecode:data];
            }
            
            if(XHISGIFTypeWithData(data)){
                LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:data];
                [imgAnima setAnimatedImageLoopCount:0];
                adImageView.image = imgAnima;
                
//                __weak typeof(adImageView) w_adImageView = adImageView;
//                adImageView.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
//                    if(configuration.GIFImageCycleOnce){
//                        [w_adImageView stopAnimating];
//                        XHLaunchAdLog(@"GIF不循环,播放完成");
//                        [[NSNotificationCenter defaultCenter] postNotificationName:XHLaunchAdGIFImageCycleOnceFinishNotification object:@{@"imageNameOrURLString":configuration.imageNameOrURLString}];
//                    }
//                };
            }else{
                adImageView.image = nil;
                adImageView.image = [UIImage imageWithData:data];
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
            if ([self.delegate respondsToSelector:@selector(xhLaunchAd:imageDownLoadFinish:)]) {
                [self.delegate xhLaunchAd:self imageDownLoadFinish:[UIImage imageWithData:data]];
            }
#pragma clang diagnostic pop
        }else{
            adImageView.image = _launchImageView.image ;
            XHLaunchAdLog(@"未设置广告图片");
        }
        WeakSelf
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.launchImageView.alpha = 0.0;
        }];
    }
    /** skipButton */
    [self addSkipButtonForConfiguration:configuration];
    [self startSkipDispathTimer];
    /** customView */
    if(configuration.subViews.count>0)  [self addSubViews:configuration.subViews];
    XHWeakSelf
    adImageView.click = ^(CGPoint point) {
        [weakSelf clickAndPoint:point];
    };
}
- (NSData *)vk_imageDecode:(NSData *)fromData {
    return [FFAES decryptData:fromData key:KAESKEY];
}

-(void)addSkipButtonForConfiguration:(XHLaunchAdConfiguration *)configuration{
  
    if(!configuration.skipButtonType) configuration.skipButtonType = SkipTypeTimeText;
    
    if (configuration.duration <= 0) {
        configuration.skipButtonType = SkipTypeText;
    }
    
    if(configuration.customSkipView){
        [_window addSubview:configuration.customSkipView];
    }else{
        if(_skipButton == nil){
            _skipButton = [[XHLaunchAdButton alloc] initWithSkipType:configuration.skipButtonType];
            _skipButton.hidden = YES;
            [_skipButton addTarget:self action:@selector(skipButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        [_window addSubview:_skipButton];
        [_skipButton setTitleWithSkipType:configuration.skipButtonType duration:configuration.duration];
    }
}

/**视频*/
-(void)setupVideoAdForConfiguration:(XHLaunchVideoAdConfiguration *)configuration{
    if(_window ==nil) return;
    [self removeSubViewsExceptLaunchAdImageView];
    if(!_adVideoView){
        _adVideoView = [[XHLaunchAdVideoView alloc] init];
    }
    [_window addSubview:_adVideoView];
    /** frame */
    if(configuration.frame.size.width>0&&configuration.frame.size.height>0) _adVideoView.frame = configuration.frame;
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if(configuration.scalingMode) _adVideoView.videoScalingMode = configuration.scalingMode;
#pragma clang diagnostic pop
    if(configuration.videoGravity) _adVideoView.videoGravity = configuration.videoGravity;
    _adVideoView.videoCycleOnce = configuration.videoCycleOnce;
    if(configuration.videoCycleOnce){
        [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            XHLaunchAdLog(@"video不循环,播放完成");
            [[NSNotificationCenter defaultCenter] postNotificationName:XHLaunchAdVideoCycleOnceFinishNotification object:nil userInfo:@{@"videoNameOrURLString":configuration.videoNameOrURLString}];
        }];
    }
    /** video 数据源 */
    if(configuration.videoNameOrURLString.length && XHISURLString(configuration.videoNameOrURLString)){
        [XHLaunchAdCache async_saveVideoUrl:configuration.videoNameOrURLString];
        NSURL *pathURL = [XHLaunchAdCache getCacheVideoWithURL:[NSURL URLWithString:configuration.videoNameOrURLString]];
        if(pathURL){
            if ([self.delegate respondsToSelector:@selector(xhLaunchAd:videoDownLoadFinish:)]) {
                [self.delegate xhLaunchAd:self videoDownLoadFinish:pathURL];
            }
            _adVideoView.contentURL = pathURL;
            _adVideoView.muted = configuration.muted;
            [_adVideoView.videoPlayer.player play];
        }else{
            XHWeakSelf
            [[XHLaunchAdDownloader sharedDownloader] downloadVideoWithURL:[NSURL URLWithString:configuration.videoNameOrURLString] progress:^(unsigned long long total, unsigned long long current) {
                if ([weakSelf.delegate respondsToSelector:@selector(xhLaunchAd:videoDownLoadProgress:total:current:)]) {
                    [weakSelf.delegate xhLaunchAd:self videoDownLoadProgress:current/(float)total total:total current:current];
                }
            }  completed:^(NSURL * _Nullable location, NSError * _Nullable error){
                if(!error){
                    if ([weakSelf.delegate respondsToSelector:@selector(xhLaunchAd:videoDownLoadFinish:)]){
                        [weakSelf.delegate xhLaunchAd:self videoDownLoadFinish:location];
                    }
                }
            }];
            /***视频缓存,提前显示完成 */
            [self removeAndAnimateDefault]; return;
        }
    }else{
        if(configuration.videoNameOrURLString.length){
            NSURL *pathURL = nil;
            NSURL *cachePathURL = [[NSURL alloc] initFileURLWithPath:[XHLaunchAdCache videoPathWithFileName:configuration.videoNameOrURLString]];
            //若本地视频未在沙盒缓存文件夹中
            if (![XHLaunchAdCache checkVideoInCacheWithFileName:configuration.videoNameOrURLString]) {
                /***如果不在沙盒文件夹中则将其复制一份到沙盒缓存文件夹中/下次直接取缓存文件夹文件,加快文件查找速度 */
                NSURL *bundleURL = [[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])] URLForResource:configuration.videoNameOrURLString withExtension:nil];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[NSFileManager defaultManager] copyItemAtURL:bundleURL toURL:cachePathURL error:nil];
                });
                pathURL = bundleURL;
            }else{
                pathURL = cachePathURL;
            }
            
            if(pathURL){
                if ([self.delegate respondsToSelector:@selector(xhLaunchAd:videoDownLoadFinish:)]) {
                    [self.delegate xhLaunchAd:self videoDownLoadFinish:pathURL];
                }
                _adVideoView.contentURL = pathURL;
                _adVideoView.muted = configuration.muted;
                [_adVideoView.videoPlayer.player play];
                
            }else{
                XHLaunchAdLog(@"Error:广告视频未找到,请检查名称是否有误!");
            }
        }else{
            XHLaunchAdLog(@"未设置广告视频");
        }
    }
    /** skipButton */
    [self addSkipButtonForConfiguration:configuration];
    [self startSkipDispathTimer];
    /** customView */
    if(configuration.subViews.count>0) [self addSubViews:configuration.subViews];
    XHWeakSelf
    _adVideoView.click = ^(CGPoint point) {
        [weakSelf clickAndPoint:point];
    };
}

#pragma mark - add subViews
-(void)addSubViews:(NSArray *)subViews{
    [subViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [_window addSubview:view];
    }];
}

#pragma mark - set
-(void)setImageAdConfiguration:(XHLaunchImageAdConfiguration *)imageAdConfiguration{
    _imageAdConfiguration = imageAdConfiguration;
    _launchAdType = XHLaunchAdTypeImage;
    [self setupImageAdForConfiguration:imageAdConfiguration];
}

-(void)setVideoAdConfiguration:(XHLaunchVideoAdConfiguration *)videoAdConfiguration{
    _videoAdConfiguration = videoAdConfiguration;
    _launchAdType = XHLaunchAdTypeVideo;
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CGFLOAT_MIN * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf setupVideoAdForConfiguration:videoAdConfiguration];
    });
}

-(void)setWaitDataDuration:(NSInteger)waitDataDuration{
    _waitDataDuration = waitDataDuration;
    /** 数据等待 */
    if (waitDataDuration == 0) {
        return;
    }
    [self startWaitDataDispathTiemr];
}

#pragma mark - Action
-(void)skipButtonClick:(XHLaunchAdButton *)button{
    if ([self.delegate respondsToSelector:@selector(xhLaunchAd:clickSkipButton:)]) {
        [self.delegate xhLaunchAd:self clickSkipButton:button];
    }
    [self removeAndAnimated:YES];
}

-(void)removeAndAnimated:(BOOL)animated{
    if(animated){
        [self removeAndAnimate];
    }else{
        [self remove];
    }
}

-(void)clickAndPoint:(CGPoint)point{
    self.clickPoint = point;
    XHLaunchAdConfiguration * configuration = [self commonConfiguration];
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if ([self.delegate respondsToSelector:@selector(xhLaunchAd:clickAndOpenURLString:)]) {
        [self.delegate xhLaunchAd:self clickAndOpenURLString:configuration.openURLString];
        [self removeAndAnimateDefault];
    }
    if ([self.delegate respondsToSelector:@selector(xhLaunchAd:clickAndOpenURLString:clickPoint:)]) {
        [self.delegate xhLaunchAd:self clickAndOpenURLString:configuration.openURLString clickPoint:point];
        [self removeAndAnimateDefault];
    }
    if ([self.delegate respondsToSelector:@selector(xhLaunchAd:clickAndOpenModel:clickPoint:)]) {
        [self.delegate xhLaunchAd:self clickAndOpenModel:configuration.openModel clickPoint:point];
        [self removeAndAnimateDefault];
    }
#pragma clang diagnostic pop
    if ([self.delegate respondsToSelector:@selector(xhLaunchAd:clickAtOpenModel:clickPoint:)]) {
        BOOL status =  [self.delegate xhLaunchAd:self clickAtOpenModel:configuration.openModel clickPoint:point];
        if(status) [self removeAndAnimateDefault];
    }
}

-(XHLaunchAdConfiguration *)commonConfiguration{
    XHLaunchAdConfiguration *configuration = nil;
    switch (_launchAdType) {
        case XHLaunchAdTypeVideo:
            configuration = _videoAdConfiguration;
            break;
        case XHLaunchAdTypeImage:
            configuration = _imageAdConfiguration;
            break;
        default:
            break;
    }
    return configuration;
}

-(void)startWaitDataDispathTiemr{
    __block NSInteger duration = defaultWaitDataDuration;
    if(_waitDataDuration) duration = _waitDataDuration;
    _waitDataTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    NSTimeInterval period = 1.0;
    dispatch_source_set_timer(_waitDataTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    WeakSelf
    dispatch_source_set_event_handler(_waitDataTimer, ^{
        STRONGSELF
        if (strongSelf ==nil) {
            return;
        }
        if(duration==0){
            DISPATCH_SOURCE_CANCEL_SAFE(strongSelf.waitDataTimer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:XHLaunchAdWaitDataDurationArriveNotification object:nil];
                [strongSelf remove];
                return ;
            });
        }
        duration--;
    });
    dispatch_resume(_waitDataTimer);
}

-(void)startSkipDispathTimer{
    XHLaunchAdConfiguration * configuration = [self commonConfiguration];
    DISPATCH_SOURCE_CANCEL_SAFE(_waitDataTimer);
    if(!configuration.skipButtonType) configuration.skipButtonType = SkipTypeTimeText;//默认
    
    
    if (configuration.duration <= 0) {
        return;
    }
    __block NSInteger duration = 5;//默认
    if(configuration.duration) duration = configuration.duration;
    if(configuration.skipButtonType == SkipTypeRoundProgressTime || configuration.skipButtonType == SkipTypeRoundProgressText){
        [_skipButton startRoundDispathTimerWithDuration:duration];
    }
    NSTimeInterval period = 1.0;
    _skipTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_skipTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    WeakSelf
    dispatch_source_set_event_handler(_skipTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if ([strongSelf.delegate respondsToSelector:@selector(xhLaunchAd:customSkipView:duration:)]) {
                [strongSelf.delegate xhLaunchAd:strongSelf customSkipView:configuration.customSkipView duration:duration];
            }
            if(!configuration.customSkipView){
                [strongSelf.skipButton setTitleWithSkipType:configuration.skipButtonType duration:duration];
            }
            if(duration==0){
                DISPATCH_SOURCE_CANCEL_SAFE(strongSelf.skipTimer);
                [strongSelf removeAndAnimate]; return ;
            }
            duration--;
        });
    });
    dispatch_resume(_skipTimer);
}

-(void)removeAndAnimate{
    
    XHLaunchAdConfiguration * configuration = [self commonConfiguration];
    CGFloat duration = showFinishAnimateTimeDefault;
    if(configuration.showFinishAnimateTime>0) duration = configuration.showFinishAnimateTime;
    switch (configuration.showFinishAnimate) {
        case ShowFinishAnimateNone:{
            [self remove];
        }
            break;
        case ShowFinishAnimateFadein:{
            [self removeAndAnimateDefault];
        }
            break;
        case ShowFinishAnimateLite:{
            WeakSelf
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionCurveEaseOut animations:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf.window.transform = CGAffineTransformMakeScale(1.5, 1.5);
                strongSelf.window.alpha = 0;
            } completion:^(BOOL finished) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf remove];
            }];
        }
            break;
        case ShowFinishAnimateFlipFromLeft:{
            WeakSelf
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf.window.alpha = 0;
            } completion:^(BOOL finished) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf remove];
            }];
        }
            break;
        case ShowFinishAnimateFlipFromBottom:{
            WeakSelf
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf.window.alpha = 0;
            } completion:^(BOOL finished) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf remove];
            }];
        }
            break;
        case ShowFinishAnimateCurlUp:{
            WeakSelf
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionCurlUp animations:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf.window.alpha = 0;
            } completion:^(BOOL finished) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf remove];
            }];
        }
            break;
        default:{
            [self removeAndAnimateDefault];
        }
            break;
    }
}

-(void)removeAndAnimateDefault{
    XHLaunchAdConfiguration * configuration = [self commonConfiguration];
    CGFloat duration = showFinishAnimateTimeDefault;
    if(configuration.showFinishAnimateTime>0) duration = configuration.showFinishAnimateTime;
    WeakSelf
    [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionNone animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.window.alpha = 0;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf remove];
    }];
}
-(void)removeOnly{
    DISPATCH_SOURCE_CANCEL_SAFE(_waitDataTimer)
    DISPATCH_SOURCE_CANCEL_SAFE(_skipTimer)
    REMOVE_FROM_SUPERVIEW_SAFE(_skipButton)
    if(_launchAdType==XHLaunchAdTypeVideo){
        if(_adVideoView){
            [_adVideoView stopVideoPlayer];
            REMOVE_FROM_SUPERVIEW_SAFE(_adVideoView)
        }
    }
    if(_window){
        [_window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            REMOVE_FROM_SUPERVIEW_SAFE(obj)
        }];
        _window.hidden = YES;
        _window = nil;
        [_launchImageView removeFromSuperview];
        _launchImageView = nil;
    }
}

-(void)remove{
    [self removeOnly];
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if ([self.delegate respondsToSelector:@selector(xhLaunchShowFinish:)]) {
        [self.delegate xhLaunchShowFinish:self];
    }
#pragma clang diagnostic pop
    if ([self.delegate respondsToSelector:@selector(xhLaunchAdShowFinish:)]) {
        [self.delegate xhLaunchAdShowFinish:self];
    }
}

-(void)removeSubViewsExceptLaunchAdImageView{
  
    [_window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![obj isKindOfClass:[XHLaunchImageView class]]){
            REMOVE_FROM_SUPERVIEW_SAFE(obj)
        }
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
