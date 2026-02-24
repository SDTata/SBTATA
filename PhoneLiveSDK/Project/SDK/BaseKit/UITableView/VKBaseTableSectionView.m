//
//  VKBaseTableSectionView.m
//
//  Created by vick on 2020/12/15.
//

#import "VKBaseTableSectionView.h"

@implementation VKBaseTableSectionView

+ (CGFloat)itemHeight {
    return 0;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self updateView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self updateView];
}

- (void)updateView {
    
}

- (void)updateData {
    
}

@end
