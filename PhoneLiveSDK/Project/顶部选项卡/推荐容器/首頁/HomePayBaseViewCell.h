//
//  HomePayBaseViewCell.h
//  phonelive2
//
//  Created by s5346 on 2024/7/20.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomePayBaseViewCell : VKBaseCollectionViewCell

@property (nonatomic, strong) UIStackView *tagStackView;
@property (nonatomic, strong) UIButton *vipTagButton;
@property (nonatomic, strong) UIButton *payTagButton;

- (void)updateDataForVip:(NSInteger)is_vip pay:(NSInteger)coin_cost ticket:(NSInteger)ticket_cost canPlay:(NSInteger)can_play;

@end

@interface HomePayBaseViewTableViewCell : UITableViewCell

@property (nonatomic, strong) UIStackView *tagStackView;
@property (nonatomic, strong) UIButton *vipTagButton;
@property (nonatomic, strong) UIButton *payTagButton;

- (void)updateDataForVip:(NSInteger)is_vip pay:(NSInteger)coin_cost ticket:(NSInteger)ticket_cost canPlay:(NSInteger)can_play;

@end

NS_ASSUME_NONNULL_END
