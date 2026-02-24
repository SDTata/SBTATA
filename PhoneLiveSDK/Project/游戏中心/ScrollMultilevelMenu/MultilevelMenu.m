//
//  MultilevelMenu.m
//  MultilevelMenu
//
//  Created by gitBurning on 15/3/13.
//  Copyright (c) 2015年 BR. All rights reserved.
//

#import "MultilevelMenu.h"
#import "MultilevelTableViewCell.h"
#import "MultilevelCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "GameTypeCell.h"
#import "LMHWaterFallLayout.h"
#import "MultilevelCollectionViewBigCell.h"
#import "CacheImageKey.h"
#define kCellRightLineTag 100
#define kImageDefaultName @"tempShop2"
#define kMultilevelCollectionViewCell @"MultilevelCollectionViewCell"
#define kMultilevelCollectionViewBigCell @"MultilevelCollectionViewBigCell"
#define kMultilevelCollectionHeader   @"CollectionHeader"//CollectionHeader
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface MultilevelMenu()<LMHWaterFallLayoutDeleaget>

@property(assign,nonatomic) BOOL isLeftTableDidSelected;
@property(assign,nonatomic) BOOL isReturnLastOffset;
@property(assign,nonatomic) BOOL tmptest;


@property(assign,nonatomic) int loadImageNum;


@property(strong,nonatomic) NSMutableDictionary *heightCellDic;

@property(strong,nonatomic)NSMutableDictionary *cacheSelected;

@end
@implementation MultilevelMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame WithData:(NSArray *)data withSelectIndex:(void (^)(NSInteger, NSInteger, id))selectIndex
{
    self=[super initWithFrame:frame];
    if (self) {
        if (data.count==0) {
            return nil;
        }
        _tmptest = true;
        
        _block=selectIndex;
        self.leftSelectColor=[UIColor blackColor];
        self.leftSelectBgColor=[UIColor clearColor];
        self.leftBgColor=[UIColor clearColor];
        self.leftSeparatorColor=UIColorFromRGB(0xE5E5E5);
        self.leftUnSelectBgColor=UIColorFromRGB(0xF3F4F6);
        self.leftUnSelectColor=[UIColor blackColor];
        self.heightCellDic = [NSMutableDictionary dictionary];
        _selectIndex=0;
        _allData=data;
        _cacheSelected = [NSMutableDictionary dictionary];
        
        /**
         左边的视图
        */
        self.leftTablew=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kLeftWidth, frame.size.height)];
        [self addSubview:self.leftTablew];
        [self.leftTablew mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.mas_equalTo(self);
            make.width.mas_equalTo(kLeftWidth);
        }];
        self.leftTablew.dataSource=self;
        self.leftTablew.delegate=self;
        self.leftTablew.showsVerticalScrollIndicator = NO;
        self.leftTablew.showsHorizontalScrollIndicator = NO;
        self.leftTablew.tableFooterView=[[UIView alloc] init];
        
        self.leftTablew.backgroundColor=self.leftBgColor;
        if ([self.leftTablew respondsToSelector:@selector(setLayoutMargins:)]) {
            self.leftTablew.layoutMargins=UIEdgeInsetsZero;
        }
        if ([self.leftTablew respondsToSelector:@selector(setSeparatorInset:)]) {
            self.leftTablew.separatorInset=UIEdgeInsetsZero;
        }
        self.leftTablew.separatorColor=self.leftSeparatorColor;
        [self.leftTablew registerClass:[GameTypeCell class] forCellReuseIdentifier:NSStringFromClass([GameTypeCell class])];
        self.leftTablew.separatorStyle = UITableViewCellSeparatorStyleNone;
        /**
         右边的视图
         */
        
        float leftMargin =0;
        
        
        self.rightTablew=[[UITableView alloc] initWithFrame:CGRectMake(kLeftWidth+leftMargin,0,kScreenWidth-kLeftWidth-leftMargin*2,frame.size.height)];
        [self addSubview:self.rightTablew];
        [self.rightTablew mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.leftTablew.mas_trailing);
            make.trailing.top.bottom.mas_equalTo(self);
        }];
        self.rightTablew.dataSource=self;
        self.rightTablew.delegate=self;
        self.rightTablew.estimatedRowHeight = 300.0;
        self.rightTablew.rowHeight = UITableViewAutomaticDimension;
        self.rightTablew.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0,0,kScreenWidth-kLeftWidth-leftMargin*2,84)];
        self.rightTablew.backgroundColor = [UIColor clearColor];
        self.rightTablew.showsVerticalScrollIndicator = NO;
        self.rightTablew.showsHorizontalScrollIndicator = NO;
        self.rightTablew.separatorColor = [UIColor clearColor];
        self.rightTablew.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.rightTablew.bounces = NO;
        self.rightCollections = [[NSMutableArray alloc] init];
        for (int i = 0; i < _allData.count; i++) {
            LMHWaterFallLayout * layout = [[LMHWaterFallLayout alloc] init];
            layout.delegate = self;
            UICollectionView *rightCollection=[[UICollectionView alloc] initWithFrame:CGRectMake(kLeftWidth+leftMargin,0,kScreenWidth-kLeftWidth-leftMargin*2,frame.size.height) collectionViewLayout:layout];
            rightCollection.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
            rightCollection.delegate=self;
            rightCollection.dataSource=self;
            [rightCollection setBounces:NO];
            [rightCollection setScrollEnabled:NO];
           
            
            UINib *nib=[UINib nibWithNibName:kMultilevelCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
            UINib *nibBig=[UINib nibWithNibName:kMultilevelCollectionViewBigCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
            [rightCollection registerNib: nib forCellWithReuseIdentifier:kMultilevelCollectionViewCell];
            [rightCollection registerNib: nibBig forCellWithReuseIdentifier:kMultilevelCollectionViewBigCell];
            
//            UINib *header=[UINib nibWithNibName:kMultilevelCollectionHeader bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
//            [rightCollection registerNib:header forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMultilevelCollectionHeader];
            
            //[self addSubview:self.rightCollection];
            rightCollection.backgroundColor=self.leftSelectBgColor;
            [self.rightCollections addObject:rightCollection];
        }
        
      
        self.isReturnLastOffset=YES;
        self.backgroundColor=self.leftSelectBgColor;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setContentTableCanScroll) name:@"SetContentTableCanScroll" object:nil];
      
    }
    return self;
}
-(void)setContentTableCanScroll {
    self.isRightTableCanScroll = YES;
}


- (void)reloadFrame:(CGRect)frame{
    self.frame = frame;
    self.leftTablew.frame = CGRectMake(0, 0, kLeftWidth, frame.size.height);
    float leftMargin =0;
    self.rightTablew.frame = CGRectMake(kLeftWidth+leftMargin,0,kScreenWidth-kLeftWidth-leftMargin*2,frame.size.height);
}
-(void)setNeedToScorllerIndex:(NSInteger)needToScorllerIndex{
    
    /**
     *  滑动到 指定行数
     */
    
    // 默认选中行
    NSIndexPath *firstPath = [NSIndexPath indexPathForRow:needToScorllerIndex inSection:0];
    [self.leftTablew selectRowAtIndexPath:firstPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    if ([self.leftTablew.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [self.leftTablew.delegate tableView:self.leftTablew didDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectIndex inSection:0]];
    }
    if ([self.leftTablew.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.leftTablew.delegate tableView:self.leftTablew didSelectRowAtIndexPath:firstPath];
    }
    
//    [self.leftTablew selectRowAtIndexPath:[NSIndexPath indexPathForRow:needToScorllerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    _selectIndex=needToScorllerIndex;

    [self reloadData];
    _needToScorllerIndex=needToScorllerIndex;
}
-(void)setLeftBgColor:(UIColor *)leftBgColor{
    _leftBgColor=leftBgColor;
    self.leftTablew.backgroundColor=leftBgColor;
   
}
-(void)setLeftSelectBgColor:(UIColor *)leftSelectBgColor{
    
    _leftSelectBgColor=leftSelectBgColor;
//    self.rightCollection.backgroundColor=leftSelectBgColor;
    
    self.backgroundColor=leftSelectBgColor;
}
-(void)setLeftSeparatorColor:(UIColor *)leftSeparatorColor{
    _leftSeparatorColor=leftSeparatorColor;
    self.leftTablew.separatorColor=leftSeparatorColor;
}
-(void)reloadData{
    
    [self.leftTablew reloadData];
    for (UICollectionView *subCO in self.rightCollections) {
        [subCO reloadData];
    }
    [self.rightTablew reloadData];


    
}
-(void)setLeftTablewCellSelected:(BOOL)selected withCell:(MultilevelTableViewCell*)cell
{
//    UILabel * line=(UILabel*)[cell viewWithTag:kCellRightLineTag];
//    if (selected) {
//
//        line.backgroundColor=cell.backgroundColor;
//        cell.titile.textColor=self.leftSelectColor;
//        cell.backgroundColor=self.leftSelectBgColor;
//    }
//    else{
//        cell.titile.textColor=self.leftUnSelectColor;
//        cell.backgroundColor=self.leftUnSelectBgColor;
//        line.backgroundColor=_leftTablew.separatorColor;
//    }
   

}

#pragma mark---左边的tablew 代理
#pragma mark--deleagte
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.allData.count;
   
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.leftTablew) {
        static NSString * Identifier=@"GameTypeCell";
        GameTypeCell * cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    //
    //    if (!cell) {
    //        cell=[[NSBundle mainBundle] loadNibNamed:@"MultilevelTableViewCell" owner:self options:nil][0];
    //
    //        UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(kLeftWidth-0.5, 0, 0.5, 44)];
    //        label.backgroundColor=tableView.separatorColor;
    //        [cell addSubview:label];
    //        label.tag=kCellRightLineTag;
    //    }
        
        
    //    cell.selectionStyle=UITableViewCellSelectionStyleNone;
        rightMeun * title=self.allData[indexPath.row];
        cell.meun = title;
        if(title.show_name){
            cell.leftLab.text=title.meunName;
//            [cell.imgV mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(cell.bgImgV);
//                make.top.equalTo(cell.bgImgV).offset(3);
//                make.size.mas_equalTo(CGSizeMake(28, 28));
//            }];
        }else{
            cell.leftLab.text = @"";
            [cell.imgV mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(cell.bgImgV);
                make.centerY.equalTo(cell.bgImgV).offset(-3);
              
                make.size.mas_equalTo(CGSizeMake(33, 33));
            }];
        }
        if (title.urlName && title.urlName.length>0) {
//            [cell.imgV sd_setImageWithURL:[NSURL URLWithString:title.urlName]];
            
//            WeakSelf
            [cell.imgV sd_setImageWithURL:[NSURL URLWithString:title.urlName] placeholderImage:[ImageBundle imagewithBundleName:kImageDefaultName] options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
               
            }];
            
        }else{
            cell.imgV.image = nil;
        }
        
        if (indexPath.row==self.selectIndex) {
            NSLog(@"设置 点中");
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self setLeftTablewCellSelected:YES withCell:(MultilevelTableViewCell*)cell];
        }
        else{
            [self setLeftTablewCellSelected:NO withCell:(MultilevelTableViewCell*)cell];

            NSLog(@"设置 不点中");

        }
        

        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            cell.layoutMargins=UIEdgeInsetsZero;
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset=UIEdgeInsetsZero;
        }
        
        
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%ldIndexcell",(long)indexPath.row]];
        cell.backgroundColor = [UIColor clearColor];
        if ([cell.contentView subviews].count == 0) {
            [cell.contentView addSubview: [self.rightCollections objectAtIndex:indexPath.row]];
            [((UICollectionView *)[self.rightCollections objectAtIndex:indexPath.row]) mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(cell);
            }];
        }
        return cell;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.leftTablew) {
        return 54;
    } else {
        if (((UICollectionView *)[self.rightCollections objectAtIndex:indexPath.row]).contentSize.height< 5) {
            return 150;
        }else{
            return ((UICollectionView *)[self.rightCollections objectAtIndex:indexPath.row]).contentSize.height;
        }
        

//        if (((UICollectionView *)[self.rightCollections objectAtIndex:indexPath.row]).contentSize.height == 0) {
//            return  UITableViewAutomaticDimension ;
//        } else {
////            float userDefaultsHeight = [common getgamecontroller_table_height:indexPath.row];
//            float height = ((UICollectionView *)[self.rightCollections objectAtIndex:indexPath.row]).contentSize.height;
////            if (height > userDefaultsHeight) {
////                [common savegamecontroller_table_height:indexPath.row height: height];
////            }
//            return height; //> userDefaultsHeight ? height : userDefaultsHeight;
//        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.leftTablew) {
        MultilevelTableViewCell * cell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
       
    //    MultilevelTableViewCell * BeforeCell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndex:_selectIndex]];
    //
    //    [self setLeftTablewCellSelected:NO withCell:BeforeCell];
        _selectIndex=indexPath.row;
        
        [self setLeftTablewCellSelected:YES withCell:cell];

//        rightMeun * title=self.allData[indexPath.row];
        
//        if(indexPath.row < self.allData.count) {
//           [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:false];
//        }
        
        
        self.isReturnLastOffset=NO;
        
     

        self.loadImageNum = 0;
//        [self.rightCollection.collectionViewLayout invalidateLayout];
        
//        [self.rightCollection reloadData];
        
//        NSIndexSet *reloadSet = [NSIndexSet indexSetWithIndex:indexPath];
//        [self.rightCollection reloadSections:reloadSet];
        

        
//        if (self.isRecordLastScroll) {
//    //        [self.rightCollection scrollRectToVisible:CGRectMake(0, title.offsetScorller - 34, self.rightCollection.frame.size.width, self.rightCollection.frame.size.height) animated:self.isRecordLastScrollAnimated];
//    
//            [self.rightCollection setContentOffset:CGPointMake(0, title.offsetScorller) animated:self.isRecordLastScrollAnimated];
//        }
//        else{
//            [self.rightCollection setContentOffset:CGPointMake(0, 0) animated:self.isRecordLastScrollAnimated];
//    //        [self.rightCollection scrollRectToVisible:CGRectMake(0, 0, self.rightCollection.frame.size.width, self.rightCollection.frame.size.height) animated:self.isRecordLastScrollAnimated];
//        }
        self.isLeftTableDidSelected = YES;
//        [self.rightTablew selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
       
//        ((UICollectionView *)[self.rightCollections objectAtIndex:indexPath.row]).hidden = false;
//        [((UICollectionView *)[self.rightCollections objectAtIndex:indexPath.row]) reloadData];
//        [self.rightTablew reloadData];
        [self.rightTablew  scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        if ([_cacheSelected objectForKey:minnum(indexPath.row)]) {
            return;
        }
        [_cacheSelected setObject:@"TRUE" forKey:minnum(indexPath.row)];
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
           
            [strongSelf.rightTablew  scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            strongSelf.isLeftTableDidSelected = NO;
        });
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.leftTablew) {
        MultilevelTableViewCell * cell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    //    cell.titile.textColor=self.leftUnSelectColor;
    //    UILabel * line=(UILabel*)[cell viewWithTag:100];
    //    line.backgroundColor=tableView.separatorColor;

        [self setLeftTablewCellSelected:NO withCell:cell];

    //    cell.backgroundColor=self.leftUnSelectBgColor;
    }
}

/**
 * 每个item的高度
 */
- (CGRect)waterFallLayout:(LMHWaterFallLayout *)waterFallLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath contentHeight:(CGFloat)contentHeight{
    NSInteger  oneCellCount = 0;
    NSInteger  twoCellCount = 0;
    NSString *  cellType = @"";
    
    NSInteger index = [self.rightCollections indexOfObject:waterFallLayout.collectionView];
    CGFloat Margin = (((UICollectionView *)[self.rightCollections objectAtIndex:index]).frame.size.width -20- 3*80)/2;
    
    rightMeun * title=self.allData[index];
    rightMeun * meun;
    
    meun=title.nextArray[indexPath.section];
    
    if (meun.nextArray.count>0) {
        meun=title.nextArray[indexPath.section];
    }
    CGFloat y = contentHeight;
    CGFloat x = 10;
    CGFloat width = 0;
    CGFloat height = 105;
    for( int i = 0 ;i < meun.nextArray.count;i ++){
        rightMeun *data = meun.nextArray[i];
        cellType = data.type;
        if(i == indexPath.row){
            break;
        }else if(![data.type isEqualToString:@"game"]) {
            oneCellCount += 1;
        }else{
            twoCellCount += 1;
        }
    }
    CGFloat headerHeightT = 0;
    if(!title.show_name){
        headerHeightT = 5;
    }
    if(indexPath.row == 0){
        x = 10;
        y += headerHeightT;
        if(![cellType isEqualToString:@"game"]) {
            width = ((UICollectionView *)[self.rightCollections objectAtIndex:index]).frame.size.width -20;
        }else{
            width = 80;
        }
    }else if(![cellType isEqualToString:@"game"]) {
        x = 10;
        width = ((UICollectionView *)[self.rightCollections objectAtIndex:index]).frame.size.width -20;
    }else{
        width = 80;
        x = 10 + (twoCellCount % 3 )*(80 + Margin);
        if(twoCellCount%3){
            y -= 105;
        }
    }
    float heightCellValue = 105;
    
    if (meun.nextArray.count<1) {
        NSString *heightCell = [self.heightCellDic objectForKey:[NSString stringWithFormat:@"%@",meun.urlName]];
        if (heightCell) {
            heightCellValue = [heightCell floatValue];
        } 
        else {
       
            NSDictionary *storedDict = [CacheImageKey sharedManager].gameheightDic;
            if (storedDict && meun.urlName != nil && [storedDict objectForKey:meun.urlName]) {
                NSString *sizeString = [storedDict objectForKey:meun.urlName];
                CGSize imageSize = CGSizeFromString(sizeString);
                float height = floor((width/imageSize.width)*imageSize.height);
                heightCellValue = height;
                NSString *heightCell = [NSString stringWithFormat:@"%.0f",height];
                
                [self.heightCellDic setObject:heightCell forKey:meun.urlName];
            }
        }
        height = ([meun.type isEqualToString:@"game"] == false)?heightCellValue+8:height;
    }else{
        meun = meun.nextArray[indexPath.row];
        NSString *heightCell = [self.heightCellDic objectForKey:[NSString stringWithFormat:@"%@",meun.urlName]];
        if (heightCell) {
            heightCellValue = [heightCell floatValue];
        } 
        else {
           
            NSDictionary *storedDict = [CacheImageKey sharedManager].gameheightDic;
            if (storedDict && meun.urlName != nil && [storedDict objectForKey:meun.urlName]) {
                NSString *sizeString = [storedDict objectForKey:meun.urlName];
                CGSize imageSize = CGSizeFromString(sizeString);
                float height = floor((width/imageSize.width)*imageSize.height);
                heightCellValue = height;
                NSString *heightCell = [NSString stringWithFormat:@"%.0f",height];
                [self.heightCellDic setObject:heightCell forKey:meun.urlName];
            }
        }
        height = ([meun.type isEqualToString:@"game"] == false)?heightCellValue+8:height;
    }

    [self.rightTablew reloadData];
    return CGRectMake(x, y, width,height);

}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if(!_tmptest){
        return 0;
    }
    
    
    if (self.allData.count==0) {
        return 0;
    }
    
    rightMeun * title=self.allData[[self.rightCollections indexOfObject:collectionView]];
     return   title.nextArray.count;
    
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(!_tmptest){
        return 0;
    }
    rightMeun * title=self.allData[[self.rightCollections indexOfObject:collectionView]];
    if (title.nextArray.count>0) {
        
        rightMeun *sub=title.nextArray[section];
        
        if (sub.nextArray.count==0)//没有下一级
        {
            return 1;
        }
        else
            return sub.nextArray.count;
        
    }
    else{
    return title.nextArray.count;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    rightMeun * title=self.allData[[self.rightCollections indexOfObject:collectionView]];
    NSArray * list;
    
    
    
    rightMeun * meun;
    
    meun=title.nextArray[indexPath.section];
    
    if (meun.nextArray.count>0) {
        meun=title.nextArray[indexPath.section];
        list=meun.nextArray;
        meun=list[indexPath.row];
    }


    void (^select)(NSInteger left,NSInteger right,id info) = self.block;
    
    select(self.selectIndex,indexPath.row,meun);
    
}
// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    

    rightMeun * title=self.allData[[self.rightCollections indexOfObject:collectionView]];
    NSArray * list;
    
    rightMeun * meun;

    meun=title.nextArray[indexPath.section];

    BOOL bEmptyMeun = true;
    if (meun.nextArray.count>0) {
        meun=title.nextArray[indexPath.section];
        list=meun.nextArray;
        meun=list[indexPath.row];
        bEmptyMeun = false;
    }
    if([meun.type isEqualToString:@"game"]){
        MultilevelCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kMultilevelCollectionViewCell forIndexPath:indexPath];
        if(meun.show_name){
            cell.titile.text=meun.meunName;
        }else{
            cell.titile.text= @"";
        }
        cell.titile.adjustsFontSizeToFitWidth = YES;
        cell.titile.minimumScaleFactor = 0.1;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:meun.urlName] placeholderImage:[ImageBundle imagewithBundleName:kImageDefaultName]];
        
    //    cell.layer.cornerRadius = 3;                           //圆角弧度
    //    cell.layer.borderWidth = 1;
    //    cell.layer.borderColor=[UIColor colorWithRed:188/255.0 green:190/255.0 blue:197/255.0 alpha:1.0].CGColor;
    //    cell.layer.shadowOffset = CGSizeMake(1, 1);             //阴影的偏移量
    ////    cell.layer.shadowRadius = 5;
    //    cell.layer.shadowOpacity = 1;                         //阴影的不透明度
    //    cell.layer.shadowColor = [UIColor blackColor].CGColor;  //阴影的颜色
       
        return cell;
    }else{
        MultilevelCollectionViewBigCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kMultilevelCollectionViewBigCell forIndexPath:indexPath];
//        cell.backgroundColor=[UIColor clearColor];
//        cell.imageView.backgroundColor=[UIColor clearColor];//UIColorFromRGB(0xF8FCF8);
//        cell.imageView.layer.cornerRadius = 10;
//        cell.imageView.layer.masksToBounds = YES;
        
        WeakSelf
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:meun.urlName] placeholderImage:[ImageBundle imagewithBundleName:kImageDefaultName] options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            STRONGSELF
            if(strongSelf == nil){
                return;
            }
            if(image!= nil){
                float height = floor((cell.imageView.width/image.size.width)*image.size.height);
                NSString *heightCell = [NSString stringWithFormat:@"%.0f",height];
                NSString *keyImgv = [NSString stringWithFormat:@"%@",imageURL.absoluteString];
                
                if (![strongSelf.heightCellDic objectForKey:keyImgv]) {
                    [strongSelf.heightCellDic setObject:heightCell forKey:keyImgv];
                    [collectionView reloadData];
                }
            }
        }];
        
        return cell;
    }

}
//// 右侧标题
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    
//    NSString *reuseIdentifier;
//    if ([kind isEqualToString: UICollectionElementKindSectionFooter ]){
//        reuseIdentifier = @"footer";
//    }else{
//        reuseIdentifier = kMultilevelCollectionHeader;
//    }
//    
//    rightMeun * title=self.allData[[self.rightCollections indexOfObject:collectionView]];
//    
//    UICollectionReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
//    
//    UILabel *label = (UILabel *)[view viewWithTag:1];
//    label.font=[UIFont systemFontOfSize:15];
//    label.textColor=UIColorFromRGB(0x686868);
//    label.text = @"";
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && title.show_name){
//        
//        if (title.nextArray.count>0) {
//        
//            rightMeun * meun;
//            if (title.nextArray.count > indexPath.section) {
//                meun=title.nextArray[indexPath.section];
//                NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:minstr(meun.meunName) attributes:nil];
//                NSTextAttachment *regionAttchment = [[NSTextAttachment alloc]init];
//                regionAttchment.bounds = CGRectMake(0, -2, 17, 13);//设置frame
//                regionAttchment.image = [ImageBundle imagewithBundleName:@"game_bt1"];
//                NSAttributedString *regionString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(regionAttchment)];
//                [noteStr insertAttributedString:regionString atIndex:0];
//                NSTextAttachment *regionAttchment2 = [[NSTextAttachment alloc]init];
//                regionAttchment2.bounds = CGRectMake(0, -2, 17, 13);//设置frame
//                regionAttchment2.image = [ImageBundle imagewithBundleName:@"game_bt2"];
//                NSAttributedString *regionString2 = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(regionAttchment2)];
//                [noteStr appendAttributedString:regionString2];
//                label.attributedText=noteStr;
//            }
//        }
//        else{
//            label.text=YZMsg(@"public_noEmpty");
//        }
//    }
//    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
//        view.backgroundColor = [UIColor lightGrayColor];
//        label.text = [NSString stringWithFormat:@"footer:%ld",(long)indexPath.section];
//    }
//    return view;
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    return CGSizeMake(80, 105);
//}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}
//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(LMHWaterFallLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    CGSize size={kScreenWidth,44};
//    return size;
//}


#pragma mark---记录滑动的坐标
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.rightTablew]) {

        
        self.isReturnLastOffset=YES;
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([scrollView isEqual:self.rightTablew]) {
        
//        rightMeun * title=self.allData[self.selectIndex];
//        
//        title.offsetScorller=scrollView.contentOffset.y;
        self.isReturnLastOffset=NO;
        
    }

 }

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.rightTablew]) {
        
        rightMeun * title=self.allData[self.selectIndex];
        
        title.offsetScorller=scrollView.contentOffset.y;
        self.isReturnLastOffset=NO;
        
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.isRightTableCanScroll == NO) {
        if (!self.isLeftTableDidSelected) {
            scrollView.contentOffset = CGPointZero;
        }
    } else if (scrollView.contentOffset.y <= 0 && self.rightTablew.contentOffset.y <= 0) {
        self.isRightTableCanScroll = NO;
        self.isLeftTableDidSelected = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SetTableCanScroll" object:nil];
    } else {
       
        if ([scrollView isEqual: self.rightTablew] &&  self.isLeftTableDidSelected ==NO) {
            NSArray *visibleIndexPaths = [self.rightTablew indexPathsForVisibleRows];
            if (visibleIndexPaths.count > 0) {
                NSIndexPath *firstVisibleIndexPath = visibleIndexPaths[0];
                NSIndexPath *indexPathToSelect = [NSIndexPath indexPathForRow:firstVisibleIndexPath.row inSection:firstVisibleIndexPath.section];
                [self.leftTablew selectRowAtIndexPath:indexPathToSelect animated:YES scrollPosition:UITableViewScrollPositionNone];
                [self.leftTablew  scrollToRowAtIndexPath:indexPathToSelect atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                self.isLeftTableDidSelected = NO;
            }
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual: self.leftTablew]) {
        CGPoint rightOffset = self.rightTablew.contentOffset;
        if (rightOffset.y == 0) {
            BOOL scrEnabled = self.rightTablew.isScrollEnabled;
            [self.rightTablew setScrollEnabled:NO];
            self.rightTablew.contentOffset = CGPointMake(rightOffset.x, 1);
            [self.rightTablew setScrollEnabled:scrEnabled];
        }
    } else {
        CGPoint leftOffset = self.leftTablew.contentOffset;
        if (leftOffset.y == 0) {
            BOOL scrEnabled = self.leftTablew.isScrollEnabled;
            [self.leftTablew setScrollEnabled:NO];
            self.leftTablew.contentOffset = CGPointMake(leftOffset.x, 1);
            [self.leftTablew setScrollEnabled:scrEnabled];
        }
    }
}

#pragma mark--Tools
-(void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}
@end



@implementation rightMeun



@end


