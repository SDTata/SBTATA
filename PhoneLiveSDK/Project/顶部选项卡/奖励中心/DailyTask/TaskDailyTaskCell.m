//
//  TaskDailyTaskCell.m
//  phonelive2
//
//  Created by vick on 2024/8/20.
//  Copyright © 2024 toby. All rights reserved.
//

#import "TaskDailyTaskCell.h"

@implementation TaskDailyTaskCell

- (void)updateView {
    [super updateView];
    self.iconImgView.hidden = YES;
    
    UIButton *imageButton = [UIView vk_button:nil image:nil font:vkFontBold(12) color:UIColor.whiteColor];
    imageButton.userInteractionEnabled = NO;
    [imageButton vk_border:nil cornerRadius:12];
    [self.backImgView addSubview:imageButton];
    self.imageButton = imageButton;
    [imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(52);
        make.centerY.mas_equalTo(-2);
    }];
    
    [self.stackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(85);
    }];
}

- (void)updateData {
    [super updateData];
    
    [self.imageButton setTitle:[NSString stringWithFormat:@"%@%ld", YZMsg(@"task_reward_level"), self.indexPath.row+1] forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageButton.horizontalColors = @[vkColorRGBA(61, 9, 255, 0.3), vkColorRGBA(103, 111, 255, 0.5)];
}

@end
