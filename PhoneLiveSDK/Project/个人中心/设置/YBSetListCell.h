//
//  YBSetListCell.h
//  phonelive2
//
//  Created by lucas on 2021/4/8.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBSetListCell : UITableViewCell
//名字
@property(nonatomic,strong) UILabel * nameLab;
//版本
@property(nonatomic,strong) UILabel *versionLab;
//更新
@property(nonatomic,strong) UIButton * updateBtn;
//开关
@property(nonatomic,strong) UISwitch * switchButton;
//详情
@property(nonatomic,strong) UILabel * detailsLab;
//背景
@property(nonatomic,strong) UIView * line;

@end

NS_ASSUME_NONNULL_END
