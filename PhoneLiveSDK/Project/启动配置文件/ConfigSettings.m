//
//  ConfigSettings.m
//  phonelive2
//
//  Created by 400 on 2022/3/29.
//  Copyright © 2022 toby. All rights reserved.
//

#import "ConfigSettings.h"
#import "DomainManager.h"
@implementation ConfigSettings
+(void)defaultDomains:(DomainManager*)managers
{

    managers.sub_plat = @"0";
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"com.phonelive.plat"];
    managers.domainCode = [appName stringByReplacingOccurrencesOfString:@"c" withString:@""];
    
    NSString *kefuStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"com.phonelive.platKefu"];
    managers.kefuServer = kefuStr;
    managers.platName = appName;

}

+(NSString*)currentLaunchImgName{
//    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"com.phonelive.plat"];
//     if(appName!= nil && [appName isEqualToString:@"c607"]){
//        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//        if([appName isEqualToString:@"IOULive"]){
//            return @"img_c607yuenan";
//        }
//        return @"img_c607";
//    }
//     else {
//         NSString *imgName = [NSString stringWithFormat:@"img_%@",appName];
//         return imgName;
//     }
    return  nil;
}



+(NSDateFormatter*)formatters:(NSString*)formStr{
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formStr];
    formatter.timeZone = timeZone;
    return formatter;
}


//播放器ffmpeg-xxx修改libavformat配置hls.c
//char valuecryption_buffer[33] = {0};
//AVDictionaryEntry *entry = av_dict_get(c->avio_opts, "cryptionNum", NULL, 0);
//if (entry) {
//    strncpy(valuecryption_buffer, entry->value, sizeof(valuecryption_buffer) - 1);
//    size_t entry_length = strlen(entry->value);
//
//    if (entry_length>=16) {
//        ff_data_to_hex(key, valuecryption_buffer, sizeof(valuecryption_buffer), 0);
//    }else{
//        ff_data_to_hex(key, pls->key, sizeof(pls->key), 0);
//    }
//} else {
//    ff_data_to_hex(key, pls->key, sizeof(pls->key), 0);
//}


//"[\u4e00-\u9fff]


@end
