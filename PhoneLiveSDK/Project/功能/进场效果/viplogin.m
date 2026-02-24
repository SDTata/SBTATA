//
//  viplogin.m
//  yunbaolive
//
//  Created by 王敏欣 on 2017/7/6.
//  Copyright © 2017年 cat. All rights reserved.
//
#import "viplogin.h"

@interface viplogin()
{
    NSArray *textArray;
}
@end

@implementation viplogin
-(instancetype)initWithFrame:(CGRect)frame andBlock:(xinBlock)blocks{
    self = [super initWithFrame:frame];
    if (self) {
        self.blocks = blocks;
        _isUserMove = 0;
        _userLogin = [NSMutableArray array];
    }
    return self;
}
-(void)addUserMove:(NSDictionary *)msg{
    if (msg == nil) {
    }
    else
    {
        [_userLogin addObject:msg];
    }
    if(_isUserMove == 0){
        [self userLoginOne];
    }
}
-(void)userLoginOne{
    if (_userLogin.count == 0 || _userLogin == nil) {
        return;
    }
    NSDictionary *Dic = [_userLogin firstObject];
    [_userLogin removeObjectAtIndex:0];
    [self userPlar:Dic];
}
-(void)userPlar:(NSDictionary *)dic{
    
    NSString *car_words = [[dic valueForKey:@"ct"] valueForKey:@"car_words"];
    NSString *names = [NSString stringWithFormat:@"%@%@",[[dic valueForKey:@"ct"] valueForKey:@"user_nicename"],car_words];
    textArray = @[names];
    if (_label) {
        [_label stopTimer];
        [_label removeFromSuperview];
        _label = nil;
    }
    CGFloat time = [[[dic valueForKey:@"ct"] valueForKey:@"car_swftime"] floatValue];
    //car_words
    _isUserMove = 1;
    NSString *animationStr = minstr([[dic valueForKey:@"ct"] valueForKey:@"car_swf"]);
    _userMoveImageV = [SDAnimatedImageView new];
    _userMoveImageV.frame = CGRectMake(0,0,_window_width,_window_height);
    _userMoveImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_userMoveImageV];
    WeakSelf
    [_userMoveImageV sd_setImageWithURL:[NSURL URLWithString:animationStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if (error == nil) {
            //        [self showlabelText];
            [strongSelf endAnimationDelay:time];
        } else {
            [strongSelf.userMoveImageV removeFromSuperview];
            [strongSelf showSVGA:animationStr];
        }
    }];
}

- (void)showSVGA:(NSString*)animationStr {
    SVGAParser *parser = [[SVGAParser alloc] init];
    NSURL *swfURL = [NSURL URLWithString:animationStr];
    WeakSelf
    [parser parseWithURL:swfURL completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.player = [[SVGAPlayer alloc] initWithFrame:CGRectMake(0, (_window_height-(_window_width/videoItem.videoSize.width*videoItem.videoSize.height))/2, _window_width, (_window_width/videoItem.videoSize.width*videoItem.videoSize.height))];
        strongSelf.player.loops = 1;
        strongSelf.player.delegate = self;
        strongSelf.player.clearsAfterStop = YES;
        [strongSelf addSubview:strongSelf.player];
        strongSelf.player.videoItem = videoItem;
        [strongSelf.player startAnimation];
//            [strongSelf showlabelText];

    } failureBlock:nil];
}

-(void)showlabelText
{
    _label = [[YFRollingLabel alloc] initWithFrame:CGRectMake(0,_window_height/2,_window_width,20)  textArray:textArray font:[UIFont systemFontOfSize:12] textColor:normalColors];
    _label.backgroundColor = [UIColor clearColor];
    _label.speed = 2;
    [_label setOrientation:RollingOrientationLeft];
    [_label setInternalWidth:_label.frame.size.width / 3];
    [self addSubview:_label];
}

-(void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    [self endAnimationDelay:0];
}

-(void)endAnimationDelay:(CGFloat)time
{
    
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf.userMoveImageV) {
            [strongSelf.userMoveImageV removeFromSuperview];
            strongSelf.userMoveImageV = nil;
        }
        strongSelf.isUserMove = 0;
        [strongSelf.label stopTimer];
        [strongSelf.label removeFromSuperview];
        strongSelf.label = nil;
        if (strongSelf.userLogin.count >0) {
            [strongSelf addUserMove:nil];
        }
        if (strongSelf.userLogin.count <=0) {
            strongSelf.blocks(nil);
        }
    });
}
@end
