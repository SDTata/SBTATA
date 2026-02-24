//
//  VKMarqueeView.m
//
//  Created by vick on 2023/8/11.
//

#import "VKMarqueeView.h"
#import "UIView+WPFExtension.h"
// 基础重复数
#define TYX_MUTIPLY_COUNT 3

@interface VKMarqueeView ()
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, copy) NSMutableArray<NSString *> *mutipleTitles;
@property (nonatomic, copy) NSMutableArray<UILabel *> *labels;
@end

@implementation VKMarqueeView {
    NSInteger multiplerCount;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat speed = 0.5;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.stop) {
                self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(run)];
                [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            }
        });
        
        self.speed = speed;
        self.opaque = YES;
        _mutipleTitles = [NSMutableArray new];
        _labels = [NSMutableArray new];
        
        self.space = 100;
        self.scrollEnabled = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

- (void)setStop:(BOOL)stop {
    _stop = stop;
    [self.displayLink setPaused:stop];
    [self.displayLink invalidate];
    self.displayLink = nil;
    [_mutipleTitles removeAllObjects];
    [_labels removeAllObjects];
    _titles = nil;
}

- (void)setPaused:(BOOL)paused {
    [self.displayLink setPaused:paused];
}

- (void)setTitles:(NSArray<NSString *> *)titles {
    
    @synchronized (self) {
        _titles = [titles copy];
        _offset = 0;
        multiplerCount = TYX_MUTIPLY_COUNT;
        
        // 增加重复数量
        if (titles.count < 3) { multiplerCount = TYX_MUTIPLY_COUNT * (4 - titles.count); }
        
        // 避免消耗过多的内存资源
        if (titles.count >= 5) { multiplerCount = 1; }
        
        for (UILabel *label in self.labels) { [label removeFromSuperview]; }

        [self.mutipleTitles removeAllObjects];
        
        CGFloat textWidth = 0;
        if (self.fromStartX != nil) {
            textWidth = [self.fromStartX floatValue];
        }
        for (int i = 0; i < multiplerCount * titles.count; i++) {
            NSInteger index = i % titles.count;
            
            UILabel *label;
            if (self.labels.count <= i) {
                label = [UILabel new];
                label.font = self.font;
                label.textColor = self.textColor;
                [self.labels addObject:label];
            } else {
                label = self.labels[i];
            }
            label.text = titles[index];
            label.frame = [label textRectForBounds:CGRectMake(0, 0, MAXFLOAT, MAXFLOAT) limitedToNumberOfLines:1];
            label.height = self.height;
            label.x = (NSInteger)textWidth;
            label.y = 0;
            label.userInteractionEnabled = YES;
            [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapAction:)]];
            
            [self.mutipleTitles addObject:label.text];
            textWidth = CGRectGetMaxX(label.frame) + self.space;
            [self addSubview:label];
        }
        
        self.contentSize = CGSizeMake(textWidth, self.height);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *subV in self.subviews) {
        if ([subV isKindOfClass:UILabel.class]) {
            subV.height = self.height;
        }
    }
}

- (void)labelTapAction:(UIGestureRecognizer *)ges {
    
    UIView *label = [ges view];
    if ([label isKindOfClass:UILabel.class]) {
        NSInteger index = [self.labels indexOfObject:(UILabel *)label];
        if (self.clickBlock) {
            self.clickBlock(index % self.titles.count);
        }
    }
}

- (void)run {
    if (self.stop) {
        return;
    }
    if (!self.mutipleTitles.count) { return; }
    if (!self.window) { return; }
    
    self.offset += self.speed;
    
    if (self.contentSize.width-self.space < self.offset) {
        self.offset = 0;
    }
    
    self.contentOffset = CGPointMake(self.offset, 0);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self setStop:YES];
    }
}

@end
