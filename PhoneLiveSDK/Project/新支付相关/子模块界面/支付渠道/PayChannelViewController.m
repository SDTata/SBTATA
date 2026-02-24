//
//  PayChannelViewController.m
//
//

#import "PayChannelViewController.h"
#import "PayChannelCollectionViewCell.h"


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kPayChannelCollectionViewCell @"PayChannelCollectionViewCell"
#define kImageDefaultName @"tempShop2"

@interface PayChannelViewController (){
    NSMutableArray *allData;
    BOOL bUICreated; // UI是否创建
    NSIndexPath *curselectIndex;
    NSString *charge_type;
}
@property (weak, nonatomic) IBOutlet UILabel *payChannelLabel;


@end

@implementation PayChannelViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    [self requestData];
}

- (void)viewDidAppear:(BOOL)animated{

//    [self getInfo];
//    self.contentView.bottom = _window_height + self.contentView.frame.origin.y;
//    self.contentView.hidden = NO;
//    [UIView animateWithDuration:0.25 animations:^{
//        //        self.view.frame = f;
//        self.contentView.bottom = _window_height;
//    } completion:^(BOOL finished) {
//    }];
    if (allData.count>0) {
        NSDictionary *dict = [allData objectAtIndex:curselectIndex.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_SelectPayChannel" object:nil userInfo:@{@"selectIndex":[NSString stringWithFormat:@"%ld", curselectIndex.row], @"subContent":dict[@"subContent"]}];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_SelectPayChannel" object:nil userInfo:@{@"selectIndex":[NSString stringWithFormat:@"%ld", curselectIndex.row]}];
    }
    NSString * str = [NSString stringWithFormat:YZMsg(@"myWithdrawVC2_Account%@_Balance1"),[common name_coin]];
    self.coinNamelab.text = [NSString stringWithFormat:@"%@",str];
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)requestData{
    NSString *getWithdrawUrl = [NSString stringWithFormat:@"User.getWithdraw&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getWithdrawUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        //        [testActivityIndicator stopAnimating]; // 结束旋转
        //        [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏

        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = [info firstObject];
            LiveUser *user = [Config myProfile];
            user.coin =  minstr([infoDic valueForKey:@"coin"]);
            [Config updateProfile:user];
            strongSelf.userCoinLab.text = [YBToolClass getRateBalance:user.coin showUnit:YES];
        }else{
            [MBProgressHUD showError:msg];
        }
        [MBProgressHUD hideHUD];
    } fail:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
    }];
}

- (void)refreshSelectPayType:(NSNotification *)notification {
    if (notification != nil) {
        allData = (notification.userInfo[@"content"]);
        NSString *chargeType = notification.userInfo[@"charge_type"];
        if (chargeType && [chargeType isKindOfClass:[NSString class]] && chargeType.length > 0) {
            charge_type = chargeType;
        } else {
            charge_type = @"支付宝转卡";
        }
    }
    if (allData.count>0) {
        NSDictionary *dict = [allData objectAtIndex:curselectIndex.row];
        NSArray *subContent = dict[@"subContent"];
        NSInteger maxCount = subContent.count;
        for (int i=0; i<maxCount; i++) {
            if([subContent[i][@"type"] isEqualToString:@"channelClass"]){
                NSDictionary *contentDict = subContent[i][@"content"];
                NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:contentDict];
                muDic[@"charge_type"] = charge_type;
                self.channelData = [muDic copy];;
//                if([subContent[i][@"viewType"]  intValue] ==5){
//                    self.userCoinLab.hidden = NO;
//                    LiveUser *user = [Config myProfile];
//                    self.userCoinLab.text = [NSString stringWithFormat:@"%.2f", [user.coin floatValue] / 10];
//                    self.coinNamelab.hidden = NO;
//                }else{
//                    self.userCoinLab.hidden = YES;
//                    self.coinNamelab.hidden = YES;
//                }
                break;
            }
        }
    }
    NSString *tip = @"";
    if (self.channelData) {
       tip = minstr(self.channelData[@"tip"]);
    }
    CGFloat tipHeight = 0;
    if(tip && ![tip isKindOfClass:[NSNull class]] && tip.length > 0){
        self.tipLabel.text = tip;
        self.tipLabel.hidden = NO;
        tipHeight = [self.tipLabel.text boundingRectWithSize:CGSizeMake(self.contentView.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYS_Font(11)} context:nil].size.height;
    }else{
        self.tipLabel.text = @"";
        self.tipLabel.hidden = YES;
    }
    NSInteger topHeight = 0;
    NSInteger LineSpacing = 5.f;
    double fLineCount = allData.count / 2.0;
    NSInteger iLineCount = ceil(fLineCount);
    float heee = iLineCount * (45 + LineSpacing) + topHeight + LineSpacing + 5 + tipHeight;
    self.viewHeight.constant = heee;
    self.view.height = self.viewHeight.constant;
    
    
    [self.gamesCollection reloadData];
}

-(NSDictionary *)getRequestParams{
    NSDictionary *dict = [allData objectAtIndex:curselectIndex.row];
    NSArray *subContent = dict[@"subContent"];
    NSInteger maxCount = subContent.count;
    for (int i=0; i<maxCount; i++) {
        if([subContent[i][@"type"] isEqualToString:@"channelClass"]){
            NSDictionary *contentDict = subContent[i][@"content"];
            dict = contentDict;
            break;
        }
    }
    
    return @{@"channelID":dict[@"channelID"]};
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.payChannelLabel.text = YZMsg(@"PayChanne_title");
    //    self.navigationItem.title = @"投注中心";
    
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.gamesCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataBalance:) name:@"Pay_UpdateBalance" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSelectPayType:) name:@"Pay_RefreshPayType" object:nil];
//    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshUI];
//    });
}
-(void)updateDataBalance:(NSNotification *)notification
{
    [self requestData];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pay_RefreshPayType" object:nil];
}
-(void)setData:(NSArray *)dict{
//    self.gamesCollection.hidden = YES;
//    allData = dict;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self refreshUI];
//    });
}

-(void)refreshUI{
    if(!bUICreated||self.gamesCollection.dataSource == nil){
        [self initUI];
    }
    
    self.gamesCollection.hidden = NO;
}

-(void)initUI{
    bUICreated = true;
    curselectIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    // 初始化投注选项
    [self initCollection];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.gamesCollection addGestureRecognizer:tapGestureRecognizer];
}
-(void)hideKeyBoard
{
    [self.parentViewController.view endEditing:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.parentViewController.view endEditing:YES];
}

- (void)initCollection {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 10.f;//左右间隔
    flowLayout.minimumLineSpacing = 5.f;
    
    self.gamesCollection.delegate = self;
    self.gamesCollection.dataSource = self;
    self.gamesCollection.collectionViewLayout = flowLayout;
    self.gamesCollection.allowsMultipleSelection = YES;

    UINib *nib=[UINib nibWithNibName:kPayChannelCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [self.gamesCollection registerNib: nib forCellWithReuseIdentifier:kPayChannelCollectionViewCell];

    self.gamesCollection.backgroundColor=[UIColor clearColor];

}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (allData.count==0) {
        return 0;
    }
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (allData.count==0) {
        return 0;
    }
    
    return allData.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //[self.parentViewController.view endEditing:YES];
    NSIndexPath * lastIndexPath = curselectIndex;
    if(lastIndexPath.row == indexPath.row){
        NSLog(@"TODO 重复点击不刷新");
//        // 重复点击不刷新
//        return;
    }
    curselectIndex = indexPath;
    if ([curselectIndex length] == 2) {
        [collectionView reloadItemsAtIndexPaths:@[lastIndexPath]];
    }
    [collectionView reloadItemsAtIndexPaths:@[curselectIndex]];
    [self refreshSelectPayType:nil];
    NSDictionary *dict = [allData objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_SelectPayChannel" object:nil userInfo:@{@"selectIndex":[NSString stringWithFormat:@"%ld", indexPath.row], @"subContent":dict[@"subContent"]}];
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PayChannelCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kPayChannelCollectionViewCell forIndexPath:indexPath];
    //NSDictionary *dict = [allData objectAtIndex:indexPath.row];
    NSDictionary *dict = [allData objectAtIndex:indexPath.row];
    NSArray *subContent = dict[@"subContent"];
    NSInteger maxCount = subContent.count;
    for (int i=0; i<maxCount; i++) {
        if([subContent[i][@"type"] isEqualToString:@"channelClass"]){
            NSDictionary *contentDict = subContent[i][@"content"];
            dict = contentDict;
            break;
        }
    }
    
    
    cell.title.text = minstr(dict[@"title"]);
    
    NSString *subTitle = minstr(dict[@"subTitle"]);
    
    if(dict[@"subTitle"] && subTitle.length > 0){
        cell.discountLabel.text = subTitle;
        cell.discountLabel.hidden = NO;
        cell.dicsontBG.hidden = NO;
    }else{
        cell.discountLabel.hidden = YES;
        cell.dicsontBG.hidden = YES;
    }
    
    if(curselectIndex.row == indexPath.row){
        [cell setSelectedStatus:true];
        self.tipLabel.text = minstr(dict[@"tip"]);
        if(dict[@"tip"]){
            self.tipLabel.hidden = NO;
        }else{
            self.tipLabel.hidden = YES;
        }
    }else{
        [cell setSelectedStatus:false];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
//    NSDictionary *dict =ways[waySelectIndex];
//    NSArray *array = dict[@"options"];
//    float matchW = self.rightCollection.width / array.count - 6; // 6是最小间距
//    float scaleRate = MAX(MIN(matchW, 80), 65) / 80;
    
    float scaleRate = 1;
    
    return CGSizeMake((_window_width - 40)/2 * scaleRate, 45 * scaleRate);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSDictionary *dict =ways[waySelectIndex];
//    NSArray *array = dict[@"options"];
//    float matchW = self.rightCollection.width / array.count;
//    float scaleRate = MIN(matchW, 80) / 80;
    float scaleRate = 1;
    
    return CGSizeMake((_window_width - 40)/2  * scaleRate, 45 * scaleRate);
}
//
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(0, 10, 0, 10);
//}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={kScreenWidth, 0};
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
