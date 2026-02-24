//
//  VKActionListCell.h
//
//  Created by vick on 2023/5/10.
//

#import <UIKit/UIKit.h>
#import "VKBaseTableViewCell.h"
#import "VKActionModel.h"

@interface VKActionListCell : VKBaseTableViewCell

@property (nonatomic, strong) UIView *backMaskView;
@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UIImageView *arrowImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *valueLabel;

@end
