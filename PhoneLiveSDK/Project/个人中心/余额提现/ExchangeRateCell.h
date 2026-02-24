//
//  ExchangeRateCell.h
//  phonelive2
//
//  Created by lucas on 2021/9/24.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExchangeRateCell : UITableViewCell
//国家
@property(nonatomic,strong) UILabel * nameLab;
//币种
@property(nonatomic,strong) UILabel *currencyLab;
//
@property(nonatomic,strong) UIImageView *iconImgV;
//分割线
@property(nonatomic,strong) UIView * line;
//
@property(nonatomic,strong) UIButton * selectedBtn;

@end

NS_ASSUME_NONNULL_END
