//
//  AnchorCmdIconView.m
//  phonelive2
//
//  Created by vick on 2025/7/31.
//  Copyright © 2025 toby. All rights reserved.
//

#import "AnchorCmdIconView.h"

@implementation AnchorCmdIconView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UIImageView *iconView = [UIImageView new];
    iconView.layer.masksToBounds = YES;
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    iconView.layer.cornerRadius = 13;
    [self addSubview:iconView];
    self.iconView = iconView;
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    UILabel *nameLabel = [UIView vk_label:nil font:vkFont(14) color:UIColor.whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)setName:(NSString *)name icon:(NSString *)icon {
    if (icon && icon.length > 0) {
        if ([icon containsString:@"/"]) {
            [self.iconView sd_setImageWithURL:[NSURL URLWithString:icon]];
        } else {
            self.iconView.image = [ImageBundle imagewithBundleName:icon];
        }
        self.iconView.backgroundColor = UIColor.clearColor;
        self.nameLabel.hidden = YES;
    } else {
        self.iconView.image = nil;
        self.nameLabel.hidden = NO;
        self.nameLabel.text = [self prefixForString:name];
        switch (name.length % 10) {
            case 1:
                self.iconView.backgroundColor = vkColorHex(0xFB898B);
                break;
            case 2:
                self.iconView.backgroundColor = vkColorHex(0xF8D093);
                break;
            case 3:
                self.iconView.backgroundColor = vkColorHex(0x57DDF9);
                break;
            default:
                self.iconView.backgroundColor = vkColorHex(0xAF8EF7);
                break;
        }
    }
}

- (NSString *)prefixForString:(NSString *)input {
    if (input.length == 0) return @"";

    unichar firstChar = [input characterAtIndex:0];
    
    // 判断是否为中日韩字符（CJK）
    BOOL isCJK = [self isCJKCharacter:firstChar];
    
    if (isCJK) {
        return [input substringToIndex:MIN(1, input.length)];
    } else {
        return [input substringToIndex:MIN(2, input.length)];
    }
}

- (BOOL)isCJKCharacter:(unichar)ch {
    // 常用的中日韩字符 Unicode 范围
    return (ch >= 0x4E00 && ch <= 0x9FFF)   || // 中日常用汉字
           (ch >= 0x3040 && ch <= 0x309F)   || // 日文平假名
           (ch >= 0x30A0 && ch <= 0x30FF)   || // 日文片假名
           (ch >= 0xAC00 && ch <= 0xD7AF);     // 韩文音节
}

@end
