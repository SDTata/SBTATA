//
//  FilterCountryVC.m
//  phonelive2
//
//  Created by 400 on 2021/8/6.
//  Copyright © 2021 toby. All rights reserved.
//

#import "FilterCountryVC.h"
#import "FilterAchorCountryCell.h"
#import "UIImageView+WebCache.h"
#import <UMCommon/UMCommon.h>

@interface FilterCountryVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end

@implementation FilterCountryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self navigation];
    self.titleLabel.text = YZMsg(@"activity_login_country_region1");
    UINib *nib=[UINib nibWithNibName:@"FilterAchorCountryCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.collectionView registerNib: nib forCellWithReuseIdentifier:@"FilterAchorCountryCell"];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);

    // Do any additional setup after loading the view from its nib.
}


-(void)navigation{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor = [UIColor whiteColor];
   
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBtn.frame = CGRectMake(8,24 + statusbarHeight,40,40);
    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 24 + statusbarHeight,_window_width-160,40)];
    titleLabel.userInteractionEnabled = YES;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.text = YZMsg(@"Filter_title");
    [navtion addSubview:titleLabel];
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];
    [self.view addSubview:navtion];
}

-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
   
    return self.datas.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
    if (self.delegate) {
        CountryFilterModel *model = self.datas[indexPath.row];
        [self.delegate countryModelSelected:model];
        NSDictionary *dict = @{ @"eventType": @(0),
                                @"country_code": model.countryCode};
        [MobClick event:@"charge_country_selected_click" attributes:dict];
    }
    [self doReturn];
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

@end
