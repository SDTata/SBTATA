//
//  NodePlayer.h
//  NodeMediaClient
//
//  Created by ALiang on 2021/11/29.
//

#import <Foundation/Foundation.h>

#define NMC_EXPORT __attribute__((visibility("default")))

#define RTSP_TRANSPORT_UDP @"udp"
#define RTSP_TRANSPORT_TCP @"tcp"
#define RTSP_TRANSPORT_UDP_MULTICAST @"udp_multicast"
#define RTSP_TRANSPORT_HTTP @"http"

NS_ASSUME_NONNULL_BEGIN

@protocol NodePlayerDelegate

- (void)onEventCallback:(id)sender event:(int)event msg:(NSString *)msg;

@end

@class UIView;
NMC_EXPORT
@interface NodePlayer : NSObject

///事件委托
@property (nullable, nonatomic, weak) id<NodePlayerDelegate> nodePlayerDelegate;

///直播视频缓冲时长，单位毫秒，默认1000，当设为0时不进行缓冲与音视频同步
@property (nonatomic) NSUInteger bufferTime;

///视频缩放模式，0-填充，1-等比缩放，2-等比填充三种
@property (nonatomic) NSUInteger scaleMode;

///日志等级 0-error，1-info，2-debug
@property (nonatomic) NSUInteger logLevel;

///开启硬件极速
@property (nonatomic) Boolean HWAccelEnable;

///播放音量  0.0 ~ 1.0
@property (nonatomic) float volume;

///日志等级 0-error，1-info，2-debug
@property (nonatomic, copy) NSString *cryptoKey;

/// RTSP 传输协议
@property (nonatomic, copy) NSString *RTSPTransport;

/// RTMP Swf Url
@property (nonatomic, copy) NSString *RTMPSwfUrl;

/// RTMP Page Url
@property (nonatomic, copy) NSString *RTMPPageUrl;

/// HTTP Referer
@property (nonatomic, copy) NSString *HTTPReferer;

/// HTTP User Agent
@property (nonatomic, copy) NSString *HTTPUserAgent;

/// 当前视频是否是点播流
@property (nonatomic, readonly) Boolean isVod;

/// 当前视频是否暂停
@property (nonatomic, readonly) Boolean isPause;

/// 当前视频是否正在播放
@property (nonatomic, readonly) Boolean isPlaying;

/// 点播视频总时长，单位毫秒
@property (nonatomic, readonly) NSUInteger duration;

/// 当前视频播放点，单位毫秒
@property (nonatomic, readonly) NSUInteger currentPosition;

/// 当前视频缓冲点，单位毫秒
@property (nonatomic, readonly) NSUInteger bufferPosition;

///以注册码初始化播放器
- (id)initWithLicense:(NSString *)license;

///附加到视图
- (void)attachView:(UIView *)view;

///从视图移除
- (void)detachView;

///开始播放视频流
- (int)start:(NSString *)url;

///停止播放视频流
- (int)stop;

///暂停播放点播视频流
- (int)pause:(Boolean)isPause;

///点播视频时移到时间点
- (int)seek:(NSUInteger)pts;

///视频截图
- (int)screenshot:(NSString *)filename;

///开始录制
- (int)startRecord:(NSString *)filepath;

///停止录制
- (int)stopRecord;

@end

NS_ASSUME_NONNULL_END
