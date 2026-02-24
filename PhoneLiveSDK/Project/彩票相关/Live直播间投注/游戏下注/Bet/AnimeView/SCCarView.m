//
//  SCCarView.m
//  phonelive2
//
//  Created by vick on 2023/12/19.
//  Copyright © 2023 toby. All rights reserved.
//

#import "SCCarView.h"
#import "LiveGifImage.h"
@interface SCCarView()

@property (nonatomic, strong) YYAnimatedImageView *carImgView;

@end

@implementation SCCarView

- (CGFloat)releaseX {
    return self.layer.presentationLayer.frame.origin.x;
}

- (instancetype)initWithIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        self.index = index;
        [self setupView];
        [self speedStopAnimation];
    }
    return self;
}

- (void)setupView {
    YYAnimatedImageView *carImgView = [YYAnimatedImageView new];
    carImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:carImgView];
    self.carImgView = carImgView;
    [carImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)speedStartAnimation {
    NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:[NSString stringWithFormat:@"sc_car%ld", self.index] ofType:@"gif"];
    LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
    [imgAnima setAnimatedImageLoopCount:0];
    self.carImgView.image = imgAnima;
    [self.carImgView startAnimating];
}

- (void)speedStopAnimation {
    [self.carImgView stopAnimating];
    self.carImgView.image = nil;
    self.carImgView.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"sc_car_%ld", self.index]];
}

- (void)speedUpAnimation {
    
}

- (void)speedDownAnimation {
    
}

@end
