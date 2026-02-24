//
//  CommonCollectionViewController2.m
//
//

#import "CommonCollectionViewController2.h"
#import "BetOptionCollectionViewCell2.h"
#import "PayViewController.h"
#import "ChipSwitchViewController.h"
#import "BetConfirmViewController.h"
#import "OpenHistoryViewController.h"
#import "IssueCollectionViewCell.h"
#import "popWebH5.h"
#import "OptionModel.h"
#import "UIButton+Additions.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kCellRightLineTag 100
#define kBetOptionCollectionViewCell2 @"BetOptionCollectionViewCell2"
#define kIssueCollectionViewCell @"IssueCollectionViewCell"
#define kCollectionHeader   @"LotteryCollectionHeader"

@interface CommonCollectionViewController2 (){
    BOOL bUICreated; // UI是否创建;
    
    NSInteger curLotteryType; // 当前投注界面对应的彩种类型
    
    // 当前选中的投注项
    NSDictionary *curOptions;
    
    // 显示类型
    CollectionShowMode showMode;
    
    // 已选择数据
    NSMutableArray *selectedArr;
    // 总数据源
    NSMutableArray *dataArr;
    // section名称
    NSMutableArray *sectionNameArr;
    
    // section是否互斥
    BOOL bSectionMutx;
    // 最小注单数
    NSInteger minZhu;
    // 最大注单数
    NSInteger maxZhu;
    
    UICollectionViewFlowLayout *flowLayout;
}

@end

@implementation CommonCollectionViewController2

-(void)exitView
{
    
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    //[self getInfo];
    [self refreshUI];
    //    self.contentView.bottom = _window_height + self.contentView.frame.origin.y;
    // self.contentView.hidden = NO;
    //    [UIView animateWithDuration:0.25 animations:^{
    //        //        self.view.frame = f;
    //        self.contentView.bottom = _window_height;
    //    } completion:^(BOOL finished) {
    //        UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitView)];
    //        [self.shadowView addGestureRecognizer:myTap];
    //    }];
}

- (void)viewWillDisappear:(BOOL)animated{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    self.rightCollection.backgroundColor= UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    //    self.navigationItem.title = @"投注中心";
    
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.rightCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    self.view.width = _window_width;
    self.view.height = _window_height;
    if(!minZhu){
        minZhu = 1;
    }
    if(!maxZhu){
        maxZhu = 999;
    }
}

- (void)setLotteryType:(NSInteger)lotteryType{
    curLotteryType = lotteryType;
    //[GameToolClass setCurOpenedLotteryType:lotteryType];
}

- (void)setShowMode:(CollectionShowMode)_showMode{
    showMode = _showMode;
    if(showMode == CollectionShowMode_NOTITLE){
        
    }
}

-(void)setLotterySectionOptions:(NSArray *)options{
    //curOptions = options;
    
    if(dataArr){
        [dataArr removeAllObjects];
    }else{
        dataArr = [[NSMutableArray alloc]init];
    }
    if(selectedArr){
        [selectedArr removeAllObjects];
    }else{
        selectedArr = [[NSMutableArray alloc]init];
    }
    if(sectionNameArr){
        [sectionNameArr removeAllObjects];
    }else{
        sectionNameArr = [[NSMutableArray alloc]init];
    }
    
    id dict = [options firstObject];
    if([dict isKindOfClass:[NSDictionary class]]){
        if([dict objectForKey:@"title"]){
            NSMutableArray *sectionArr = [[NSMutableArray alloc]init];
            NSInteger sectionIdx = dataArr.count;
            NSInteger maxCount = options.count;
            for (int i = 0; i < maxCount; i++) {
                NSDictionary *optionData = options[i];
                
                OptionModel *model = [[OptionModel alloc]init];
                model.isSelected = NO;
                model.title = optionData[@"title"];
                model.type = @"num";
                model.value = optionData[@"value"];
                model.desc = optionData[@"desc"];
                model.rest = optionData[@"rest"];
                model.indexpath = [NSIndexPath indexPathForItem:sectionArr.count inSection:sectionIdx];
                [sectionArr addObject:model];
            }
            [dataArr addObject:sectionArr];
            return;
        }
    }
    
    NSInteger maxCount = options.count;
    for (int i = 0; i < maxCount; i ++) {
        NSMutableArray *sectionArr = [[NSMutableArray alloc]init];
        NSDictionary *optionInfo = options[i];
        [sectionNameArr addObject:optionInfo[@"st"]];
        NSInteger sectionIdx = dataArr.count;
        id optionData = optionInfo[@"data"];
        
        if([optionData isKindOfClass:[NSArray class]]){
            NSArray *array = optionData;
            NSInteger maxCount = array.count;
            for (int i = 0; i < maxCount; i++) {
                NSDictionary *optionData = array[i];
                
                OptionModel *model = [[OptionModel alloc]init];
                model.isSelected = NO;
                model.title = optionData[@"title"];
                model.type = @"number";
                model.st = optionData[@"st"];
                model.value = optionData[@"value"];
                model.desc = optionData[@"desc"];
                model.rest = optionData[@"rest"];
                model.indexpath = [NSIndexPath indexPathForItem:sectionArr.count inSection:sectionIdx];
                [sectionArr addObject:model];
            }
        }else{
            NSArray *arraytext = optionData[@"text"];
            NSArray *arraynum = optionData[@"num"];
            if(arraytext != nil && arraytext.count>0){
                NSInteger maxCount = arraytext.count;
                for (int i = 0; i < maxCount; i++) {
                    NSDictionary *optionData = arraytext[i];
                    OptionModel *model = [[OptionModel alloc]init];
                    model.isSelected = NO;
                    model.title = optionData[@"title"];
                    model.st = optionData[@"st"];
                    model.type = @"text";
                    model.value = optionData[@"value"];
                    model.desc = optionData[@"desc"];
                    model.rest = optionData[@"rest"];
                    model.indexpath = [NSIndexPath indexPathForItem:sectionArr.count inSection:sectionIdx];
                    [sectionArr addObject:model];
                }
            }
            if(arraynum!= nil && arraynum.count>0){
                NSInteger maxCount = arraynum.count;
                for (int i = 0; i < maxCount; i++) {
                    NSDictionary *optionData = arraynum[i];
                    OptionModel *model = [[OptionModel alloc]init];
                    model.isSelected = NO;
                    model.title = optionData[@"title"];
                    model.st = optionData[@"st"];
                    model.type = @"num";
                    model.value = optionData[@"value"];
                    model.desc = optionData[@"desc"];
                    model.rest = optionData[@"rest"];
                    model.indexpath = [NSIndexPath indexPathForItem:sectionArr.count inSection:sectionIdx];
                    [sectionArr addObject:model];
                }
            }
        }
        
        [dataArr addObject:sectionArr];
    }
}

-(void)setMaxZhu:(NSInteger)_maxZhu{
    maxZhu = _maxZhu;
}

-(void)refreshUI{
    if(!bUICreated){
        [self initUI];
    }
    self.rightCollection.hidden = NO;
}

-(void)initUI{
    bUICreated = true;
    // 初始化投注选项
    [self initScrollView];
}

- (void)initScrollView {
    //    FLLayout *layout = [[FLLayout alloc]init];
    //    layout.dataSource = self;
    // 投注选项Collection
    
    // 初始化 UICollectionViewFlowLayout
    flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 1.0; // 设置 cell 之间的最小间距
    flowLayout.minimumLineSpacing = 1.0;      // 设置行之间的最小间距
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 4, 0, 4); // 设置 section 内边距
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.headerReferenceSize = CGSizeMake(100, 22);
    
    self.rightCollection.delegate = self;
    self.rightCollection.dataSource = self;
    self.rightCollection.collectionViewLayout = flowLayout;
    self.rightCollection.allowsMultipleSelection = YES;
    
    UINib *nib=[UINib nibWithNibName:kBetOptionCollectionViewCell2 bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [self.rightCollection registerNib: nib forCellWithReuseIdentifier:kBetOptionCollectionViewCell2];
    UINib *header=[UINib nibWithNibName:kCollectionHeader bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.rightCollection registerNib:header forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCollectionHeader];
}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return dataArr.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *sectionArr = dataArr[section];
    return sectionArr.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section{
    NSArray *sectionArr = dataArr[section];
    return sectionArr.count;
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(selectedArr.count >= maxZhu){
//        [MBProgressHUD showError:[NSString stringWithFormat:@"最多选择%ld个号码~", (long)maxZhu]];
        [MBProgressHUD showError:[NSString stringWithFormat:YZMsg(@"CommonCollectionVC2_selected %ld Warning"),(long)maxZhu]];
        return NO;
    }
    return YES;
}
//called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    BetOptionCollectionViewCell2 *cell=[collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = true;
    BOOL ret = [self selectedOrDeselectedItemAtIndexPath:indexPath];
    if(!ret){
        cell.selected = false;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeLottery_didSelected" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CancelMachineSelection" object:nil];
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    BetOptionCollectionViewCell2 *cell=[collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = false;
    BOOL ret = [self selectedOrDeselectedItemAtIndexPath:indexPath];
    if(!ret){
        cell.selected = true;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeLottery_didSelected" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CancelMachineSelection" object:nil];
}

- (BOOL)selectedOrDeselectedItemAtIndexPath:(NSIndexPath*)indexPath {
    NSArray *sectionArr = dataArr[indexPath.section];
    OptionModel *model = sectionArr[indexPath.item];
    model.isSelected = !model.isSelected;
    //[self.rightCollection reloadItemsAtIndexPaths:@[indexPath]];
    if (model.isSelected) {
        if (![selectedArr containsObject:model]) {
            [selectedArr addObject:model];
        }
    } else {
        if ([selectedArr containsObject:model]) {
            [selectedArr removeObject:model];
        };
    }
    return true;
}

-(void) clearSelectedStatus{
    for (int i = 0; i < selectedArr.count; i++) {
        OptionModel *model = selectedArr[i];
        model.isSelected = false;
        [self.rightCollection reloadItemsAtIndexPaths:@[model.indexpath]];
    }
    [selectedArr removeAllObjects];
}

- (void)randomSelected:(NSInteger)minZhu{
    [self clearSelectedStatus];
    
    NSInteger maxCount = dataArr.count;
    for (int i = 0; i < maxCount; i++) {
        NSArray *sectionArr = dataArr[i];
        NSInteger sectionMaxCount = sectionArr.count;
        
        NSArray *tmpSelectArr;
        NSMutableSet *randomSet = [[NSMutableSet alloc] init];
        int k = 0;
        while ([randomSet count] < minZhu && sectionMaxCount>0) {
            int r = arc4random() % [sectionArr count];
            [randomSet addObject:[sectionArr objectAtIndex:r]];
            k++;
            if(k > 100){
                break;
            }
        }
        tmpSelectArr = [randomSet allObjects];
        for (int j = 0; j < tmpSelectArr.count; j++) {
            OptionModel *model = tmpSelectArr[j];
            model.isSelected = true;
            //[self.rightCollection reloadItemsAtIndexPaths:@[model.indexpath]];
            [self.rightCollection selectItemAtIndexPath:model.indexpath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            if (![selectedArr containsObject:model]) {
                [selectedArr addObject:model];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeLottery_didSelected" object:nil];
}

-(NSMutableArray *)getSelectedOptions{
    return selectedArr;
}

-(void) setBottomSpace:(CGFloat) height{
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.tableBottomSpace.constant = height;
        strongSelf.collectionBottomSpace.constant = height;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.tableBottomSpace.constant = height;
        strongSelf.collectionBottomSpace.constant = height;
    }];
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BetOptionCollectionViewCell2 *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kBetOptionCollectionViewCell2 forIndexPath:indexPath];
    
    NSArray *sectionArr = dataArr[indexPath.section];
    OptionModel *model = sectionArr[indexPath.item];
    model.indexpath = indexPath;
    
   
    NSString *desc = model.desc;//dict[@"desc"];
    cell.way = sectionNameArr[indexPath.section];
    cell.titile.text= model.st;
    
    NSArray *value_splite = [model.value componentsSeparatedByString:@"/"];
    
    if(value_splite.count>1 &&value_splite[1]){
        cell.rate.text=model.value;
    }else{
        cell.rate.text=[NSString stringWithFormat:@"%.2f", [model.value floatValue]];
    }
    cell.backgroundColor=[UIColor clearColor];
    //cell.imageView.backgroundColor=[UIColor whiteColor];// UIColorFromRGB(0xF8FCF8);
    //    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:meun.urlName] placeholderImage:[ImageBundle imagewithBundleName:kImageDefaultName]];
    [cell setupDisplay];
    
    if([minstr(model.type) isEqualToString:@"num"]){
        [cell setNumber:model.st lotteryType:curLotteryType];
    }else{
        [cell setText:model.st];
    }
    
    cell.selected = model.isSelected;
    
    cell.tipBtn.tag = indexPath.row;
    [cell.tipBtn setDataProvider:indexPath];
    [cell.tipBtn addTarget:self action:@selector(doOptionClick:) forControlEvents:UIControlEventTouchUpInside];
    if(desc){
        cell.tipBtn.hidden = NO;
    }else{
        cell.tipBtn.hidden = YES;
    }
    
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier;
    if ([minstr(kind) isEqualToString: UICollectionElementKindSectionFooter ]){
        reuseIdentifier = @"footer";
    }else{
        reuseIdentifier = kCollectionHeader;
    }
    
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    //
    view.width = self.rightCollection.width;
    UILabel *label = (UILabel *)[view viewWithTag:1];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = UIColor.whiteColor;//RGB_COLOR(@"#FE0B78", 1);
    NSString *sectionName = sectionNameArr[indexPath.section];
//    if([sectionName isEqualToString:@"三中二"]){
//        sectionName = [NSString stringWithFormat:@"%@%@",sectionName, @"(中2/中3)"]
//    }else if([sectionName isEqualToString:@"二串"]){
//        sectionName = [NSString stringWithFormat:@"%@%@",sectionName, @"(中2/中3)"]
//    }else{
//
//    }
    label.text = sectionName;
    
    
    //    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
    //
    //        if (title.nextArray.count>0) {
    //
    //
    //            rightMeun * meun;
    //            meun=title.nextArray[indexPath.section];
    //
    //            label.text=meun.meunName;
    //
    //        }
    //        else{
    //            label.text=@"暂无";
    //        }
    //    }
    //    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
    //        view.backgroundColor = [UIColor lightGrayColor];
    //        label.text = [NSString stringWithFormat:@"这是footer:%ld",(long)indexPath.section];
    //    }
    return view;
}
-(void)doOptionClick:(UIButton *)sender{
    NSIndexPath *indexPath = (NSIndexPath *)[sender dataProvider];
    NSArray *sectionArr = dataArr[indexPath.section];
    OptionModel *model = sectionArr[indexPath.item];
    
//    NSDictionary *dict =way;
//    NSArray *array = dict[@"options"];
//    NSString *desc = array[sender.tag][@"desc"];
//
    if(model.desc){
        [MBProgressHUD showError:model.desc];
    }
}

//- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
//    return CGSizeMake(115, 40);
//}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return CGSizeMake(115, 40);
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 计算每个 cell 的宽度
    CGFloat collectionViewWidth = collectionView.frame.size.width;
    CGFloat cellWidth = (collectionViewWidth - flowLayout.sectionInset.left - flowLayout.sectionInset.right - (flowLayout.minimumInteritemSpacing * 1)) / 2;
    
    // 根据你的需求计算每个 cell 的高度
    CGFloat cellHeight = 40; // 根据你的需求计算高度，例如固定值或者根据内容动态计算
    
    return CGSizeMake(cellWidth, cellHeight);
}

//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(0, 1, 0, 1);
//}

// collection头部高度
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={kScreenWidth,44};
    return size;
}

- (UIImage *)createImageWithColor:(UIColor *)color rect:(CGRect)rect radius:(float)radius {
    //设置长宽
    //    CGRect rect = rect;//CGRectMake(0.0f, 0.0f, 80.0f, 30.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *original = resultImage;
    CGRect frame = CGRectMake(0, 0, original.size.width, original.size.height);
    // 开始一个Image的上下文
    UIGraphicsBeginImageContextWithOptions(original.size, NO, 1.0);
    // 添加圆角
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:radius] addClip];
    // 绘制图片
    [original drawInRect:frame];
    // 接受绘制成功的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
