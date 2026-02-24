//
//  FUMakeupModel.m
//  XPYCamera
//
//  Created by 项林平 on 2021/7/19.
//

#import "FUMakeupModel.h"

@implementation FUMakeupModel

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.bundleName forKey:@"bundleName"];
    [coder encodeObject:self.icon forKey:@"icon"];
    [coder encodeDouble:self.value forKey:@"value"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.bundleName = [coder decodeObjectForKey:@"bundleName"];
        self.icon = [coder decodeObjectForKey:@"icon"];
        self.value = [coder decodeDoubleForKey:@"value"];
    }
    return self;
}

@end
