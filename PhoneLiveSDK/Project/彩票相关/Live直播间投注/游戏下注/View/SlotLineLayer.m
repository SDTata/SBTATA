//
//  SlotLineLayer.m
//  SlotDemo
//
//  Created by test on 2022/1/3.
//

#import "SlotLineLayer.h"
@interface SlotLineLayer(){
    CGFloat repeatCount;
}
@property(nonatomic,strong)NSTimer *timer;
@end
@implementation SlotLineLayer
- (instancetype)init{
    if (self = [super init]) {
        repeatCount = 0;
        WeakSelf
        NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf.repeatCount == 4) {
                [self removeFromSuperlayer];
            }
            self.hidden = !self.isHidden;
            strongSelf.repeatCount = strongSelf.repeatCount + 1;
        }];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.timer = timer;
    }
    return self;
}
- (void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
}
@end
