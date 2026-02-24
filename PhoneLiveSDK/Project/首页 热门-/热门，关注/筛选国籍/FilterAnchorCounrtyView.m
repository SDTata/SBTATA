//
//  FilterAnchorCounrtyView.m
//  phonelive2
//
//  Created by 400 on 2021/7/28.
//  Copyright © 2021 toby. All rights reserved.
//
  
#import "FilterAnchorCounrtyView.h"
#import "FilterAchorCountryCell.h"
#import "UIImageView+WebCache.h"
@interface FilterAnchorCounrtyView()
{
    NSMutableArray <CountryFilterModel *>*_models;
}
@end
@implementation FilterAnchorCounrtyView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
   
    [self.filterButton setTitle:YZMsg(@"Filter_title") forState:UIControlStateNormal];
    [self.filterButton addTarget:self action:@selector(filterVC) forControlEvents:UIControlEventTouchUpInside];
    self.filterButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.filterButton.titleLabel.minimumScaleFactor = 0.5;
    
    self.width = SCREEN_WIDTH;
    UINib *nib=[UINib nibWithNibName:@"FilterAchorCountryCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.collectionView registerNib: nib forCellWithReuseIdentifier:@"FilterAchorCountryCell"];
    float paddingLeft = (SCREEN_WIDTH - 53 -10 - 77.5 -7 - (40*4))/5;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, paddingLeft, 0, 0);
}
-(void)setDatas:(NSArray<CountryFilterModel *> *)datas
{
    _datas = datas;
    _models = _datas.mutableCopy;
    [self.collectionView reloadData];
}
-(void)setSelectedModel:(CountryFilterModel *)selectedModel
{
    if (_selectedModel) {
        //添加之前的
        [_models addObject:_selectedModel];
    }
    //删除当前的
    for (CountryFilterModel *model in _models) {
        if ([model.name isEqualToString:selectedModel.name] && [model.countryCode isEqualToString:selectedModel.countryCode]) {
            _selectedModel = model;
            break;
        }
    }
    [_models removeObject:_selectedModel];
    _datas = _models.copy;
    [self selectedView:_selectedModel];
    [self.collectionView reloadData];
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
   
    return self.datas.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CountryFilterModel *model = self.datas[indexPath.row];
    if (self.delegate) {
        [self.delegate countryModelSelected:model];
    }
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FilterAchorCountryCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"FilterAchorCountryCell" forIndexPath:indexPath];
    CountryFilterModel *model = self.datas[indexPath.row];
    [cell.countryImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[ImageBundle imagewithBundleName:@""]];
    cell.countryNameLabel.text = model.name;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(40, 57);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return (SCREEN_WIDTH - 53 -10 - 77.5 -7 - (40*4))/5;
}


-(void)filterVC{
    FilterCountryVC *filterVC = [[FilterCountryVC alloc]initWithNibName:@"FilterCountryVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    filterVC.delegate = self;
    filterVC.datas = self.datas;
    [[MXBADelegate sharedAppDelegate] pushViewController:filterVC animated:YES];
}

-(void)countryModelSelected:(CountryFilterModel *)model
{
    if (self.delegate) {
        [self.delegate countryModelSelected:model];
    }
    [self selectedView:model];
    
}
-(void)selectedView:(CountryFilterModel*)model{
    self.selectedLabel.text = model.name;
//    self.selectedImgV.image=[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"C_%@",model.countryCode]];
    [self.selectedImgV sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[ImageBundle imagewithBundleName:@""]];
}
@end
