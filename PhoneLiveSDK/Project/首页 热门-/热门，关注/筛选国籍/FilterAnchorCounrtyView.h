//
//  FilterAnchorCounrtyView.h
//  phonelive2
//
//  Created by 400 on 2021/7/28.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryFilterModel.h"
#import "FilterCountryVC.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FilterCountryViewDelegate <NSObject>

- (void)countryModelSelected:(CountryFilterModel*)model;

@end

@interface FilterAnchorCounrtyView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,FilterCountryDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *selectedImgV;
@property (weak, nonatomic) IBOutlet UILabel *selectedLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property(nonatomic,assign)id<FilterCountryViewDelegate> delegate;
@property(nonatomic,strong)NSArray<CountryFilterModel*> *datas;
@property(nonatomic,strong)CountryFilterModel *selectedModel;

@end

NS_ASSUME_NONNULL_END
