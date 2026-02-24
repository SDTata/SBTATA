//
//  LotteryChipView.h
//  phonelive2
//
//  Created by vick on 2023/11/24.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LotteryChipCell : VKBaseCollectionViewCell

@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *titleLabel;

@end


@interface LotteryChipView : UIView

@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UIButton *continueBtn;

@property (nonatomic, copy) VKDataBlock selectBlock;
@property (nonatomic, copy) VKBlock continueBlock;

- (void)refreshBalance;

@end
