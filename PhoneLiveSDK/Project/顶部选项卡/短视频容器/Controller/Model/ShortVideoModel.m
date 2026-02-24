//
//  ShortVideoModel.m
//  phonelive2
//
//  Created by s5346 on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideoModel.h"
#import <FFAES/FFAES.h>
#import <FFAES/GTMBase64.h>

@implementation VideoTagsModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"tag_id": @"id",
             @"tag_name": @"name"};
}
@end

@implementation VideoSizeModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"width": @"w",
             @"height": @"h"};
}

- (BOOL)isProtrait {
    if (self.height <= 0 || self.width <= 0) {
        return YES;
    }
    return self.height >= self.width;
}

- (CGFloat)ratio {
    return self.width / self.height;
}

@end

@implementation ShortVideoModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"video_id": @"id", @"description_": @"description"};
}

- (ShortVideoModelPayType)isNeedPay {
    /*
     还有一种coin_cost" ticket_cost  都有值，优先检查是否有ticket_cost余额。没有就用coin_cost的余额付费。

     is_vip 不为1 表示vip和普通用户都可以操作。is_vip为1表示只有vip可以操作
     */
    if ([self.uid isEqualToString:[Config getOwnID]]) {
        return ShortVideoModelPayTypeFree;
    }
    if (self.can_play != 1) {
        if ([[Config getVip_type] intValue] <= 0 && self.is_vip > 0) {
            return ShortVideoModelPayTypeVIP;
        }
        if (self.ticket_cost > 0) {
            return ShortVideoModelPayTypeTicket;
        }
        if (self.coin_cost > 0) {
            return ShortVideoModelPayTypeCoin;
        }
    }
    return ShortVideoModelPayTypeFree;
}

-(void)setEncrypted_key:(NSString*)encrypted_key
{

    NSString *decor = [FFAES decryptBase64andAESToStr:encrypted_key key:KVideoDecryptionKey];

    _encrypted_key = decor;
    
    
}

- (NSString *)playTimeShow {
    int time = [minnum(self.video_duration) intValue];
    int hh = (int)(time / 3600);
    int mm = (int)((time % 3600) / 60);
    int ss = (int)(time % 60);

    if (hh > 0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hh, mm, ss];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d", mm, ss];
    }
}

- (void)changeEncrypted_key:(NSString*)key {
    _encrypted_key = key;
}

+ (BOOL)showPayTagIfNeed:(NSInteger)coin_cost ticket_cost:(NSInteger)ticket_cost {
    if (coin_cost > 0) {
        return YES;
    }
    return NO;
}

@end
