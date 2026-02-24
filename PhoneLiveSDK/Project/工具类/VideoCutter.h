//
//  VideoCutter.h
//  phonelive
//
//  Created by 400 on 2020/8/4.
//  Copyright © 2020 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoCutter : NSObject

-(void)cropVideoWithUrl:(NSURL *)url andStartTime:(CGFloat)startTime andDuration:(CGFloat)duration andCompletion:(void(^)(NSURL * videoPath,NSError * error))task ;

@end
