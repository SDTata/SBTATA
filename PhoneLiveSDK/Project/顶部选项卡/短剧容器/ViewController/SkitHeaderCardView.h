//
//  SkitHeaderCardView.h
//  phonelive2
//
//  Created by vick on 2024/9/30.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SkitHeaderCardView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) VKBaseCollectionView *tableView;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, copy) VKBlock clickMoreBlock;

@end
