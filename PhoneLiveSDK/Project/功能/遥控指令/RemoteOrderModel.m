//
//  RemoteOrderModel.m
//  phonelive2
//
//  Created by s5346 on 2023/12/14.
//  Copyright © 2023 toby. All rights reserved.
//

#import "RemoteOrderModel.h"

@implementation RemoteOrderModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.imagePath = [dic valueForKey:@"gifticon"];
        self.price = [dic valueForKey:@"needcoin"];
        self.type = [dic valueForKey:@"type"];
        self.giftname = minstr(dic[@"giftname"]);
        self.ID = [dic valueForKey:@"id"];
        self.mark = [dic valueForKey:@"mark"];
        NSString *shockTime = [minstr(dic[@"shocktime"]) stringByReplacingOccurrencesOfString:@".00" withString:@""];
        self.shocktime = shockTime;
        self.shocktype = [dic valueForKey:@"shocktype"];
        self.cmdType = @"0";
        
        if (dic[@"name"]) {
            self.giftname = minstr(dic[@"name"]);
            self.cmdType = @"1";
        }
        if (dic[@"price"]) {
            self.price = dic[@"price"];
        }
        if (dic[@"duration"]) {
            self.shocktime = dic[@"duration"];
        }
    }
    return self;
}

+(instancetype)modelWithDic:(NSDictionary *)dic{
    return  [[self alloc]initWithDic:dic];
}
@end
