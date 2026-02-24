//
//  FUBeautySkinModel.m
//  FUDemo
//
//  Created by 项林平 on 2021/7/19.
//

#import "FUBeautySkinModel.h"

@implementation FUBeautySkinModel

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeInteger:self.type forKey:@"type"];
    [coder encodeDouble:self.currentValue forKey:@"currentValue"];
    [coder encodeDouble:self.defaultValue forKey:@"defaultValue"];
    [coder encodeBool:self.defaultValueInMiddle forKey:@"defaultValueInMiddle"];
    [coder encodeInteger:self.ratio forKey:@"ratio"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.type = [coder decodeIntegerForKey:@"type"];
        self.currentValue = [coder decodeDoubleForKey:@"currentValue"];
        self.defaultValue = [coder decodeDoubleForKey:@"defaultValue"];
        self.defaultValueInMiddle = [coder decodeBoolForKey:@"defaultValueInMiddle"];
        self.ratio = [coder decodeIntegerForKey:@"ratio"];
    }
    return self;
}

@end
