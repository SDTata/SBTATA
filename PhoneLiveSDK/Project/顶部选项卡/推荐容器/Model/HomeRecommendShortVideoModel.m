//
//  HomeRecommendShortVideoModel.m
//  phonelive2
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeRecommendShortVideoModel.h"

//@implementation HomeRecommendShortVideo
//
//+ (NSDictionary *)mj_replacedKeyFromPropertyName {
//    return @{@"video_id": @"id", @"description_": @"description"};
//}
//
//- (ShortVideoModelPayType)isNeedPay {
//    /*
//     还有一种coin_cost" ticket_cost  都有值，优先检查是否有ticket_cost余额。没有就用coin_cost的余额付费。
//
//     is_vip 不为1 表示vip和普通用户都可以操作。is_vip为1表示只有vip可以操作
//     */
//    if (self.can_play != 1) {
//        if (self.is_vip > 0 && [[Config getVip_type] intValue] <= 0) {
//            return ShortVideoModelPayTypeVIP;
//        }
//        if (self.ticket_cost > 0) {
//            return ShortVideoModelPayTypeTicket;
//        }
//        if (self.coin_cost > 0) {
//            return ShortVideoModelPayTypeCoin;
//        }
//    }
//    return ShortVideoModelPayTypeFree;
//}
//
//-(void)setEncrypted_key:(NSString*)encrypted_key
//{
//
//    NSString *decor = [FFAES decryptBase64andAESToStr:encrypted_key key:KVideoDecryptionKey];
//
//    _encrypted_key = decor;
//
//
//}
//
//@end

@implementation HomeRecommendShortVideoModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"className": @"class"};
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"data" : [ShortVideoModel class]};
}

- (BOOL)isScroll {
    if (self.layout_column == 0) {
        return YES;
    }

    return NO;
}

@end
