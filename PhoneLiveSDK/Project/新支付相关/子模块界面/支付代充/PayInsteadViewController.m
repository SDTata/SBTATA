//
//  PayInsteadViewController.m
//
//

#import "PayInsteadViewController.h"
#import "PayInsteadCollectionViewCell.h"


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kPayInsteadCollectionViewCell @"PayInsteadCollectionViewCell"
#define kImageDefaultName @"tempShop2"

@interface PayInsteadViewController (){
    NSMutableDictionary *allData;
    BOOL bUICreated; // UI是否创建
    NSIndexPath *curselectIndex;
}
@property (weak, nonatomic) IBOutlet UILabel *accountTitleLabel;

@end

@implementation PayInsteadViewController



- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    
    
}
- (void)viewDidAppear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFeildChange) name:UITextFieldTextDidChangeNotification object:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)refreshSelectPayChannel:(NSNotification *)notification {
    NSArray *arr = (notification.userInfo[@"subContent"]);
    NSInteger maxCount = arr.count;
    
    
    for (int i=0; i<maxCount; i++) {
        if([minstr(arr[i][@"type"]) isEqualToString:@"insteadClass"]){
            NSDictionary *contentDict = arr[i][@"content"];
            allData = [NSMutableDictionary dictionaryWithDictionary:contentDict];
            break;
        }
    }
    
    if(allData){
        NSString *tip = minstr(allData[@"tip"]);
        self.tipLabel.text = tip;
        
        CGFloat tipHeight = 0;
        if(tip && ![tip isKindOfClass:[NSNull class]] && tip.length > 0){
            tipHeight = [self.tipLabel.text boundingRectWithSize:CGSizeMake(self.contentView.width - 40, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYS_Font(12)} context:nil].size.height + 6;
            self.tipView.hidden = NO;
        }else{
            self.tipView.hidden = YES;
        }
        
        
        NSArray *list = allData[@"users"];
        NSInteger topHeight = 0;
        NSInteger LineSpacing = -1.f;
        double fLineCount = list.count / 1.0;
        NSInteger iLineCount = ceil(fLineCount);
        self.viewHeight.constant = iLineCount * (70 + LineSpacing) + topHeight + LineSpacing + 47 + tipHeight + 6;
        self.view.height = self.viewHeight.constant;
        //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
        //    });
        dispatch_main_async_safe(^{
            //        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
        });
        
        [self.gamesCollection reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.navigationItem.title = @"投注中心";
    
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.gamesCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSelectPayChannel:) name:@"Pay_RefreshPayChannel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Pay_TextFieldChange:) name:@"Pay_TextFieldChange" object:nil];
    
    
    [self refreshUI];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pay_RefreshPayChannel" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pay_TextFieldChange" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)refreshUI{
    if(!bUICreated){
        [self initUI];
    }
    
    self.gamesCollection.hidden = NO;
}

-(void)initUI{
    bUICreated = true;
    curselectIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.accountCopyBtn setTitle:YZMsg(@"publictool_copy") forState:UIControlStateNormal];
    self.tipLabel.text = YZMsg(@"PayInstead_tipwarning");
    self.accountTitleLabel.text = YZMsg(@"PayInstead_accountTitle");
    
    // 初始化投注选项
    [self initCollection];
    
    self.accountLabel.text = [Config getOwnID];
    [self.accountCopyBtn addTarget:self action:@selector(doCopyAccont:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)Pay_TextFieldChange:(NSNotification *)notification {
    NSString *amountStr = notification.userInfo[@"amount"];
    if(!amountStr || [amountStr isKindOfClass:[NSNull class]]){
        return;
    }
    CGFloat amount = [amountStr floatValue];
    NSLog(@"%@", [NSString stringWithFormat:@"当前金额:%.2f",amount]);

    if(amount){
        NSArray *list = allData[@"users"];
        NSInteger maxCount = list.count;
        for (int i=0; i<maxCount; i++) {
            NSDictionary *dict = [list objectAtIndex:i];
            NSInteger quotaValue = [dict[@"quota"] integerValue];
            
            // PayInsteadCollectionViewCell *cell = [self.gamesCollection dequeueReusableCellWithReuseIdentifier:kPayInsteadCollectionViewCell forIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            PayInsteadCollectionViewCell *cell = (PayInsteadCollectionViewCell*)[self.gamesCollection cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            if(quotaValue < amount){
                [cell setBtnEnable:NO];
            }else{
                [cell setBtnEnable:YES];
            }
        }
    }
}

- (void)doCopyAccont:(UIButton *)sender {
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    paste.string = self.accountLabel.text;
    [MBProgressHUD showSuccess:YZMsg(@"publictool_copy_success")];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)initCollection {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0.f;//左右间隔
    flowLayout.minimumLineSpacing = -1.f;
    
    self.gamesCollection.delegate = self;
    self.gamesCollection.dataSource = self;
    self.gamesCollection.collectionViewLayout = flowLayout;
    self.gamesCollection.allowsMultipleSelection = YES;

    UINib *nib=[UINib nibWithNibName:kPayInsteadCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [self.gamesCollection registerNib: nib forCellWithReuseIdentifier:kPayInsteadCollectionViewCell];

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
    NSArray *list = allData[@"users"];
    if (list.count==0) {
        return 0;
    }
    return list.count;
}

//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    [self.parentViewController.view endEditing:YES];
//    NSIndexPath * lastIndexPath = curselectIndex;
//    curselectIndex = indexPath;
//    if ([curselectIndex length] == 2) {
//        [collectionView reloadItemsAtIndexPaths:@[lastIndexPath]];
//    }
//    [collectionView reloadItemsAtIndexPaths:@[curselectIndex]];
//}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PayInsteadCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPayInsteadCollectionViewCell forIndexPath:indexPath];
    NSArray *list = allData[@"users"];
    NSDictionary *dict = [list objectAtIndex:indexPath.row];
    
    cell.nickNameLabel.text = minstr(dict[@"name"]);
    NSInteger quotaValue = [dict[@"quota"] integerValue];
    if(quotaValue >= 10000){
        cell.quotaLabel.text = [NSString stringWithFormat:YZMsg(@"PayInsta_tenTh%.0f"), floor(quotaValue/10000)];
    }else if(quotaValue >= 1000){
        cell.quotaLabel.text = [NSString stringWithFormat:YZMsg(@"PayInsta_Th%.0f"), floor(quotaValue/1000)];
    }else if(quotaValue >= 100){
        cell.quotaLabel.text = [NSString stringWithFormat:YZMsg(@"PayInsta_hund%.0f"), floor(quotaValue/100)];
    }else{
        cell.quotaLabel.text = minstr(dict[@"quota"]);
    }
    
    cell.QQ = dict[@"qq"];
    cell.weChat = dict[@"wechat"];
    cell.alipay = dict[@"alipay"];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    return CGSizeMake(self.gamesCollection.width, 70);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.gamesCollection.width, 70);
}

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
