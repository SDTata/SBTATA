//
//  userLoginAnimation.h
//  yunbaolive
//
//  Created by 王敏欣 on 2017/2/21.
//  Copyright © 2017年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol adadimation <NSObject>

-(void)animationad;

@end

@interface centerADAnimation : UIView
@property(nonatomic,strong)UIImageView *vipimage;
@property(nonatomic,weak)id<adadimation>delegate;
@property(nonatomic,strong)UIImageView *userMoveImageV;//进入动画背景
@property(nonatomic,strong)UIView *msgView;//显示用户信息
@property(nonatomic,strong)UILabel *contentLabel;

@property(nonatomic,assign)int  isADMove;// 限制用户进入动画
@property(nonatomic,strong)NSMutableArray *ad;//用户进入数组，存放动画
@property(nonatomic,strong)NSString *curUrl;//当前url

-(void)addAD:(NSDictionary *)dic;

@end
