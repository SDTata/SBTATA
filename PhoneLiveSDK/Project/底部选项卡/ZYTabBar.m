//
//  ZYTabBar.m
//  自定义tabbarDemo
//
//  Created by tarena on 16/7/1.
//  Copyright © 2016年 张永强. All rights reserved.
//

#import "ZYTabBar.h"
#import "UIView+LBExtension.h"
#import <objc/runtime.h>

#define ZYMagin 30
@interface ZYTabBar ()<MXtabbarDelegate>
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end
@implementation ZYTabBar
//对按钮的一些基本设置
- (void)setUpPathButton:(MXtabbar *)pathButton {
    pathButton.delegate = self;
//    pathButton.bloomRadius = self.bloomRadius;
//    pathButton.allowCenterButtonRotation = self.allowCenterButtonRotation;
//    pathButton.bottomViewColor = [UIColor clearColor];
//    pathButton.bloomDirection = kMXtabbarBloomDirectionTop;
//    pathButton.basicDuration = self.basicDuration;
//    pathButton.bloomAngel = self.bloomAngel;
//    pathButton.allowSounds = NO;
}
- (void)drawRect:(CGRect)rect {
    if (!self.plusBtn && !self.expandView && self.hasMiddle) {
#ifdef LIVE
        self.plusBtn = [[MXtabbar alloc]initWithCenterImage:[ImageBundle imagewithBundleName:@"main_bottom_openlive"]highlightedImage:[ImageBundle imagewithBundleName:@"main_bottom_openlive"]];
#else
        self.plusBtn = [[MXtabbar alloc]initWithCenterImage:[ImageBundle imagewithBundleName:@"main_bottom_baoxiang"] highlightedImage:[ImageBundle imagewithBundleName:@"main_bottom_baoxiang"]];
#endif
        self.plusBtn.delegate = self;
        self.plusBtn.hidden = NO;
        [self setUpPathButton:self.plusBtn];
        //必须加到父视图上
        //[self.superview addSubview:self.plusBtn];
        
        //self.plusBtn.top = kWindow.height  - self.plusBtn.height-12-ShowDiff/2+(iPhoneX?0:-4);
        
        self.expandView = [[TouchSuperView alloc] initWithFrame:CGRectZero];
        //self.expandView.backgroundColor = [UIColor yellowColor];
        [self.superview addSubview:self.expandView];
        
        [self.expandView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_safeAreaLayoutGuideBottom).inset(iPhoneX ? 0 : 13);
            make.width.mas_equalTo(self).multipliedBy(0.5);
            make.height.mas_equalTo(200);
        }];
  
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(self.plusBtn.centerX, self.plusBtn.bottom, 70, 20)];
        
        
        self.expandBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString: self.configData[@"icon_bg"]] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL)
        {} completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL)
        {
            self.expandBackgroundView.image = image;
        }];
#ifdef LIVE
        label.text = YZMsg(@"ZYTabBar_open_live");
#else
        label.text = self.configData[@"title"];
#endif
        [label setTextAlignment:NSTextAlignmentCenter];
        label.font = [UIFont systemFontOfSize:13];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        //[label sizeToFit];
        label.textColor = [UIColor grayColor];
        label.centerX = _plusBtn.centerX;
        label.centerY = CGRectGetMaxY(_plusBtn.frame) - 11;// + ZYMagin;
        self.kbLabel = label;
        //[self.superview addSubview:label];

        [self.expandView addSubview:self.plusBtn];
        [self.expandView addSubview:label];
        [self.expandView addSubview:self.expandBackgroundView];
        
        [self.plusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.expandView);
            make.bottom.mas_equalTo(self.expandView.mas_bottom).offset(3);
            make.size.mas_equalTo(self.plusBtn.size);
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.expandView);
            make.bottom.mas_equalTo(self.expandView.mas_bottom);
            make.width.mas_equalTo(70);
            make.height.mas_equalTo(20);
        }];
        
        [self.expandBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.expandView);
            make.bottom.mas_equalTo(self.expandView.mas_bottom).inset(33);
            make.width.mas_equalTo(self.expandView.mas_width);
            make.top.mas_equalTo(self.expandView.mas_top);
        }];
        
        
        self.activityButtonArray = [NSMutableArray array];
        NSArray *buttons = self.configData[@"buttons"];
        if (buttons.count > 1) {
            [buttons enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
                LiveActivityButton *btn = [[LiveActivityButton alloc] initWithFrame:CGRectMake(0, 0, AD(60), AD(60))];
                [btn setButtonImageWithUrl: dic[@"icon_normal"] forState:UIControlStateNormal];
                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:dic[@"icon_selected"]] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL)
                {} completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL)
                {
                    [btn setButtonImage:image forState:UIControlStateSelected fromNetwork:YES];
                }];
                [btn setTitle: dic[@"title"] forState:UIControlStateNormal];
                [btn setTitleColor: RGB_COLOR(dic[@"text_color_normal"], 1) forState: UIControlStateNormal];
                [btn setTitleColor: RGB_COLOR(dic[@"text_color_selected"], 1) forState: UIControlStateSelected];
                [btn setHidden: YES];
                btn.alpha = 0;
                [self.expandView addSubview: btn];
                [self.activityButtonArray addObject: btn];
            }];
            [self buttonMakeConstraints];
            [self addTarget];
        }
    }
}

//重新绘制按钮
- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.backgroundImageView) {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        [self insertSubview:self.backgroundImageView atIndex:0];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, -3);
        self.layer.shadowOpacity = 0.1;
        self.layer.shadowRadius = 4.0;
    }
    self.backgroundImageView.image = self.bgImg;

    if (self.hasMiddle) {
        //系统自带的按钮类型是UITabBarButton,找出这些类型的按钮,然后重新排布位置 ,空出中间的位置
        Class class = NSClassFromString(@"UITabBarButton");
        int btnIndex = 0;
        for (UIView *btn in self.subviews) {//遍历tabbar的子控件
            if ([btn isKindOfClass:class]) {//如果是系统的UITabBarButton，那么就调整子控件位置，空出中间位置
               //每一个按钮的宽度 == tabbar的五分之一
                btn.width = self.width/(self.hasMiddle ? 5 : self.subviews.count);
                btn.x = btn.width * btnIndex;
                btn.y = 5+ShowDiff/2 +(iPhoneX?0:-4);
                btnIndex ++;
                //如果是索引是1(从0开始的)，直接让索引++，目的就是让消息按钮的位置向右移动，空出来发布按钮的位置
                if (btnIndex == 2 && self.hasMiddle) {
                    btnIndex++;
                }
                for (UIView *subview in btn.subviews) {
                    if ([subview isKindOfClass:NSClassFromString(@"_UIBadgeView")]) {
                        CGRect badgeFrame = subview.frame;
                        // 设置新的 x 和 y 坐标
                        badgeFrame.origin.x = badgeFrame.origin.x;
                        badgeFrame.origin.y = badgeFrame.origin.y+(iPhoneX?10:-9);
                        subview.frame = badgeFrame;
                    }
                }
            }
        }
    }
}
- (void)pathButton:(MXtabbar *)MXtabbar clickItemButtonAtIndex:(NSUInteger)itemButtonIndex {
    if (self.activityButtonArray.count > 1) {
        self.selected ? [self closeAnimation] : [self openAnimation];
    } else {
        if ([self.delegateT respondsToSelector:@selector(pathButton:clickItemButtonAtIndex:)]) {
            [self.delegateT pathButton:self clickItemButtonAtIndex:itemButtonIndex];
        }
    }
}

- (void)setButtonsAlpha:(CGFloat)alpha {
    [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
        button.alpha = alpha;
    }];
}

- (void)addTarget {
    [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
        WeakSelf
        [button setTargetClick:^(NSString *tag,LiveActivityButton *sende) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            NSInteger count = strongSelf.activityButtonArray.count;
            if (count>0) {
                [strongSelf.activityButtonArray[0] selected:index == 0];
            }
            if (count>1) {
                [strongSelf.activityButtonArray[1] selected:index == 1];
            }
            if (count>2) {
                [strongSelf.activityButtonArray[2] selected:index == 2];
            }
            if (count>3) {
                [strongSelf.activityButtonArray[3] selected:index == 3];
            }
            
            [strongSelf.plusBtn setIcon: [sende getSelectImage]];
            strongSelf.selected = NO;
            [strongSelf closeAnimation];
            [strongSelf labelAnimation: [sende getTitle]];
            [(ZYTabBarController *)strongSelf.delegateT setSelectedIndex: 4 + index];
        }];
    }];
}

- (void)buttonMakeConstraints {
    if (self.activityButtonArray.count == 2) {
        [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
            if (index == 0) {
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(0.5);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.75);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 1) {
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1.5);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.75);
                    make.size.mas_equalTo(button.size);
                }];
            }
        }];
    } else if (self.activityButtonArray.count == 3) {
        [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
            if (index == 0) {
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(0.33);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.85);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 1) {
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.5);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 2) {
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1.66);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.85);
                    make.size.mas_equalTo(button.size);
                }];
            }
        }];
    } else if (self.activityButtonArray.count == 4) {
        [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
            if (index == 0) {
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(0.25);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.85);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 1) {
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(0.75);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.5);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 2) {
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1.25);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.5);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 3) {
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1.75);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.85);
                    make.size.mas_equalTo(button.size);
                }];
            }
        }];
    }
}

- (void)closeAnimation {
    if (self.activityButtonArray.count == 2) {
        [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
            if (index == 0) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(0.5);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.75);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 1) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1.5);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.75);
                    make.size.mas_equalTo(button.size);
                }];
            }
        }];
    } else if (self.activityButtonArray.count == 3) {
        [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
            if (index == 0) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(0.33);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.85);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 1) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.5);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 2) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1.66);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.85);
                    make.size.mas_equalTo(button.size);
                }];
            }
        }];
    } else if (self.activityButtonArray.count == 4) {
        [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
            if (index == 0) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(0.25);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.85);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 1) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(0.75);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.5);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 2) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1.25);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.5);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 3) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1.75);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.85);
                    make.size.mas_equalTo(button.size);
                }];
            }
        }];
    }
    [self setButtonsAlpha: 1];
    [UIView animateWithDuration:0.3 animations:^{
        [self.expandView layoutIfNeeded];
        [self setButtonsAlpha: 0];
    } completion:^(BOOL finished) {
        [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
            [button setHidden: YES];
        }];
    }];
    self.selected = NO;
}

- (void)openAnimation {
    if (self.activityButtonArray.count == 2) {
        [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
            if (index == 0) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(0.5);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.15);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 1) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1.5);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.15);
                    make.size.mas_equalTo(button.size);
                }];
            }
        }];
    } else if (self.activityButtonArray.count == 3) {
        [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
            if (index == 0) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(0.33);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.25);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 1) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(0.75);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 2) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1.66);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.25);
                    make.size.mas_equalTo(button.size);
                }];
            }
        }];
    } else if (self.activityButtonArray.count == 4) {
        [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
            if (index == 0) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(0.25);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.25);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 1) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(0.75);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(0.85);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 2) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1.25);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(0.85);
                    make.size.mas_equalTo(button.size);
                }];
            } else if (index == 3) {
                [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.expandView.mas_centerX).multipliedBy(1.75);
                    make.centerY.mas_equalTo(self.expandView.mas_centerY).multipliedBy(1.25);
                    make.size.mas_equalTo(button.size);
                }];
            }
        }];
    }
    [self setButtonsAlpha: 0];
    [UIView animateWithDuration:0.3 animations:^{
        [self.expandView layoutIfNeeded];
        [self.activityButtonArray enumerateObjectsUsingBlock:^(LiveActivityButton *button, NSUInteger index, BOOL * _Nonnull stop) {
            [button setHidden: NO];
        }];
        [self setButtonsAlpha: 1];
    }];
    self.selected = YES;
}

- (void)labelAnimation:(NSString *)text {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    self.kbLabel.text = text;
    [self.kbLabel.layer addAnimation:transition forKey:@"labelFade"];
}

@end















