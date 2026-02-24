//
//  HomeSearchYouLikeCell.h
//  c700LIVE
//
//  Created by user on 2024/7/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTagsView.h"

typedef void (^HomeSearchYouLikeCellDidSelectBlock)(void);

@interface HomeSearchYouLikeCell : VKBaseTableViewCell
@property (nonatomic, copy) HomeSearchYouLikeCellDidSelectBlock didSelectCellBlock;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *titleRightIcon;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) NSArray *datas;
@property(nonatomic,assign) id<TagViewDelegate> delelgate;
@end
