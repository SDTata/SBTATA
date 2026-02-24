//
//  AddUSDTInfoCell.m
//  phonelive2
//
//  Created by test on 2022/1/17.
//  Copyright © 2022 toby. All rights reserved.
//

#import "AddUSDTInfoCell.h"
#import "BRPickerViewMacro.h"

#define kLeftMargin 14
#define kRowHeight 50

@interface AddUSDTInfoCell ()
@property (nonatomic, strong) UIImageView *nextImageView;

@end

@implementation AddUSDTInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.nextImageView];
        [self.contentView addSubview:self.textView];
        [self.contentView addSubview:self.placeHolder];
        [self.contentView addSubview:self.lineView];
        [self.contentView addSubview:self.btn_paste];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 调整cell分割线的边距：top, left, bottom, right
    //self.separatorInset = UIEdgeInsetsMake(0, kLeftMargin, 0, kLeftMargin);
    self.titleLabel.frame = CGRectMake(kLeftMargin, 0, 200, kRowHeight);
    self.nextImageView.frame = CGRectMake(self.contentView.bounds.size.width - kLeftMargin - 14, (kRowHeight - 14) / 2, 14, 14);
    self.textField.frame = CGRectMake(self.nextImageView.frame.origin.x - 200, 0, 200, kRowHeight);
    if (self.canEdit) {
        self.nextImageView.hidden = YES;
        self.textView.hidden = NO;
        self.textField.hidden = YES;
        self.btn_paste.hidden = NO;
        self.lineView.hidden = NO;
    } else {
        self.nextImageView.hidden = NO;
        self.textView.hidden = YES;
        self.textField.hidden = NO;
        self.btn_paste.hidden = YES;
        self.lineView.hidden = YES;
    }
}

- (void)doPaste:(UIButton *)sender{
    NSString *pasteString = [UIPasteboard generalPasteboard].string;
    CGRect rect = [pasteString boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 2*kLeftMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0f]} context:nil];
    self.textView.text = pasteString;
    self.textView.frame = CGRectMake(kLeftMargin, kRowHeight, SCREEN_WIDTH - 2*kLeftMargin, rect.size.height + kRowHeight);
    if (self.delegate && [self.delegate respondsToSelector:@selector(doPasteCall:)]) {
        [self.delegate doPasteCall:self];
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        if (@available(iOS 13.0, *)) {
            _titleLabel.textColor = [UIColor blackColor];
        } else {
            _titleLabel.textColor = [UIColor blackColor];
        }
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc]init];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.font = [UIFont systemFontOfSize:16.0f];
        _textField.textAlignment = NSTextAlignmentRight;
        if (@available(iOS 13.0, *)) {
            _textField.textColor = [UIColor blackColor];
        } else {
            _textField.textColor = [UIColor blackColor];
        }
    }
    return _textField;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc]init];
        _textView.frame = CGRectMake(kLeftMargin, kRowHeight, SCREEN_WIDTH - 2*kLeftMargin, 30);
        _textView.backgroundColor = [UIColor clearColor];
        _textView.font = [UIFont systemFontOfSize:16.0f];
        _textView.textAlignment = NSTextAlignmentLeft;
        if (@available(iOS 13.0, *)) {
            _textView.textColor = [UIColor blackColor];
        } else {
            _textView.textColor = [UIColor blackColor];
        }
    }
    return _textView;
}

- (UILabel *)placeHolder{
    if (!_placeHolder) {
        _placeHolder = [[UILabel alloc]init];
        _placeHolder.frame = CGRectMake(kLeftMargin + 5, kRowHeight+5, SCREEN_WIDTH - 2*kLeftMargin, 18);
        _placeHolder.font = [UIFont systemFontOfSize:14.0f];
        _placeHolder.textAlignment = NSTextAlignmentLeft;
        _placeHolder.textColor = [UIColor lightGrayColor];
        _placeHolder.text = YZMsg(@"AddUSDT_PlaceHolder");
    }
    return _placeHolder;
}


- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UITextView alloc]init];
        _lineView.frame = CGRectMake(kLeftMargin, kRowHeight + 30, SCREEN_WIDTH - 2*kLeftMargin, 1);
        _lineView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    return _lineView;
}

- (UIButton *)btn_paste {
    if (!_btn_paste) {
        _btn_paste = [[UIButton alloc]init];
        NSString *pasteTitle = YZMsg(@"AddUSDT_Paste");
        CGRect rect = [pasteTitle boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 2*kLeftMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0f]} context:nil];
        _btn_paste.frame = CGRectMake(SCREEN_WIDTH - kLeftMargin - rect.size.width - 20, 15, rect.size.width + 20, 20);
        _btn_paste.layer.borderColor = [UIColor orangeColor].CGColor;
        _btn_paste.layer.borderWidth = 1.0;
        _btn_paste.layer.masksToBounds = YES;
        _btn_paste.layer.cornerRadius = 10;
        _btn_paste.titleLabel.font = [UIFont systemFontOfSize:14];
        [_btn_paste setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_btn_paste setTitle:pasteTitle forState:UIControlStateNormal];
        [_btn_paste addTarget:self action:@selector(doPaste:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_paste;
}


- (UIImageView *)nextImageView {
    if (!_nextImageView) {
        _nextImageView = [[UIImageView alloc]init];
        _nextImageView.backgroundColor = [UIColor clearColor];
        _nextImageView.image = [UIImage imageNamed:@"icon_next"];
    }
    return _nextImageView;
}

@end
