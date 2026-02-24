//
//  BetAnimationView_SSC.m
//  phonelive2
//
//  Created by vick on 2023/12/15.
//  Copyright © 2023 toby. All rights reserved.
//

#import "BetAnimationView_SSC.h"
#import "LotteryVoiceUtil.h"

@interface BetAnimationView_SSC () {
    NSMutableArray *numbersText;
    NSMutableArray *scrollLayers;
    NSMutableArray *scrollLabels;
}

@end

@implementation BetAnimationView_SSC

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    [LotteryVoiceUtil.shared stopPlayAward];
    VKLOG(@"%@ - dealloc", NSStringFromClass(self.class));
}

- (void)commonInit
{
    self.duration = 1.5;
    self.durationOffset = 0.2;
    self.density = 5;
    self.minLength = 0;
    self.isAscending = NO;
    self.isFinish = NO;
    
    self.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    self.textColor = [UIColor blackColor];
    
    numbersText = [NSMutableArray new];
    scrollLayers = [NSMutableArray new];
    scrollLabels = [NSMutableArray new];
    
    UIImageView *bgImgView = [UIImageView new];
    bgImgView.image = [ImageBundle imagewithBundleName:@"ssc_bg"];
    [self addSubview:bgImgView];
    [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(-25);
        make.bottom.mas_equalTo(30);
        make.left.mas_equalTo(-40);
        make.right.mas_equalTo(40);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(100);
    }];
}

- (void)clear
{
    for(CALayer *layer in scrollLayers){
        [layer removeFromSuperlayer];
    }
    
    [numbersText removeAllObjects];
    [scrollLayers removeAllObjects];
    [scrollLabels removeAllObjects];
}

- (void)startAnimation
{
    self.isFinish = NO;
    [self prepareAnimations];
    [self createAnimations];
    
    [LotteryVoiceUtil.shared startPlayAward:@"ssc_game"];
}

- (void)stopAnimation
{
    self.isFinish = YES;
    [self prepareAnimations];
    [self createAnimations];
    
    vkGcdAfter(1.0, ^{
        [LotteryVoiceUtil.shared stopPlayAward];
    });
}

- (void)prepareAnimations
{
    [self clear];
    [self createNumbersText];
    [self createScrollLayers];
}

- (void)createNumbersText
{
    NSString *textValue = self.winValue;
    
    for(NSInteger i = 0; i < (NSInteger)self.minLength - (NSInteger)[textValue length]; ++i){
        [numbersText addObject:@"0"];
    }
    
    for(NSUInteger i = 0; i < [textValue length]; ++i){
        [numbersText addObject:[textValue substringWithRange:NSMakeRange(i, 1)]];
    }
}

- (void)createScrollLayers
{
    CGFloat width = roundf(CGRectGetWidth(self.frame) / numbersText.count);
    CGFloat height = CGRectGetHeight(self.frame);
    
    for(NSUInteger i = 0; i < numbersText.count; ++i){
        CAScrollLayer *layer = [CAScrollLayer layer];
        layer.frame = CGRectMake(roundf(i * width), 0, width, height);
        [scrollLayers addObject:layer];
        [self.layer addSublayer:layer];
    }
    
    for(NSUInteger i = 0; i < numbersText.count; ++i){
        CAScrollLayer *layer = scrollLayers[i];
        NSString *numberText = numbersText[i];
        [self createContentForLayer:layer withNumberText:numberText];
    }
}

- (void)createContentForLayer:(CAScrollLayer *)scrollLayer withNumberText:(NSString *)numberText
{
    NSInteger number = [numberText integerValue];
    NSMutableArray *textForScroll = [NSMutableArray new];
    
    for(NSUInteger i = 0; i < self.density + 1; ++i){
        [textForScroll addObject:[NSString stringWithFormat:@"%lu", (number + i) % 10]];
    }
    
    [textForScroll addObject:numberText];

    if(!self.isAscending){
        textForScroll = [[[textForScroll reverseObjectEnumerator] allObjects] mutableCopy];
    }
    
    CGFloat height = 0;
    for(NSString *text in textForScroll){
        UIImageView * textLabel = [self createLabel:text];
        textLabel.frame = CGRectMake(0, height, CGRectGetWidth(scrollLayer.frame), CGRectGetHeight(scrollLayer.frame));
        [scrollLayer addSublayer:textLabel.layer];
        [scrollLabels addObject:textLabel];
        height = CGRectGetMaxY(textLabel.frame);
    }
}

- (UIImageView *)createLabel:(NSString *)text
{
    UIImageView *view = [UIImageView new];
    view.contentMode = UIViewContentModeScaleAspectFit;
    view.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ssc_%@", text]];
    return view;
}

- (void)createAnimations
{
    CFTimeInterval duration = self.duration - ([numbersText count] * self.durationOffset);
    CFTimeInterval offset = 0;
    
    for(CALayer *scrollLayer in scrollLayers){
        CGFloat maxY = [[scrollLayer.sublayers lastObject] frame].origin.y;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.y"];
        animation.duration = duration + offset;
        animation.repeatCount = INFINITY;
        
        if (self.isFinish) {
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            animation.repeatCount = 1;
        }
        
        if(self.isAscending){
            animation.fromValue = [NSNumber numberWithFloat:-maxY];
            animation.toValue = @0;
        }
        else{
            animation.fromValue = @0;
            animation.toValue = [NSNumber numberWithFloat:-maxY];
        }
        
        [scrollLayer addAnimation:animation forKey:@"JTNumberScrollAnimatedView"];
        
        offset += self.durationOffset;
    }
}

@end
