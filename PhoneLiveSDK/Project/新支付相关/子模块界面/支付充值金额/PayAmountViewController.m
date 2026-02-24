//
//  PayAmountViewController.m
//
//

#import "PayAmountViewController.h"
#import "PayAmountCollectionViewCell.h"
#import <UMCommon/UMCommon.h>


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kPayAmountCollectionViewCell @"PayAmountCollectionViewCell"
#define kImageDefaultName @"tempShop2"

@interface PayAmountViewController (){
    NSMutableDictionary *allData;
    BOOL bUICreated; // UI是否创建
    NSIndexPath *curselectIndex;
    NSString *lastAmountString;
    
    
    NSInteger discount_type;
    CGFloat discount_each_base;
    NSString *discount_each_give;
    CGFloat discount_maxamount;
    NSString *discount_rate;
    NSString *exchange_rate;
    
    
    NSString *beforeEditAmount;
    UITextField *curForceTextField;
    NSString *current_unit;
    
    
    NSString *damaStr ;
}

@property (weak, nonatomic) IBOutlet UILabel *chargeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *curenyLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeTitle2Label;
@property (weak, nonatomic) IBOutlet UIImageView *diamondImageView;

@end

@implementation PayAmountViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFeildDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFeildChange) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)textFeildDidBeginEditing:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[UITextField class]]) {
        UITextField *textField = notification.object;
        curForceTextField = textField;
    } else if ([notification.object isKindOfClass:[UITextView class]]) {
//        UITextView *textView = notification.object;
        // Do something with text view
    }
}
-(void)updateDataBalance:(NSNotification *)notification
{
    NSArray *arr = (notification.userInfo[@"subContent"]);
    NSInteger maxCount = arr.count;
    for (int i=0; i<maxCount; i++) {
        if([minstr(arr[i][@"type"]) isEqualToString:@"balance"]){
            NSDictionary *contentDict = arr[i][@"content"];
            if(contentDict && contentDict[@"balance"]){
                self.vippayCoinLab.text = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%@",contentDict[@"balance"]] showUnit:YES];
                break;
            }
        }
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.gamesCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSelectPayChannel:) name:@"Pay_RefreshPayChannel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataBalance:) name:@"Pay_UpdateBalance" object:nil];
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
   
    
    self.chargeTitleLabel.text = YZMsg(@"PayAmount_chargeTitle");
    self.chargeTitle2Label.text = YZMsg(@"chargeMoney2");
    self.amountValueTextField.placeholder = YZMsg(@"PayAmount_input_charge_amount");
   
    self.discountCalcLabel.adjustsFontSizeToFitWidth= YES;
    self.discountCalcLabel.minimumScaleFactor= 0.3;
    [self refreshUI];
    
    //    });
}


- (void)keyboardWillShow:(NSNotification *)notification {
    //获取键盘高度，在不同设备上，以及中英文下是不同的
//    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    if(curForceTextField == self.amountValueTextField){
        beforeEditAmount = self.amountValueTextField.text;
        self.amountValueTextField.text = @"";
    }
}

- (void)keyboardWillHide:(NSNotification *)notify {
    if(curForceTextField){
        if(self.amountValueTextField.text.length == 0){
            self.amountValueTextField.text = beforeEditAmount;
        }
        curForceTextField = nil;
    }
}

- (void)refreshSelectPayChannel:(NSNotification *)notification {
    NSArray *arr = (notification.userInfo[@"subContent"]);
    NSInteger maxCount = arr.count;
    for (int i=0; i<maxCount; i++) {
        if([minstr(arr[i][@"type"]) isEqualToString:@"channelClass"]){
            self.currentViewType = [arr[i][@"viewType"]  intValue];
        }
    }
    
    for (int i=0; i<maxCount; i++) {
        if([minstr(arr[i][@"type"]) isEqualToString:@"chosseAmountClass"]||[minstr(arr[i][@"type"]) isEqualToString:@"chosseAmountRateGiveClass"]){
            NSDictionary *contentDict = arr[i][@"content"];
            if(contentDict && contentDict[@"quick_amount"]){
                allData = [NSMutableDictionary dictionaryWithDictionary:contentDict];
            }
        }
        if([minstr(arr[i][@"type"]) isEqualToString:@"channelClass"]){
            NSDictionary *contentDict = arr[i][@"content"];
            
            
            if(self.currentViewType ==5 || self.currentViewType ==6){
                self.vippayCoinLab.hidden = NO;
                self.vippayNameLab.hidden = NO;
                if (self.currentViewType ==6) {
                    self.vippayNameLab.text = YZMsg(@"PayVC_ChargeAmount");
                }
            }else{
                self.vippayCoinLab.hidden = YES;
                self.vippayNameLab.hidden = YES;
            }
            if(contentDict){
                discount_type = [contentDict[@"discount_type"] integerValue];
                discount_each_base = [contentDict[@"discount_each_base"] floatValue];
                discount_each_give = contentDict[@"discount_each_give"];
                discount_maxamount = [contentDict[@"discount_maxamount"] floatValue];
                discount_rate = contentDict[@"discount_rate"];
                exchange_rate = contentDict[@"exchange_rate"];
                current_unit = [NSString stringWithFormat:@"%@",contentDict[@"curreny_unit"]];
                if (self.currentViewType == 6) {
//                    self.diamondImageView.image = [ImageBundle imagewithBundleName:@"yfks_zs"];
//                    self.diamondImageView.hidden = false;
                    self.diamondImageView.hidden = true;
                    self.symbolLabel.text = [Config getRegionCurrenyChar];
                } else {
                    self.diamondImageView.hidden = true;
                    self.symbolLabel.text = current_unit;
//                    if (![PublicObj checkNull:current_unit]) {
//                        self.symbolLabel.text = current_unit;
//                    }else{
//                        self.symbolLabel.text = @"";
//                    }
                }
            }
        }
        if([minstr(arr[i][@"type"]) isEqualToString:@"balance"] && self.currentViewType == 5){
            NSDictionary *contentDict = arr[i][@"content"];
            if(contentDict && contentDict[@"balance"]){
                self.vippayCoinLab.text = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%@",contentDict[@"balance"]] showUnit:YES];
                self.vippayNameLab.text = YZMsg(@"myWithdrawVC2_Account_Balance2");
            }
        }
        
        if([minstr(arr[i][@"type"]) isEqualToString:@"needFlow"] && self.currentViewType == 6){
            NSDictionary *contentDict = arr[i][@"content"];
            if(contentDict && contentDict[@"flow"]){
                damaStr = [NSString stringWithFormat:@"%@",contentDict[@"flow"]];
               
            }
        }
        
    }
    
    if(allData){
        NSInteger bOpenCustom = [allData[@"openCustom"] integerValue];
        if(bOpenCustom){
            self.amountView.hidden = NO;
            self.customAmountHeight.constant = 50;
        }else{
            self.amountView.hidden = YES;
            self.customAmountHeight.constant = 0;
        }
        
        NSArray *amountRange = allData[@"amountRange"];
        if(amountRange && amountRange.count>1){
            self.amountRangeLabel.text = [NSString stringWithFormat:YZMsg(@"PayAmount_Range_%@%@_%@%@"), amountRange[0] ,current_unit,amountRange[1] ,current_unit];
            self.amountValueTextField.placeholder = [NSString stringWithFormat:@"%@-%@", amountRange[0] ,amountRange[1]];
        }
        
        NSArray *quick_amount = allData[@"quick_amount"];
        NSString *tip = allData[@"tip"];
        CGFloat tipHeight = 0;
        if(tip && ![tip isKindOfClass:[NSNull class]] && tip.length > 0){
            self.tipLabel.text = minstr(tip);
            self.tipLabel.hidden = NO;
            tipHeight = [self.tipLabel.text boundingRectWithSize:CGSizeMake(self.contentView.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYS_Font(11)} context:nil].size.height;
        }else{
            self.tipLabel.text = @"";
            self.tipLabel.hidden = YES;
        }
        
        if(discount_type == 0){
            self.discountView.hidden = YES;
            self.discountViewHeight.constant = 0;
            [self.curenyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-8);
            }];
        }else{
            self.discountView.hidden = NO;
            self.discountViewHeight.constant = 35;
            if(discount_type == 1){
                self.discountDescLabel.text = [NSString stringWithFormat:YZMsg(@"PayAmount_giftRule1_%@%.1f_%@%.1f_%@%.1f"), current_unit, discount_each_base, current_unit, discount_each_give.doubleValue, current_unit, discount_maxamount];
            }else if (discount_type == 2){
                self.discountDescLabel.text = [NSString stringWithFormat:YZMsg(@"PayAmount_giftRule2_%.2f_%@%.1f"), [discount_rate doubleValue],current_unit,discount_maxamount];
            }
            [self.discountView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view.mas_bottom).offset(-4);
            }];
        }
        
        NSInteger topHeight = 0;
        NSInteger LineSpacing = 5.f;
        double fLineCount = quick_amount.count / 4.0;
        NSInteger iLineCount = ceil(fLineCount);
        self.viewHeight.constant = iLineCount * (35 + LineSpacing) + topHeight + LineSpacing + 55 + tipHeight + self.discountViewHeight.constant + self.customAmountHeight.constant + 30;

        self.view.height = self.viewHeight.constant;
        
        [self.gamesCollection reloadData];

    }
    
    [self updateCurrenyLabel];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
}
-(void)updateCurrenyLabel{
    
   
    if (self.currentViewType == 6) {
        
        NSArray *quick_amount = allData[@"quick_amount"];
        
        for (NSInteger i = (quick_amount.count-1); i>=0; i--) {
            NSDictionary *subDic = quick_amount[i];
            if ([subDic isKindOfClass:[NSDictionary class]]) {
                NSString *title = [NSString stringWithFormat:@"%@",subDic[@"title"]];
                if (title && [title floatValue]>0.00) {
                    if ([self.amountValueTextField.text floatValue]>=[title floatValue]) {
                        NSString *give_rate = [NSString stringWithFormat:@"%@",subDic[@"give_rate"]];
                        
                        NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:give_rate];
                       
                        NSDecimalNumberHandler*roundDown = [NSDecimalNumberHandler
                                                          decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                          scale:2
                                                          raiseOnExactness:NO
                                                          raiseOnOverflow:NO
                                                          raiseOnUnderflow:NO
                                                          raiseOnDivideByZero:YES];
                        NSDecimalNumber *numberOrig = [NSDecimalNumber decimalNumberWithString:self.amountValueTextField.text];
                        
                        NSDecimalNumber *numberByMultiplying= [numberOrig decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
                        
                        NSDecimalNumber *numberByMultiplying1= [[NSDecimalNumber decimalNumberWithString:title] decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
                        
                        NSDecimalNumber *amountDecimal = [numberByMultiplying decimalNumberByAdding:numberOrig withBehavior:roundDown];
                       
                        NSString *calculateN = [NSString stringWithFormat:@"%.2f",amountDecimal.floatValue];
                        
                       
                        NSString *resultStr=  [NSString stringWithFormat:YZMsg(@"curreny_unit_alert_charge"), [PublicObj removeFloatAllZero:calculateN], [common name_coin]];
                        
                        self.discountDescLabel.text = [NSString stringWithFormat:YZMsg(@"PayAmount_giftRule3_%@%@_%@%@"), @"", [YBToolClass getRateCurrency:title showUnit:YES], @"", [YBToolClass getRateCurrency:numberByMultiplying1.stringValue showUnit:YES]];
                        self.discountCalcLabel.text = [NSString stringWithFormat:YZMsg(@"PayAmount_giftRule3%@%@"), @"", [YBToolClass getRateCurrency:numberByMultiplying.stringValue showUnit:YES]];
                        
                        if (damaStr && damaStr.length>0) {
                            NSDecimalNumber *numb = [NSDecimalNumber decimalNumberWithString:damaStr];
                            if (numb.doubleValue>0) {
                                resultStr = [NSString stringWithFormat:YZMsg(@"ChargeNumberTip%@"), [YBToolClass getRateCurrency:damaStr showUnit:YES]];
                                self.discountCalcLabel.text = [NSString stringWithFormat:YZMsg(@"PayAmount_giftRule3%@%@"),@"", [YBToolClass getRateCurrency:@"0" showUnit:YES]];
                            }
                        }
                        
                        self.curenyLabel.text = resultStr;
                        break;
                        
                    }
                }
                
            }
        }
        
        
    }else{
        NSDecimalNumber *decimalExchange_rate = [NSDecimalNumber decimalNumberWithString:exchange_rate];
        NSDecimalNumber *rateNumber = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
        NSDecimalNumberHandler*roundDown = [NSDecimalNumberHandler
                                          decimalNumberHandlerWithRoundingMode:NSRoundDown
                                          scale:2
                                          raiseOnExactness:NO
                                          raiseOnOverflow:NO
                                          raiseOnUnderflow:NO
                                          raiseOnDivideByZero:YES];
        NSDecimalNumber *amountDecimal = [[NSDecimalNumber decimalNumberWithString:self.amountValueTextField.text] decimalNumberByDividingBy:decimalExchange_rate withBehavior:roundDown];
        NSDecimalNumber *rate = [rateNumber decimalNumberByDividingBy:decimalExchange_rate withBehavior:roundDown];
        NSString *calculateN = [NSString stringWithFormat:@"%.2f",amountDecimal.floatValue];
        NSString *money = [NSString stringWithFormat:@"%@", [YBToolClass getRateCurrency:calculateN showUnit:YES]];
        NSString *resultStr=  [NSString stringWithFormat:YZMsg(@"curreny_unit_alert"), money, @"", [@"1:" stringByAppendingFormat:@"%@", [PublicObj removeFloatAllZero:rate.stringValue]]];
        self.curenyLabel.text = resultStr;
       
        
    }
    
}


-(void)refreshDiscount{
    if(discount_type == 0){
        self.discountView.hidden = YES;
        return;
    }else{
        self.discountView.hidden = NO;
        if(discount_type == 1){
            NSInteger chargeMoney = [self.amountValueTextField.text integerValue];
            NSInteger discountGiveScale = floor(chargeMoney / discount_each_base);
            CGFloat discountMoney = discountGiveScale * [discount_each_give doubleValue];
            if(discountMoney > discount_maxamount){
                discountMoney = discount_maxamount;
            }
            self.discountCalcLabel.text = [NSString stringWithFormat:YZMsg(@"PayAmount_giftRule3%@%@"), @"", [YBToolClass getRateCurrency:@(discountMoney).stringValue showUnit:YES]];
        }else if (discount_type == 2){
            NSInteger chargeMoney = [self.amountValueTextField.text integerValue];
            CGFloat discountMoney = chargeMoney * [discount_rate doubleValue] / 100;
            self.discountCalcLabel.text = [NSString stringWithFormat:YZMsg(@"PayAmount_giftRule3%@%@"), @"", [YBToolClass getRateCurrency:@(discountMoney).stringValue showUnit:YES]];
        }
    }
}

-(NSDictionary *)getRequestParams{
    NSString *money = self.amountValueTextField.text;
    return @{@"money": money};
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:YZMsg(@"public_cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:YZMsg(@"publictool_sure") style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    self.amountValueTextField.inputAccessoryView = numberToolbar;
    self.amountValueTextField.delegate = self;
}

-(void)cancelNumberPad{
    [self.amountValueTextField resignFirstResponder];
    [self.view endEditing:YES];
}

-(void)doneWithNumberPad{
    [self.amountValueTextField resignFirstResponder];
    [self.view endEditing:YES];
}

-(NSArray *)getRequireKeys{
    return @[@"amount"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField == self.amountValueTextField){
        NSInteger amountValue = [self.amountValueTextField.text integerValue];
        NSArray *amountRange = allData[@"amountRange"];
        if(amountValue < [amountRange[0] floatValue] || amountValue > [amountRange[1] floatValue]){
            NSArray *quick_amount = allData[@"quick_amount"];
            if(quick_amount.count == 0){
                self.amountValueTextField.text = [NSString stringWithFormat:@"%.2f",[amountRange[0] floatValue]];
            }
            [MBProgressHUD showError:[NSString stringWithFormat:YZMsg(@"PayAmount_Range_%@%@_%@%@"), amountRange[0],current_unit ,amountRange[1],current_unit]];
            if (amountValue < [amountRange[0] floatValue]) {
                self.amountValueTextField.text = [NSString stringWithFormat:@"%@",amountRange[0]];
            }
            if (amountValue>[amountRange[1] floatValue]) {
                self.amountValueTextField.text = [NSString stringWithFormat:@"%@",amountRange[1]];
            }
        }
        
//        if (!self.vippayCoinLab.hidden && self.vippayCoinLab.text>0 && amountValue>[self.vippayCoinLab.text doubleValue]) {
//            self.amountValueTextField.text = self.vippayCoinLab.text;
//        }
    }
    [self updateCurrenyLabel];
}

-(void)textFeildChange {
    if( ![self.amountValueTextField.text isEqualToString:minstr(lastAmountString)] ){
        lastAmountString = self.amountValueTextField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_TextFieldChange" object:nil userInfo:@{@"amount" : self.amountValueTextField.text}];
        [self refreshDiscount];
        [self updateCurrenyLabel];
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

    UINib *nib=[UINib nibWithNibName:kPayAmountCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [self.gamesCollection registerNib: nib forCellWithReuseIdentifier:kPayAmountCollectionViewCell];

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
    NSArray *quick_amount = allData[@"quick_amount"];
    if (quick_amount.count==0) {
        return 0;
    }
    return quick_amount.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.parentViewController.view endEditing:YES];
    NSIndexPath * lastIndexPath = curselectIndex;
    curselectIndex = indexPath;
    if ([curselectIndex length] == 2) {
        [collectionView reloadItemsAtIndexPaths:@[lastIndexPath]];
    }
    [collectionView reloadItemsAtIndexPaths:@[curselectIndex]];
    [self updateCurrenyLabel];
    [MobClick event:@"mine_charge_click" attributes:@{ @"eventType": @(1)}];
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PayAmountCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kPayAmountCollectionViewCell forIndexPath:indexPath];
    NSArray *quick_amount = allData[@"quick_amount"];
    NSDictionary *dict = [quick_amount objectAtIndex:indexPath.row];

    NSString *text = minstr(dict[@"title"]);
    
    if (self.currentViewType == 6) {
        cell.title.text = [YBToolClass getRateCurrency:text showUnit:YES];
    } else {
        cell.title.text = [NSString stringWithFormat:@"%@%@", current_unit, text];
    }

    NSString *subTitle = minstr(dict[@"subTitle"]);

    if(!subTitle || [subTitle isKindOfClass:[NSNull class]] || !subTitle.length){
        cell.subTitle.hidden = YES;
        cell.heightSubLabelConstraint.constant = 0;
    }else{
        cell.heightSubLabelConstraint.constant = 15;
        cell.subTitle.text = minstr(dict[@"subTitle"]);
        cell.subTitle.hidden = NO;
    }
    
    if(curselectIndex.row == indexPath.row){
        [cell setSelectedStatus:true];
        if (self.currentViewType == 6) {
            self.amountValueTextField.text = [YBToolClass getRateCurrencyWithoutK:text];
        } else {
            self.amountValueTextField.text = text;
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_TextFieldChange" object:nil userInfo:@{@"amount" : self.amountValueTextField.text}];
        [self refreshDiscount];
        [self updateCurrenyLabel];
    }else{
        [cell setSelectedStatus:false];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    return CGSizeMake((self.gamesCollection.width -15)/4, 35);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.gamesCollection.width -15)/4, 35);
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
