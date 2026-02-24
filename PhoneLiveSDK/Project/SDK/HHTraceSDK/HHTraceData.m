//
//  HSShareData.m
//  HSShareSDK
//
//  Created by aa on 2020/10/14.
//

#import "HHTraceData.h"

@implementation HHTraceData
- (instancetype)init
{
    self = [super init];
    if (self) {
        _channel =@"";
        _parameters=@"";
    }
    return self;
}
@end
