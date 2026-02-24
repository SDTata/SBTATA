//
//  ChipChoiseCell.h
//  phonelive2
//
//  Created by 400 on 2021/9/30.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChipChoiseCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *chipImgView;
@property (weak, nonatomic) IBOutlet UILabel *chipNumLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property(nonatomic,assign)NSInteger chipNum;
@end

NS_ASSUME_NONNULL_END
