//
//  LiveClosePopView.h
//  yunbaolive
//
//  Created by lucas on 2021/9/7.
//  Copyright © 2021 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveClosePopView : UIView
@property (nonatomic,copy) void(^startBtnClickBlock)(void);
@property (nonatomic,copy) void(^lookBtnClickBlock)(void);
@property (nonatomic,strong) UIImageView *titleImgV;
@property (nonatomic,strong) UILabel *titleLbl;
@property (nonatomic,strong) UILabel *resultLbl;
@property (nonatomic,strong) UIButton *lookBtn;
@property (nonatomic,strong) UIButton *startBtn;
@property (nonatomic,strong) UIButton *closeBtn;
@property (nonatomic,strong) UIImageView *bjView;

// 点击关闭按钮回调
@property (nonatomic, strong) void(^callBlock)(void);

@end

NS_ASSUME_NONNULL_END
