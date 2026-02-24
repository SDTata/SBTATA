//
//  ShortVideoProgressManager.m
//  phonelive2
//
//  Created by s5346 on 2024/8/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideoProgressManager.h"

@implementation ShortVideoProgressManager

+(void)saveUserProgress:(NSString*)progress videoId:(NSString*)videoId title:(NSString*)title {
    NSArray *progressArray = [progress componentsSeparatedByString:@"|"];
    if (progressArray.count < 1) {
        return;
    }

    NSString *key = [ShortVideoProgressManager getKeyVideoId:videoId title:title];
    NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingFormat:@"/ShortVideo/%@/", [Config getOwnID]];
    NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dat", key]];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    [progress writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+(NSString*)loadUserProgress:(NSString*)key {
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"ShortVideo/%@/%@.dat", [Config getOwnID], key]];
    NSString *progressString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return progressString;
}

+(ShortVideoProgressModel*)loadProgress:(NSString*)videoId title:(NSString*)title {
    NSString *key = [ShortVideoProgressManager getKeyVideoId:videoId title:title];
    NSString *progressString = [ShortVideoProgressManager loadUserProgress:key];
    NSArray *array = [progressString componentsSeparatedByString:@"|"];
    ShortVideoProgressModel *model = [[ShortVideoProgressModel alloc] init];
    model.currentTime = 0;
    model.totalTime = 0;
    if (array.count < 1) {
        return model;
    }

    model.currentTime = [array[0] intValue];
    model.totalTime = [array[1] intValue];
    return model;
}

+(NSString*)getKeyVideoId:(NSString*)videoId title:(NSString*)title {
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", videoId, [Config getOwnID], [title toMD5]];
    return key;
}

@end
