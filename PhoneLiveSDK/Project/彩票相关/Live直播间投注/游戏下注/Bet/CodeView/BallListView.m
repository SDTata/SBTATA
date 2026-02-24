//
//  BallListView.m
//  phonelive2
//
//  Created by vick on 2025/2/14.
//  Copyright © 2025 toby. All rights reserved.
//

#import "BallListView.h"

@implementation BallListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.axis = UILayoutConstraintAxisHorizontal;
    self.spacing = 2;
    
    for (int i=0; i<10; i++) {
        BallView *ballView = [BallView new];
        ballView.index = i;
        ballView.tag = 1000 + i;
        ballView.hidden = YES;
        [self addArrangedSubview:ballView];
        [ballView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(14);
            make.width.mas_greaterThanOrEqualTo(14);
        }];
    }
}

- (void)setSize:(CGSize)size {
    _size = size;
    for (int i=0; i<10; i++) {
        BallView *ballView = [self viewWithTag:1000 + i];
        [ballView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(size.height);
            make.width.mas_greaterThanOrEqualTo(size.width);
        }];
    }
}

- (void)setCodes:(NSArray *)codes {
    _codes = codes;
    for (int i=0; i<10; i++) {
        BallView *ballView = [self viewWithTag:1000 + i];
        NSString *code = [codes safeObjectWithIndex:i];
        if (code) {
            ballView.hidden = NO;
            ballView.titleLabel.text = [NSString stringWithFormat:@"%@", code];
            if (self.setupStyleBlock) {
                self.setupStyleBlock(ballView);
            }
        } else {
            ballView.hidden = YES;
        }
    }
    if (codes.count <= 0) {
        self.hidden = YES;
    }
}

@end
