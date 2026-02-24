//
//  VideoProgressManager.m
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoProgressManager.h"

@implementation VideoProgressManager

+(void)saveUserProgress:(NSString*)progress skitId:(NSString*)skitId episodeNumber:(NSInteger)episodeNumber {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[VideoProgressManager loadUserProgress:skitId]];
    NSArray *progressArray = [progress componentsSeparatedByString:@"|"];
    if (progressArray.count < 2) {
        return;
    }
    dictionary[minnum(episodeNumber)] = progress;
    dictionary[@"currentEpisode"] = minnum(episodeNumber);
    NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingFormat:@"/Skit/%@/", [Config getOwnID]];
    NSString *filePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dat", skitId]];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    [dictionary writeToFile:filePath atomically:YES];
}

+(NSDictionary*)loadUserProgress:(NSString*)skitId {
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"Skit/%@/%@.dat", [Config getOwnID], skitId]];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return dic;
}

+(DramaProgressModel*)loadProgress:(NSString*)skitId episodeNumber:(NSInteger)episodeNumber {
    NSDictionary *progressDic = [VideoProgressManager loadUserProgress:skitId];
    NSString *progress = progressDic[minnum(episodeNumber)];
    NSArray *array = [progress componentsSeparatedByString:@"|"];
    DramaProgressModel *model = [[DramaProgressModel alloc] init];
    model.episode_number = episodeNumber;
    model.currentTime = 0;
    model.totalTime = 0;
    if (array.count < 2) {
        return model;
    }

    model.episode_number = episodeNumber;
    model.currentTime = [array[0] intValue];
    model.totalTime = [array[1] intValue];
    return model;
}

@end
