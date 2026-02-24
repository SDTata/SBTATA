//
//  NodePublisher.h
//  NodeMediaClient
//
//  Created by ALiang on 2023/4/23.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#define NMC_CODEC_ID_H264                 27
#define NMC_CODEC_ID_H265                 173
#define NMC_CODEC_ID_AAC                  86018

#define NMC_PROFILE_AUTO                  0
#define NMC_PROFILE_H264_BASELINE         66
#define NMC_PROFILE_H264_MAIN             77
#define NMC_PROFILE_H264_HIGH             100
#define NMC_PROFILE_H265_MAIN             1
#define NMC_PROFILE_AAC_LC                1
#define NMC_PROFILE_AAC_HE                4
#define NMC_PROFILE_AAC_HE_V2             28
#define NMC_PROFILE_AAC_LD                22
#define NMC_PROFILE_AAC_ELD               38

#define VIDEO_ORIENTATION_PORTRAIT        1
#define VIDEO_ORIENTATION_LANDSCAPE_RIGHT 3
#define VIDEO_ORIENTATION_LANDSCAPE_LEFT  4

#define FLAG_AF  1
#define FLAG_AE  2
#define FLAG_AWB  4

#define NMC_DEVICE_TYPE_WideAngleCamera 0 // 广角
#define NMC_DEVICE_TYPE_TelephotoCamera 1 // 长焦
#define NMC_DEVICE_TYPE_UltraWideCamera 2 // 超广角
#define NMC_DEVICE_TYPE_DualCamera 3 // 双摄
#define NMC_DEVICE_TYPE_TripleCamera 4 // 三摄

#define NMC_EXPORT                        __attribute__((visibility("default")))

@class UIView;

@protocol NodePublisherDelegate

- (void)onEventCallback:(id)sender event:(int)event msg:(NSString *)msg;

@end

NMC_EXPORT
@interface NodePublisher : NSObject

///事件委托
@property (nonatomic, weak) id <NodePublisherDelegate> nodePublisherDelegate;

///日志等级 0-error，1-info，2-debug
@property (nonatomic) NSUInteger logLevel;

/// 是否开启硬件加速编码
@property (nonatomic) Boolean HWAccelEnable;

/// 是否开启背景音降噪
@property (nonatomic) Boolean denoiseEnable;

///音视频内容加密密码，16字节字符串
@property (nonatomic, copy) NSString *cryptoKey;

/////预览前置摄像头画面是否镜像
//@property(nonatomic) Boolean cameraFrontMirror;
//
/////编码前置摄像头画面是否镜像
//@property(nonatomic) Boolean videoFrontMirror;

///视频关键帧间隔，单位秒
@property (nonatomic) NSUInteger keyFrameInterval;

///视频方向
@property (nonatomic) NSUInteger videoOrientation;

///设置麦克风音量，
///0.0 麦克风静音
///1.0 默认值
///2.0 增益
@property (nonatomic) float volume;

@property (nonatomic) Boolean enhancedRtmp;

///以注册码初始化播放器
- (id)initWithLicense:(NSString *)license;

///打开摄像头，是否是前置打开
- (int)openCamera:(Boolean)frontCamera;

///打开指定类型摄像头，是否是前置打开
- (int)openCameraDevice:(int)deviceType withFront:(Boolean)frontCamera;

///关闭摄像头
- (int)closeCamera;

///切换摄像头
- (int)switchCamera;

///设置音频编码参数
- (void)setAudioParamWithCodec:(int)c profile:(int)p samplerate:(int)s channels:(int)ch bitrate:(int)b;

///设置视频编码参数
- (void)setVideoParamWithCodec:(int)c profile:(int)p width:(int)w height:(int)h fps:(int)f bitrate:(int)b;

///开始推送视频流
- (int)start:(NSString *)url;

///停止推送视频流
- (int)stop;

///添加额外输出，可以是直播流地址，也可以是全路径的文件，支持flv,mp4,ts,mkv格式
- (int)addOutput:(NSString *)url;

///移除全部额外输出
- (int)removeOutputs;

///附加到视图
- (void)attachView:(UIView *)view;

///从视图移除
- (void)detachView;

/// 开启闪光灯补光
- (void)enableTorch:(Boolean)enable;

/// 设置缩放, 0.0-1.0
- (void)setRoomRatio:(float)ratio;

/// 设置中心点自动对焦曝光白平衡
- (void)startFocusAndMeteringCenter;

/// 设置自动对焦曝光白平衡
- (void)startFocusAndMetering:(nullable CGPoint*)point withFlags:(int)flags;

@end

NS_ASSUME_NONNULL_END
