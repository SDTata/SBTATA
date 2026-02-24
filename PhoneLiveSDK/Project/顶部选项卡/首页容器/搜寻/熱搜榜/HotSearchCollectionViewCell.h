//
//  HotSearchCollectionViewCell.h
//  phonelive2
//
//  Created by user on 2024/7/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotSearchCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *rankingLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *popularityLabel;
@property (nonatomic, strong) UIImageView *hotIcon;
- (void)setupData:(NSDictionary *)data;
@end
