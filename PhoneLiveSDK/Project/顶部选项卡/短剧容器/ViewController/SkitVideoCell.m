//
//  SkitVideoCell.m
//  phonelive2
//
//  Created by vick on 2024/9/30.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitVideoCell.h"

@implementation SkitVideoCell

+ (NSInteger)itemCount {
    return 2;
}

+ (CGFloat)itemSpacing {
    return 10;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+ (CGFloat)itemHeight {
    return VKPX(200);
}

- (void)updateData {
    [self update:self.itemModel];
}

@end


@implementation SkitVideoThreeCell

+ (NSInteger)itemCount {
    return 3;
}

+ (CGFloat)itemSpacing {
    return 0;
}

+ (CGFloat)itemLineSpacing {
    return  10;
}

+ (CGFloat)itemHeight {
    return VKPX(130);
}

+ (CGFloat)itemWidth {
    return VKPX(100);
}

@end
