//
//  LiveEncodeCommon.m
//  phonelive2
//
//  Created by 400 on 2021/5/8.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LiveEncodeCommon.h"

@implementation LiveEncodeCommon
static LiveEncodeCommon* manager = nil;

/** 单例类方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[super allocWithZone:NULL] init];
            manager.isOpenEncode = YES;
            manager.isOpenEncodeSDK = YES;
            manager.enableEn = YES;
            manager.column = 8;
            manager.line = 16;
            manager.bitwise_not=true;
            manager.flip = true;
            manager.bitrate = 1800;
        }
        
    });
    
    return manager;
}

-(void)setColumn:(int)column
{
    if (column >0) {
        _column = column;
    }else{
        _column = 8;
    }
}
-(void)setLine:(int)line
{
    if (line>0) {
        _line = line;
    }else{
        _line = 16;
    }
}
-(void)setBitrate:(int)bitrate
{
    if (bitrate>0) {
        _bitrate = bitrate;
    }else{
        _bitrate = 1800;
    }
}

@end
