//
//  LotteryVoiceUtil.h
//  phonelive2
//
//  Created by vick on 2023/12/11.
//  Copyright © 2023 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LotteryVoiceUtil : NSObject
VK_SINGLETON_H

/// 静音状态，0有声音 1 禁止背景音乐 2 禁止全部声音
@property (nonatomic, assign) NSInteger muteValue;

/// 静音状态图标
@property (nonatomic, copy, readonly) NSString *muteImage;

/// 播放背景音
- (void)startPlayBGM:(NSString *)fileUrl;

/// 播放提示音
- (void)startPlayHint:(NSString *)fileName;

/// 播放游戏音效
- (void)startPlayAward:(NSString *)fileName;

/// 停止背景音
- (void)stopPlayBGM;

/// 停止提示音
- (void)stopPlayHint;

/// 停止游戏音效
- (void)stopPlayAward;

@end
