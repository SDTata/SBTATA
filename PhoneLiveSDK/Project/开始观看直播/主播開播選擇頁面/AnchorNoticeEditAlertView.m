//
//  AnchorNoticeEditAlertView.m
//  phonelive2
//
//  Created by vick on 2025/7/21.
//  Copyright © 2025 toby. All rights reserved.
//

#import "AnchorNoticeEditAlertView.h"
#import "UITextView+JKPlaceHolder.h"
#import "UITextView+JKInputLimit.h"
#import "VKButton.h"

@interface AnchorNoticeEditAlertView () <UITextViewDelegate>

@property (nonatomic, strong) UISwitch *openButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) VKButton *timeButton;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, copy) NSString *selectTime;

@end

@implementation AnchorNoticeEditAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        
        self.textView.text = [common getAnchorNoticeText];
        if (self.textView.text.length <= 0) {
            self.textView.jk_placeHolderTextView.hidden = NO;
        } else {
            self.textView.jk_placeHolderTextView.hidden = YES;
        }
        [self textViewDidChange:self.textView];
        
        NSString *time = [common getAnchorNoticeTime] ?: @"60";
        self.selectTime = time;
        [self.timeButton setTitle:[NSString stringWithFormat:@"%@秒", time] forState:UIControlStateNormal];
        
        self.openButton.on = [common getAnchorNoticeSwitch];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = UIColor.whiteColor;
    [self corner:VKCornerMaskTop radius:14];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VK_SCREEN_W);
    }];
    
    UILabel *titleLabel = [UIView vk_label:@"主播公告设置" font:vkFontMedium(16) color:vkColorHex(0x111118)];
    titleLabel.backgroundColor = vkColorHexA(0x919191, 0.08);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    UILabel *openTitleLabel = [UIView vk_label:@"直播公告开关" font:vkFontMedium(12) color:vkColorHex(0x111118)];
    [self addSubview:openTitleLabel];
    [openTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(22);
    }];
    
    UISwitch *openButton = [UISwitch new];
    openButton.onTintColor = vkColorHex(0xFF63AC);
    [openButton addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:openButton];
    self.openButton = openButton;
    [openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.centerY.mas_equalTo(openTitleLabel.mas_centerY);
    }];
    
    UILabel *openDetailLabel = [UIView vk_label:@"主播公告仅主播本人可设置，官方后台可查看，修改或删除违规内容。主播公告设置不会影响正常开播流程。" font:vkFont(10) color:vkColorHex(0x919191)];
    openDetailLabel.numberOfLines = 0;
    [self addSubview:openDetailLabel];
    [openDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(openTitleLabel.mas_bottom).offset(22);
    }];
    
    UIView *inputBackView = [UIView new];
    [inputBackView vk_border:nil cornerRadius:5];
    inputBackView.backgroundColor = vkColorHexA(0x919191, 0.15);
    [self addSubview:inputBackView];
    [inputBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(openDetailLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(150);
    }];
    {
        UITextView *textView = [UITextView new];
        textView.backgroundColor = UIColor.clearColor;
        textView.textColor = UIColor.blackColor;
        textView.font = vkFont(12);
        [textView jk_addPlaceHolder:@"请输入您要展示的公告内容(限30字)"];
        textView.jk_maxLength = 30;
        textView.delegate = self;
        [inputBackView addSubview:textView];
        self.textView = textView;
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.right.mas_equalTo(-14);
            make.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-32);
        }];
        
        UILabel *countLabel = [UIView vk_label:@"0/30" font:vkFont(12) color:vkColorHex(0x919191)];
        [inputBackView addSubview:countLabel];
        self.countLabel = countLabel;
        [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-14);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(32);
        }];
    }
    
    UIView *timeBackView = [UIView new];
    [timeBackView vk_border:nil cornerRadius:5];
    timeBackView.backgroundColor = vkColorHexA(0x919191, 0.15);
    [self addSubview:timeBackView];
    [timeBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(inputBackView.mas_bottom).offset(14);
        make.height.mas_equalTo(32);
    }];
    {
        UILabel *timeTitleLabel = [UIView vk_label:@"展示间隔时间" font:vkFont(12) color:vkColorHex(0x919191)];
        [timeBackView addSubview:timeTitleLabel];
        [timeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.centerY.mas_equalTo(0);
        }];
        
        VKButton *timeButton = [VKButton buttonWithType:UIButtonTypeCustom];
        [timeButton vk_button:@"60秒" image:@"live_arrow_black" font:vkFont(12) color:vkColorHex(0x111118)];
        timeButton.imageSize = CGSizeMake(10, 10);
        timeButton.imagePosition = VKButtonImagePositionRight;
        [timeButton vk_addTapAction:self selector:@selector(clickTimeAction:)];
        [timeBackView addSubview:timeButton];
        self.timeButton = timeButton;
        [timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-14);
            make.centerY.mas_equalTo(timeTitleLabel.mas_centerY);
        }];
    }
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton vk_button:@"保存设置" image:nil font:vkFontMedium(16) color:UIColor.whiteColor];
    [saveButton vk_border:nil cornerRadius:23];
    [saveButton vk_addTapAction:self selector:@selector(clickSaveAction)];
    [self addSubview:saveButton];
    self.saveButton = saveButton;
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.height.mas_equalTo(46);
        make.bottom.mas_equalTo(-VK_BOTTOM_H-12);
        make.top.mas_equalTo(timeBackView.mas_bottom).offset(30);
    }];
}

- (void)clickSaveAction {
    [common saveAnchorNoticeText:self.textView.text];
    [common saveAnchorNoticeTime:self.selectTime];
    [self hideAlert:nil];
}

- (void)clickTimeAction:(UIButton *)sender {
    [self.textView resignFirstResponder];
    NSArray *titles = @[@"30秒", @"60秒", @"120秒"];
    NSArray *values = @[@"30", @"60", @"120"];
    [YBPopupMenu showMenu:sender style:VKPopupMenuNormal width:140 titles:titles icons:nil block:^(NSInteger index) {
        [self.timeButton setTitle:titles[index] forState:UIControlStateNormal];
        self.selectTime = values[index];
    }];
}

- (void)switchValueChanged:(UISwitch *)sender {
    [common saveAnchorNoticeSwitch:sender.isOn];
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length <= 30) {
        self.countLabel.text = [NSString stringWithFormat:@"%ld/30", textView.text.length];
    }
    if (textView.text.length > 0) {
        self.saveButton.enabled = YES;
        self.saveButton.horizontalColors = @[vkColorHex(0xFF838E), vkColorHex(0xFF63AC)];
    } else {
        self.saveButton.enabled = NO;
        self.saveButton.backgroundColor = vkColorHexA(0x919191, 0.2);
    }
}

@end
