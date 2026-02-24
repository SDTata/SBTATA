//
//  HomeSearchRecordCell.h
//  phonelive2
//
//  Created by user on 2024/7/4.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTagsView.h"

@interface HomeSearchRecordCell : VKBaseTableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *titleRightIcon;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) NSArray *datas;
@property(nonatomic,assign) id<TagViewDelegate> delelgate;
@end
