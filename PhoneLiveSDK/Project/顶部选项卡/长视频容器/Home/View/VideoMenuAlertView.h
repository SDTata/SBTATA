//
//  VideoMenuAlertView.h
//  phonelive2
//
//  Created by vick on 2024/7/4.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieHomeModel.h"

@interface VideoMenuAlertCell : VKBaseCollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@end


@interface VideoMenuAlertView : UIView

@property (nonatomic, strong) VKBaseCollectionView *tableView;

@property (nonatomic, strong) NSArray <MovieCateModel *> *dataArray;

@property (nonatomic, copy) void (^clickIndexBlock)(NSInteger index);

@end
