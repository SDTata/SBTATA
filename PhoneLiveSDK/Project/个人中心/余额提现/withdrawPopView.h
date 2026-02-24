//
//  withdrawPopView.h
//  phonelive2
//
//  Created by lucas on 2021/4/20.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface withdrawPopView : UIView
@property (nonatomic,strong) UILabel *titleLbl;

@property (nonatomic,strong) UILabel *billingLab;

@property (nonatomic,strong) UIButton *cancelBtn;

@property (nonatomic,strong) UIButton *submitBtn;


@property (nonatomic,copy) void(^cancelBtnClickBlock)(UIButton *sender);
@property (nonatomic,copy) void(^submitBtnClickBlock)(UIButton *sender);

@end

NS_ASSUME_NONNULL_END
