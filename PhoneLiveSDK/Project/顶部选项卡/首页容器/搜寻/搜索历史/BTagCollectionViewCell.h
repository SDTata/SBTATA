//
//  BTagCollectionViewCell.h
//  phonelive2
//
//  Created by user on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionViewLeftAlignedLayout.h"

@interface BTagCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UIImageView *moreIcon;
- (void)setupData:(NSString *)text;
+ (CGSize)getItemSizeWothText:(NSString *)text;
@end
