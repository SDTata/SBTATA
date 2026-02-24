//
//  LotteryVoiceUtil.m
//  phonelive2
//
//  Created by vick on 2023/12/11.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryVoiceUtil.h"
#import "VIMediaCache.h"

@interface LotteryVoiceUtil ()

/// 背景音
@property (nonatomic, strong) AVPlayer *bgmPlayer;
/// 提示音
@property (nonatomic, strong) AVAudioPlayer *hintPlayer;
/// 游戏音效
@property (nonatomic, strong) AVAudioPlayer *awardPlayer;

@property (nonatomic, strong) VIResourceLoaderManager *resourceLoaderManager;

@end

@implementation LotteryVoiceUtil
VK_SINGLETON_M

- (instancetype)init {
    self = [super init];
    if (self) {
        self.muteValue = [common soundControlValue];
    }
    return self;
}

/// 播放背景音
- (void)startPlayBGM:(NSString *)fileUrl {
    if (!fileUrl || ![fileUrl hasPrefix:@"http"]) {
        VKLOG(@"播放地址无效");
        return;
    }
    
    /// 先停止播放器
    [self stopPlayBGM];
    
    
    NSURL *originUrl = [NSURL URLWithString:fileUrl];
//    VIResourceLoaderManager *resourceLoaderManager = [VIResourceLoaderManager new];
//    self.resourceLoaderManager = resourceLoaderManager;
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:originUrl];
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    player.automaticallyWaitsToMinimizeStalling = NO;
    [player play];
    VKLOG(@"开始播放：%@", fileUrl);
    self.bgmPlayer = player;
    
    /// 播放结束通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
    
    /// 静音状态
    self.muteValue = [common soundControlValue];
}

/// 停止背景音
- (void)stopPlayBGM {
    if (self.bgmPlayer) {
        [self.bgmPlayer pause];
    }
    self.bgmPlayer = nil;
}

/// 播放提示音
- (void)startPlayHint:(NSString *)fileName {
    NSString *path = [NSString stringWithFormat:@"%@", fileName];
    NSURL *url = [[XBundle currentXibBundleWithResourceName:@""] URLForResource:path withExtension:@"mp3"];
    if (!url) {
        VKLOG(@"未找到文件：%@", fileName);
        return;
    }
    /// 如果正在播放同一个音乐，直接返回
    if (self.hintPlayer && self.hintPlayer.isPlaying && ([self.hintPlayer.url.absoluteString isEqualToString:url.absoluteString])) {
        VKLOG(@"正在播放：%@", url);
        return;
    }
    /// 先停止播放器
    [self stopPlayHint];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    player.numberOfLoops = 0;
    [player prepareToPlay];
    [player play];
    VKLOG(@"开始播放：%@", fileName);
    self.hintPlayer = player;
    
    /// 静音状态
    self.muteValue = [common soundControlValue];
}

/// 停止提示音
- (void)stopPlayHint {
    if (self.hintPlayer) {
        [self.hintPlayer stop];
    }
    self.hintPlayer = nil;
}

/// 播放游戏音效
- (void)startPlayAward:(NSString *)fileName {
    NSString *path = [NSString stringWithFormat:@"%@", fileName];
    NSURL *url = [[XBundle currentXibBundleWithResourceName:@""] URLForResource:path withExtension:@"mp3"];
    if (!url) {
        VKLOG(@"未找到文件：%@", fileName);
        return;
    }
    /// 如果正在播放同一个音乐，直接返回
    if (self.awardPlayer && self.awardPlayer.isPlaying && ([self.awardPlayer.url.absoluteString isEqualToString:url.absoluteString])) {
        VKLOG(@"正在播放：%@", url);
        return;
    }
    /// 先停止播放器
    [self stopPlayAward];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    player.numberOfLoops = -1;
    [player prepareToPlay];
    [player play];
    VKLOG(@"开始播放：%@", fileName);
    self.awardPlayer = player;
    
    /// 静音状态
    self.muteValue = [common soundControlValue];
}

/// 停止游戏音效
- (void)stopPlayAward {
    if (self.awardPlayer) {
        [self.awardPlayer stop];
    }
    self.awardPlayer = nil;
}

/// 背景音乐播放结束
- (void)playbackFinished:(NSNotification *)notification {
    if (self.bgmPlayer) {
        [self.bgmPlayer seekToTime:kCMTimeZero];
        [self.bgmPlayer play];
    }
}

/// 静音状态
- (void)setMuteValue:(NSInteger)muteValue {
    _muteValue = muteValue;
    [self updateMute];
    [common soundControl:(int)muteValue];
}

- (void)updateMute {
    switch (self.muteValue) {
        case 1:
            self.bgmPlayer.volume = 0;
            self.hintPlayer.volume = 1;
            self.awardPlayer.volume = 1;
            break;
        case 2:
            self.bgmPlayer.volume = 0;
            self.hintPlayer.volume = 0;
            self.awardPlayer.volume = 0;
            break;
        default:
            self.bgmPlayer.volume = 1;
            self.hintPlayer.volume = 1;
            self.awardPlayer.volume = 1;
            break;
    }
}

- (NSString *)muteImage {
    switch (self.muteValue) {
        case 1:
            return @"game_music_close";
        case 2:
            return @"game_music_close_all";
        default:
            return @"game_music_open";
    }
}

@end
