//
//  LiveUser.m
//  yunbaolive
//
//  Created by cat on 16/3/9.
//  Copyright © 2016年 cat. All rights reserved.
//

#import "LiveUser.h"
@implementation LiveAppItem
- (instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super init]) {
        self.id = [coder decodeObjectForKey:@"id"];
        self.info = [coder decodeObjectForKey:@"info"];
        self.app_logo = [coder decodeObjectForKey:@"app_logo"];
        self.app_name = [coder decodeObjectForKey:@"app_name"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:_id forKey:@"id"];
    [coder encodeObject:_info forKey:@"info"];
    [coder encodeObject:_app_logo forKey:@"app_logo"];
    [coder encodeObject:_app_name forKey:@"app_name"];
}

@end

@implementation LiveUser

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.ID = value;
    }
}

-(instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if(self)
    {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+(instancetype)modelWithDic:(NSDictionary *)dic
{
    return [[self alloc] initWithDic:dic];
}

-(void)setIsBindMobile:(BOOL)isBindMobile
{
#ifdef LIVE
    _isBindMobile = true;
#else
    _isBindMobile = isBindMobile;
#endif
}
@end
