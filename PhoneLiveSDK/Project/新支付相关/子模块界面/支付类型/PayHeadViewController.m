//
//  PayHeadViewController.m
//
//

#import "PayHeadViewController.h"
#import "PayHeadCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "myWithdrawVC2.h"
#import "webH5.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kPayHeadCollectionViewCell @"PayHeadCollectionViewCell"
#define kImageDefaultName @""

@interface PayHeadViewController (){
    NSMutableArray *allData;
    BOOL bUICreated; // UI是否创建
    NSIndexPath *curselectIndex;
}


@end

@implementation PayHeadViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    
    
}
- (void)viewDidAppear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"moneyChange" object:nil];
//    [self getInfo];
//    self.contentView.bottom = _window_height + self.contentView.frame.origin.y;
//    self.contentView.hidden = NO;
//    [UIView animateWithDuration:0.25 animations:^{
//        //        self.view.frame = f;
//        self.contentView.bottom = _window_height;
//    } completion:^(BOOL finished) {
//    }];
//     通知默认项
//    if(allData!= nil && allData.count>curselectIndex.row){
//        NSArray *arr = [allData objectAtIndex:curselectIndex.row][@"models"];
//        if(arr){
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_SelectPayType" object:nil userInfo:@{@"selectIndex":[NSString stringWithFormat:@"%ld", curselectIndex.row], @"content":arr}];
//        }
//        [self initCollection];
//        [self refreshUI];
//    }else{
//        [self initCollection];
//        [self refreshUI];
//    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.navigationItem.title = @"投注中心";
    self.view.backgroundColor = [UIColor clearColor];
   
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.gamesCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
}
-(void)exitView{
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.contentView.bottom = _window_height + strongSelf.contentView.frame.origin.y;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.view removeFromSuperview];
        [strongSelf removeFromParentViewController];
    }];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"moneyChange" object:nil];
}
-(void)setChargeData:(NSArray *)dict{
    self.gamesCollection.hidden = YES;
    if ([dict isKindOfClass:[NSArray class]]) {
        allData = [NSMutableArray arrayWithArray:dict];
    }
    curselectIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    
    dispatch_main_async_safe(^{
//        [self initCollection];
//        [self refreshUI];
        
//        WeakSelf
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            STRONGSELF
//            if (strongSelf == nil) {
//                return;
//            }
//            if (strongSelf->allData!= nil && strongSelf->allData.count>0) {
//                [strongSelf collectionView:strongSelf.gamesCollection didSelectItemAtIndexPath:strongSelf->curselectIndex];
//            }
//        });
    });
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf initCollection];
        [strongSelf refreshUI];
     
        if (strongSelf->allData!= nil && strongSelf->allData.count>0) {
            NSArray *arr = [strongSelf->allData objectAtIndex:strongSelf->curselectIndex.row][@"models"];
            if(arr){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_SelectPayType" object:nil userInfo:@{@"selectIndex":[NSString stringWithFormat:@"%ld", strongSelf->curselectIndex.row], @"content":arr}];
            }
        }
        
    });
   
}

-(void)refreshUI{

    if(!bUICreated||self.gamesCollection.dataSource == nil){
        [self initCollection];
    }else{
        [self.gamesCollection reloadData];
    }
   
    self.gamesCollection.hidden = NO;
   
    if(allData && allData.count>0){
       
        if(allData.count>curselectIndex.row){
            NSArray *arr = [allData objectAtIndex:curselectIndex.row][@"models"];
            if(arr&& arr.count>0){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_UpdateBalance" object:nil userInfo:arr[0]];
            }
           
        }
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.parentViewController.view endEditing:YES];
}


- (void)initCollection {
    bUICreated = true;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 5.f;//左右间隔
    flowLayout.minimumLineSpacing = 5.f;
    
    self.gamesCollection.delegate = self;
    self.gamesCollection.dataSource = self;
    self.gamesCollection.collectionViewLayout = flowLayout;
    self.gamesCollection.allowsMultipleSelection = YES;
    self.gamesCollection.scrollEnabled = NO;

    UINib *nib=[UINib nibWithNibName:kPayHeadCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [self.gamesCollection registerNib: nib forCellWithReuseIdentifier:kPayHeadCollectionViewCell];

    self.gamesCollection.backgroundColor=[UIColor clearColor];

}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (allData.count==0) {
        return 0;
    }
    

//    NSDictionary *dict =ways[waySelectIndex];
//    NSArray *array = dict[@"options"];
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (allData.count==0) {
        return 0;
    }
    NSInteger topHeight = 5;
    NSInteger LineSpacing = 5.f;
    double fLineCount = allData.count / 3.0;
    NSInteger iLineCount = ceil(fLineCount);
    self.viewHeight.constant = iLineCount * (90 + LineSpacing) + topHeight + LineSpacing + 78;
    self.view.height = self.viewHeight.constant;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
    });
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
//    });
    return allData.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.parentViewController.view endEditing:YES];
    NSIndexPath * lastIndexPath = curselectIndex;
    curselectIndex = indexPath;
    if ([curselectIndex length] == 2 && lastIndexPath.item < allData.count) {
        [collectionView reloadItemsAtIndexPaths:@[lastIndexPath]];
    }
    [collectionView reloadItemsAtIndexPaths:@[curselectIndex]];
    
    // 通知选中
    if (allData) {
        NSArray *arr = [allData objectAtIndex:curselectIndex.row][@"models"];
        NSString *charge_type = [allData objectAtIndex:curselectIndex.row][@"head"][@"title"]; // 充值大类名称
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_SelectPayType" object:nil userInfo:@{@"selectIndex":[NSString stringWithFormat:@"%ld", curselectIndex.row], @"content":arr, @"charge_type": charge_type}];
    }
   
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PayHeadCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kPayHeadCollectionViewCell forIndexPath:indexPath];
    NSDictionary *dict = [allData objectAtIndex:indexPath.row][@"head"];

    cell.title.text = minstr(dict[@"title"]);
    cell.subTitle.text = minstr(dict[@"subTitle"]);
    
    [cell.logo sd_setImageWithURL:[NSURL URLWithString:dict[@"icon"]] placeholderImage:[ImageBundle imagewithBundleName:kImageDefaultName]];
    NSString *subIconUrl = minstr(dict[@"subIcon"]);
    if(subIconUrl && ![subIconUrl isKindOfClass:[NSNull class]] && subIconUrl.length > 0){
        cell.subLogo.hidden = NO;
        [cell.subLogo sd_setImageWithURL:[NSURL URLWithString:subIconUrl] placeholderImage:[ImageBundle imagewithBundleName:kImageDefaultName]];
    }else{
        cell.subLogo.hidden = YES;
    }
    
    cell.clickBtn.tag = indexPath.row;
//    [cell.clickBtn addTarget:self action:@selector(doSelect:) forControlEvents:UIControlEventTouchUpInside];
//    cell.logo.layer.cornerRadius = cell.frame.size.height / 2;  // 圆角弧度
//    cell.logo.layer.shadowOffset = CGSizeMake(1, 1);            // 阴影的偏移量
//////    cell.layer.shadowRadius = 5;
//    cell.logo.layer.shadowOpacity = 1;                          // 阴影的不透明度
//    cell.logo.layer.shadowColor = [UIColor blackColor].CGColor; // 阴影的颜色
    
    if(curselectIndex.row == indexPath.row){
        [cell setSelectedStatus:true];
        
//        NSArray *arr = [allData objectAtIndex:indexPath.row][@"models"];
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////            [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_SelectPayType" object:nil userInfo:@{@"selectIndex":[NSString stringWithFormat:@"%ld", indexPath.row], @"content":arr}];
////        });
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_SelectPayType" object:nil userInfo:@{@"selectIndex":[NSString stringWithFormat:@"%ld", indexPath.row], @"content":arr}];
//        });
    }else{
        [cell setSelectedStatus:false];
    }
//    }else{
//        cell.selected = false;
//    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
//    NSDictionary *dict =ways[waySelectIndex];
//    NSArray *array = dict[@"options"];
//    float matchW = self.rightCollection.width / array.count - 6; // 6是最小间距
//    float scaleRate = MAX(MIN(matchW, 80), 65) / 80;
    
    float scaleRate = 1;
    
    return CGSizeMake((_window_width-45)/3 * scaleRate, 90 * scaleRate);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSDictionary *dict =ways[waySelectIndex];
//    NSArray *array = dict[@"options"];
//    float matchW = self.rightCollection.width / array.count;
//    float scaleRate = MIN(matchW, 80) / 80;
    float scaleRate = 1;
    
    return CGSizeMake((_window_width-45)/3 * scaleRate, 90 * scaleRate);
}
//
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(0, 10, 0, 10);
//}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={kScreenWidth,10};
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
