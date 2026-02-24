//
//  PayTransferViewController.m
//
//

#import "PayTransferViewController.h"
#import "PayTransferCollectionViewCell.h"


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kPayTransferCollectionViewCell @"PayTransferCollectionViewCell"
#define kImageDefaultName @"tempShop2"

@interface PayTransferViewController (){
    NSMutableDictionary *allData;
    BOOL bUICreated; // UI是否创建
    NSIndexPath *curselectIndex;
    NSString *lastNameString;
}
@property (weak, nonatomic) IBOutlet UILabel *moneyTitleName;

@property (weak, nonatomic) IBOutlet UILabel *leaveMsgLabel;

@end

@implementation PayTransferViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFeildChange) name:UITextFieldTextDidChangeNotification object:nil];
}


- (void)refreshSelectPayChannel:(NSNotification *)notification {
    NSArray *arr = (notification.userInfo[@"subContent"]);
    NSInteger maxCount = arr.count;
    
    
    for (int i=0; i<maxCount; i++) {
        if([minstr(arr[i][@"type"]) isEqualToString:@"transferClass"]){
            NSDictionary *contentDict = arr[i][@"content"];
            allData = [NSMutableDictionary dictionaryWithDictionary:contentDict];
            break;
        }
    }
    
    if(allData){
        NSString *tip = allData[@"tip"];
        // tip = @"我司入款银行卡不定期更换，请勿保存银行卡号转账,存款请进入【银行卡转账】页面复制最新的卡号转账\n1\n2\n3\n4\n5";
        self.tipLabel.text = minstr(tip);
        
        CGFloat tipHeight = 0;
        if(tip && ![tip isKindOfClass:[NSNull class]] && tip.length > 0){
            tipHeight = [self.tipLabel.text boundingRectWithSize:CGSizeMake(self.contentView.width - 40, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYS_Font(12)} context:nil].size.height + 6;
            self.tipView.hidden = NO;
        }else{
            self.tipView.hidden = YES;
            [self.tipView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            [self.gamesCollection mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view.mas_bottom).offset(-2);
            }];
        }
        
        
        NSArray *list = allData[@"list"];
        NSInteger topHeight = 5;
        NSInteger LineSpacing = 5.f;
        double fLineCount = list.count / 1.0;
        NSInteger iLineCount = ceil(fLineCount);
        self.viewHeight.constant = iLineCount * (150 + LineSpacing) + topHeight + LineSpacing + 116 + tipHeight;
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

-(NSDictionary *)getRequestParams{
    return @{@"name" : self.transferNameTextField.text, @"msg" : self.transferDescTextField.text};
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
    self.moneyTitleName.text = YZMsg(@"Transfer_nameTitle");
    self.leaveMsgLabel.text = YZMsg(@"Transfer_leaveMsg");
    self.transferNameTextField.placeholder = YZMsg(@"Transfer_nameplaceholder");
    self.transferNameTextField.placeholder = YZMsg(@"Transfer_nameplaceholder");
    self.transferDescTextField.placeholder = YZMsg(@"Transfer_optionalplaceholder");
    
//    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshUI];
//    });
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
}
-(void)setData:(NSArray *)dict{
//    self.gamesCollection.hidden = YES;
//    allData = dict;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self refreshUI];
//    });
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
    // 初始化投注选项
    [self initCollection];
    
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:YZMsg(@"public_cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelWithKeyBoard)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:YZMsg(@"publictool_sure") style:UIBarButtonItemStyleDone target:self action:@selector(doneWithKeyBoard)]];
    [keyboardToolbar sizeToFit];
    self.transferNameTextField.inputAccessoryView = keyboardToolbar;
    self.transferDescTextField.inputAccessoryView = keyboardToolbar;
    
    self.transferNameTextField.delegate = self;
    // 给转账人设置默认值
    self.transferNameTextField.text = [common getTransferName];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf textFeildChange];
    });
}

-(void)cancelWithKeyBoard{
    [self.transferNameTextField resignFirstResponder];
    [self.transferDescTextField resignFirstResponder];
}

-(void)doneWithKeyBoard{
    [self.transferNameTextField resignFirstResponder];
    [self.transferDescTextField resignFirstResponder];
}

-(NSArray *)getRequireKeys{
    return @[@"name"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField == self.transferNameTextField){
        [common saveTransferName:self.transferNameTextField.text];
    }
}

-(void)textFeildChange {
    if( ![self.transferNameTextField.text isEqualToString:minstr(lastNameString)] ){
        lastNameString = self.transferNameTextField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_TextFieldChange" object:nil userInfo:@{@"name" : self.transferNameTextField.text}];
    }
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
    flowLayout.minimumLineSpacing = 5.f;
    
    self.gamesCollection.delegate = self;
    self.gamesCollection.dataSource = self;
    self.gamesCollection.collectionViewLayout = flowLayout;
    self.gamesCollection.allowsMultipleSelection = YES;

    UINib *nib=[UINib nibWithNibName:kPayTransferCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [self.gamesCollection registerNib: nib forCellWithReuseIdentifier:kPayTransferCollectionViewCell];

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
    NSArray *list = allData[@"list"];
    if (list.count==0) {
        return 0;
    }
    return list.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.parentViewController.view endEditing:YES];
    NSIndexPath * lastIndexPath = curselectIndex;
    curselectIndex = indexPath;
    if ([curselectIndex length] == 2) {
        [collectionView reloadItemsAtIndexPaths:@[lastIndexPath]];
    }
    [collectionView reloadItemsAtIndexPaths:@[curselectIndex]];
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PayTransferCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kPayTransferCollectionViewCell forIndexPath:indexPath];
    NSArray *list = allData[@"list"];
    NSDictionary *dict = [list objectAtIndex:indexPath.row];

    cell.bankNumLabel.text = minstr(dict[@"bankNum"]);
    cell.bankOwnLabel.text = minstr(dict[@"bankOwn"]);
    cell.bankNameLabel.text = minstr(dict[@"bankName"]);
    cell.bankGateLabel.text = minstr(dict[@"bankGate"]);
    
//    if(curselectIndex.row == indexPath.row){
//        [cell setSelectedStatus:true];
//        self.amountValueTextField.text = cell.title.text;
//        //[[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_SelectChannel" object:nil userInfo:@{@"selectIndex":[NSString stringWithFormat:@"%ld", indexPath.row]}];
//    }else{
//        [cell setSelectedStatus:false];
//    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    return CGSizeMake(self.gamesCollection.width, 150);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.gamesCollection.width, 150);
}

//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(0, 10, 0, 10);
//}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={kScreenWidth, 5};
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
