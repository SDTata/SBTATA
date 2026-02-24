//
//  VKActionGridCell.h
//
//  Created by vick on 2023/5/10.
//

#import <UIKit/UIKit.h>
#import "VKBaseCollectionViewCell.h"
#import "VKActionModel.h"

@interface VKActionGridCell : VKBaseCollectionViewCell

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@end
