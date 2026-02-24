//
//  FUBeautyFilterModel.m
//  FURTCDemo
//
//  Created by 项林平 on 2023/2/6.
//

#import "FUBeautyFilterModel.h"

@implementation FUBeautyFilterModel

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.filterName forKey:@"filterName"];
    [coder encodeDouble:self.filterLevel forKey:@"filterLevel"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.filterName = [coder decodeObjectForKey:@"filterName"];
        self.filterLevel = [coder decodeDoubleForKey:@"filterLevel"];
    }
    return self;
}

@end
