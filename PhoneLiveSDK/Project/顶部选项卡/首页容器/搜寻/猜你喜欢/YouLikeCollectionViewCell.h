//
//  YouLikeCollectionViewCell.h
//  phonelive2
//
//  Created by user on 2024/7/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YouLikeCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *titleLabel;
- (void)setupData:(NSString *)text;
@end
