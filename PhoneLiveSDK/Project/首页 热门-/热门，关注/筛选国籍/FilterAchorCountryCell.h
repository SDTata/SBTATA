//
//  FilterAchorCountryCell.h
//  phonelive2
//
//  Created by 400 on 2021/8/6.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryFilterModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FilterAchorCountryCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *countryImgView;
@property (weak, nonatomic) IBOutlet UILabel *countryNameLabel;

@end

NS_ASSUME_NONNULL_END
