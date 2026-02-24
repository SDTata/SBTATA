//
//  PayPwdAlertView.m
//  phonelive2
//
//  Created by vick on 2024/8/14.
//  Copyright © 2024 toby. All rights reserved.
//

#import "PayPwdAlertView.h"
#import "CRBoxInputView.h"

@interface PayPwdAlertView ()

@property (nonatomic, strong) CRBoxInputView *boxInputView;

@end

@implementation PayPwdAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (CRBoxInputView *)boxInputView {
    if (!_boxInputView) {
        CRBoxInputCellProperty *cellProperty = [[CRBoxInputCellProperty alloc] init];
        cellProperty.cellBgColorNormal = UIColor.whiteColor;
        cellProperty.cellBgColorSelected = UIColor.whiteColor;
        cellProperty.cellFont = vkFontBold(20);
        cellProperty.cellTextColor = UIColor.blackColor;
        cellProperty.cornerRadius = 0;
        cellProperty.borderWidth = 0.5;
        cellProperty.cellBorderColorNormal = UIColor.lightGrayColor;
        cellProperty.cellBorderColorSelected = UIColor.lightGrayColor;
        
        CRBoxInputView *inputView = [CRBoxInputView new];
        inputView.layer.cornerRadius = 5;
        inputView.layer.borderColor = UIColor.lightGrayColor.CGColor;
        inputView.layer.borderWidth = 0.5;
        inputView.layer.masksToBounds = YES;
        inputView.codeLength = 6;
        inputView.boxFlowLayout.minimumLineSpacing = 0;
        inputView.boxFlowLayout.minimumInteritemSpacing = 0;
        inputView.boxFlowLayout.ifNeedEqualGap = NO;
        inputView.ifNeedSecurity = YES;
        inputView.ifNeedCursor = NO;
        inputView.customCellProperty = cellProperty;
        [inputView loadAndPrepareViewWithBeginEdit:YES];
        
        __weak typeof(self) weakSelf = self;
        inputView.textDidChangeblock = ^(NSString *text, BOOL isFinished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (isFinished) {
                [strongSelf hideAlert:nil];
                if (strongSelf.clickConfirmBlock) {
                    strongSelf.clickConfirmBlock(text);
                }
            }
        };
        
        _boxInputView = inputView;
    }
    return _boxInputView;
}

- (void)setupView {
    self.backgroundColor = UIColor.whiteColor;
    [self vk_border:nil cornerRadius:10];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(220);
    }];
    
    UIButton *closeButton = [UIView vk_buttonImage:@"close" selected:nil];
    [closeButton vk_addTapAction:self selector:@selector(clickCancelAction)];
    closeButton.contentEdgeInsets = UIEdgeInsetsMake(13, 13, 13, 13);
    [self addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(40);
    }];
    
    UILabel *titleLabel = [UIView vk_label:YZMsg(@"PayVC_PwdAlertTitle") font:vkFont(16) color:UIColor.blackColor];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(60);
    }];
    
//    UITextField *textField = [UITextField new];
//    textField.font = vkFont(14);
//    textField.textColor = UIColor.blackColor;
//    textField.textAlignment = NSTextAlignmentCenter;
//    textField.keyboardType = UIKeyboardTypeASCIICapable;
//    textField.secureTextEntry = YES;
//    textField.placeholder = YZMsg(@"PayVC_PwdAlertTip");
//    [textField vk_border:UIColor.lightGrayColor cornerRadius:20];
//    [self addSubview:textField];
//    self.textField = textField;
//    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(20);
//        make.right.mas_equalTo(-20);
//        make.top.mas_equalTo(titleLabel.mas_bottom).offset(20);
//        make.height.mas_equalTo(40);
//    }];
    
    [self addSubview:self.boxInputView];
    [self.boxInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(252);
        make.height.mas_equalTo(47);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(30);
    }];
    
//    UIButton *cancelButton = [UIView vk_button:YZMsg(@"public_cancel") image:nil font:vkFont(16) color:UIColor.systemPurpleColor];
//    [cancelButton vk_border:UIColor.systemPurpleColor cornerRadius:20];
//    [cancelButton vk_addTapAction:self selector:@selector(clickCancelAction)];
//    [self addSubview:cancelButton];
//    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(20);
//        make.bottom.mas_equalTo(-20);
//        make.height.mas_equalTo(40);
//        make.top.mas_equalTo(textField.mas_bottom).offset(30);
//    }];
//    
//    UIButton *confirmButton = [UIView vk_button:YZMsg(@"publictool_sure") image:nil font:vkFont(16) color:UIColor.whiteColor];
//    [confirmButton vk_border:nil cornerRadius:20];
//    confirmButton.backgroundColor = UIColor.systemPurpleColor;
//    [confirmButton vk_addTapAction:self selector:@selector(clickConfirmAction)];
//    [self addSubview:confirmButton];
//    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-20);
//        make.left.mas_equalTo(cancelButton.mas_right).offset(20);
//        make.height.width.bottom.mas_equalTo(cancelButton);
//    }];
}

- (void)clickCancelAction {
    [self hideAlert:nil];
}

- (void)clickConfirmAction {
//    if (self.textField.text.length <= 0) {
//        [MBProgressHUD showError:self.textField.placeholder toView:self];
//        return;
//    }
//    [self hideAlert:nil];
//    if (self.clickConfirmBlock) {
//        self.clickConfirmBlock(self.textField.text);
//    }
}

@end
