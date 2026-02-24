//
//  FMBackModeManager.m
//  BackModeDemo
//
//  Created by LIUSONG on 2019/4/2.
//  Copyright © 2019 Rayor. All rights reserved.
//

#import "FMBackModeManager.h"
#import <AVFoundation/AVFoundation.h>
#import "Livebroadcast.h"
@interface FMBackModeManager()
/** 播放器，如果想让音频没有声音，不要赋值即可 */
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation FMBackModeManager

+ (instancetype)shared {
	static FMBackModeManager * manager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[FMBackModeManager alloc] init];
	});
	return manager;
}

- (void)activeBackMode {
	
	if (self.isActive) {
		return;
	}
    if (![[MXBADelegate sharedAppDelegate].topViewController isKindOfClass:[Livebroadcast class]]) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
	
	//让 app 支持接受远程控制事件
	//	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	
	//播放背景音乐
	NSString *musicPath = [[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])] pathForResource:@"backMusic" ofType:@"mp3"];
	NSURL *url = [[NSURL alloc]initFileURLWithPath:musicPath];
	
	//创建播放器
	AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
	
	[audioPlayer prepareToPlay];
	audioPlayer.volume = 1.0;
	self.soundActive = YES;
	
	//无限循环播放
	audioPlayer.numberOfLoops=-1;
	[audioPlayer play];
	
	self.audioPlayer = audioPlayer;
}


- (void)invalidBackModel {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
	
}

- (void)setSoundActive:(BOOL)soundActive {
	_soundActive = soundActive;
    if (self.audioPlayer) {
        self.audioPlayer.volume = _soundActive ? 1.0 : 0.0;
    }
	
}

- (BOOL)isActive {
	return self.audioPlayer && self.audioPlayer.isPlaying;
}

@end
