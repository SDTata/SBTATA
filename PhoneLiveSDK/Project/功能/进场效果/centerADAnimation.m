//
//  centerADAnimation.m
//  yunbaolive
//
//  Created by 王敏欣 on 2017/2/21.
//  Copyright © 2017年 cat. All rights reserved.
//
#import "centerADAnimation.h"
@implementation centerADAnimation
-(instancetype)init{
    self = [super init];
    if (self) {
        _isADMove = 0;
        _ad = [NSMutableArray array];
        _curUrl = @"";
        
        NSString * adText = [Config getADText];
        NSString * adUrl = [Config getADUrl];
        [self addAD:@{@"text":adText, @"url":adUrl}];
        
        
    }
    return self;
}
-(void)addAD:(NSDictionary *)msg{
    
    if (msg == nil) {
    }
    else
    {
        [_ad addObject:msg];
    }
    if(_isADMove == 0){
        [self playOne];
    }
}
-(void)playOne{
    
    if (_ad.count == 0 || _ad == nil) {
        return;
    }
    NSDictionary *Dic = [_ad firstObject];
    [_ad removeObjectAtIndex:0];
    [self doPlay:Dic];
}
-(void)doPlay:(NSDictionary *)dic{
    _isADMove = 1;
    _userMoveImageV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width + 20,0, _window_width*0.8,20)];
    [_userMoveImageV setImage:[ImageBundle imagewithBundleName:@"userlogin_Back"]];
//    _userMoveImageV.alpha = 0;
    _userMoveImageV.visible = false;
    [self addSubview:_userMoveImageV];
    _msgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 30)];
//    _msgView.backgroundColor = [UIColor clearColor];
    _msgView.backgroundColor = RGB_COLOR(@"#000000", 0.2);
    _msgView.alpha = 1;
    _msgView.layer.masksToBounds = YES;
    _msgView.layer.cornerRadius = 5;
    [self addSubview:_msgView];
    _contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,30,_window_width,20)];
    _contentLabel.textColor = RGB_COLOR(@"#fed230", 1);//[UIColor whiteColor];
    _contentLabel.font = [UIFont systemFontOfSize:11];
    [_contentLabel setTextAlignment:NSTextAlignmentCenter];
    
    _contentLabel.text = [dic valueForKey:@"text"];
//    _contentLabel.userInteractionEnabled = NO;
    
    [_msgView addSubview:_contentLabel];
    _msgView.userInteractionEnabled = YES;
    _curUrl = [dic valueForKey:@"url"];
    UITapGestureRecognizer *tapGesturRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapADAction:)];
    [_msgView addGestureRecognizer:tapGesturRecognizer];


    // 渐隐+上滑出现
    WeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.userMoveImageV.x = 80;
        strongSelf.contentLabel.y = 5;
        strongSelf.contentLabel.alpha = 1;
    }completion:^(BOOL finished) {
    }];

    // 停顿
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        
        [UIView animateWithDuration:0.5 animations:^{
            if (strongSelf == nil) {
                return;
            }
            strongSelf.userMoveImageV.x = 10;
            strongSelf.contentLabel.y = 5;
        }] ;
    });
    
    // 渐隐消失
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        [UIView animateWithDuration:0.2 animations:^{
            if (strongSelf == nil) {
                return;
            }
            strongSelf.userMoveImageV.x = -_window_width;
            strongSelf.contentLabel.y = -30;
            strongSelf.contentLabel.alpha = 0;
        } completion:^(BOOL finished) {
            if (strongSelf == nil) {
                return;
            }
            [strongSelf.userMoveImageV removeFromSuperview];
            strongSelf.userMoveImageV = nil;
            
            [strongSelf.contentLabel removeFromSuperview];
            strongSelf.contentLabel = nil;
            
            [strongSelf.msgView removeFromSuperview];
            strongSelf.msgView = nil;
            strongSelf.isADMove = 0;
            if (strongSelf.ad.count >0) {
                [strongSelf addAD:nil];
            }else{
                // TODO 停顿 然后继续训轮
                NSString * adText = [Config getADText];
                NSString * adUrl = [Config getADUrl];
                [strongSelf addAD:@{@"text":adText, @"url":adUrl}];
            }
        }];

    });
}
-(void)tapADAction:(id)tap

{
    NSLog(@"点击了AD");
    if(_curUrl.length > 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_curUrl] options:@{} completionHandler:^(BOOL success) {
            
        }];
    }
}


@end
