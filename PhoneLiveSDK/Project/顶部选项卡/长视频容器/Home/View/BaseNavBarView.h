//
//  BaseNavBarView.h
//  phonelive2
//
//  Created by vick on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseNavBarView : UIView

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIStackView *actionStackView;

@end
