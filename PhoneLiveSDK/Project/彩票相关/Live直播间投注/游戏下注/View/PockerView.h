//
//  PockerView.h
//  翻牌
//
//  Created by 斌 on 2017/4/20.
//  Copyright © 2017年 斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PockerView : UIView

@property(nonatomic,strong)UIImageView *imgview1;
@property(nonatomic,strong)UIImageView *imgview2;

- (void)setPokerName:(NSString *)pokerName;

/// 直接显示翻牌
- (void)showOpenPoker;

/// 显示翻牌动画
- (void)rotateWithPokerView;

/// 显示收牌动画
- (void)showClosePoker:(CGPoint)point;

@end
