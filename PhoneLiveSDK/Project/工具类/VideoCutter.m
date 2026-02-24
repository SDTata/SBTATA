//
//  VideoCutter.m
//  phonelive
//
//  Created by 400 on 2020/8/4.
//  Copyright © 2020 toby. All rights reserved.
//

#import "VideoCutter.h"

@implementation VideoCutter
-(void)cropVideoWithUrl:(NSURL *)url andStartTime:(CGFloat)startTime andDuration:(CGFloat)duration andCompletion:(void(^)(NSURL * videoPath,NSError * error))task{

    dispatch_queue_t globalDispatchQueueDefault = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//由于本人也是参考其他大神的作品发挥的，所以可能理解的不是很准确。

    dispatch_async(globalDispatchQueueDefault, ^{
        AVURLAsset * asset = [[AVURLAsset alloc] initWithURL:url options:nil] ;
        AVAssetExportSession * exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:@"AVAssetExportPresetHighestQuality"] ;
//这里是得到一个视频转码类AVAssetExportSession 然后质量是最高
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) ;
        NSString * outputURL = paths.firstObject ;
        NSFileManager * manager = [NSFileManager defaultManager] ;
    
        [manager createDirectoryAtPath:outputURL withIntermediateDirectories:true attributes:nil error:nil] ;
    
        outputURL = [outputURL stringByAppendingPathComponent:@"output.mp4"] ;
        //拿到转码后的视频地址

        [manager removeItemAtPath:outputURL error:nil] ;
    
        if ([exportSession isKindOfClass:[AVAssetExportSession class]]) {
            exportSession.outputURL = [[NSURL alloc] initFileURLWithPath:outputURL] ;
            exportSession.shouldOptimizeForNetworkUse = true ;
            exportSession.outputFileType = AVFileTypeMPEG4 ;
            Float64 duration64 = duration ;
            Float64 startTime64 = startTime ;
            CMTime start = CMTimeMakeWithSeconds(startTime64, 600) ;
            CMTime duration = CMTimeMakeWithSeconds(duration64, 600) ;
            CMTimeRange range = CMTimeRangeMake(start, duration) ;
            exportSession.timeRange = range ;
        
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                switch (exportSession.status) {
                    case AVAssetExportSessionStatusCompleted:
                        task(exportSession.outputURL,nil) ;
                      //转换ok后把视频地址block回去
                        break;
                    case AVAssetExportSessionStatusFailed:
                        NSLog(@"%@",exportSession.error) ;
                        break;
                    case AVAssetExportSessionStatusCancelled:
                        NSLog(@"%@",exportSession.error) ;
                        break;
                    default:
                        NSLog(@"default case") ;
                        break;
                }
            }] ;
        }
        dispatch_main_async_safe(^{
        //回到主线程
        });
    }) ;
}

@end
