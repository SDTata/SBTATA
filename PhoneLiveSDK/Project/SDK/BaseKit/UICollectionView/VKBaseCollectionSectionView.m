//
//  VKBaseCollectionSectionView.m
//
//  Created by vick on 2020/11/10.
//

#import "VKBaseCollectionSectionView.h"

@implementation VKBaseCollectionSectionView

+ (CGFloat)itemHeight {
    return 10;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
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
