//
//  RemoteControllerCell.m
//  phonelive2
//
//  Created by s5346 on 2023/12/4.
//  Copyright © 2023 toby. All rights reserved.
//

#import "RemoteControllerCell.h"

typedef NS_ENUM(NSUInteger, CellType) {
    CellTypeForOrder, // 主播指令
    CellTypeForToy,   // 跳蛋指令
};

@interface RemoteControllerCell() {
    UIImageView *icon1;
    UIImageView *icon2;
    UILabel *coinLabel;
    UILabel *nameLabel;
    UILabel *socketTimeLabel;
    UIButton *selectedButton;
    CellType type;
}
@end

@implementation RemoteControllerCell
@synthesize selectedButton = selectedButton;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)updateRemoteToy:(NSInteger)index info:(RemoteOrderModel*)info {
    selectedButton.hidden = true;
    self.contentView.backgroundColor = RGB_COLOR(@"#FAE5F4", 1);
    type = CellTypeForToy;
    [icon1 setHidden:false];
    [icon2 setHidden:false];
    nameLabel.text = info.giftname;
    socketTimeLabel.text = [NSString stringWithFormat:@"%@%@", info.shocktime, YZMsg(@"RemoteControllerCell_second")];
    coinLabel.text = [self changeToCurrency:info.price];

    WeakSelf
    NSString *iconUrl = info.imagePath;
    [icon2 sd_setImageWithURL:[NSURL URLWithString:iconUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        STRONGSELF
        if (error == nil) {
            strongSelf->icon2.image = image;
        } else {
            [strongSelf->icon2 setHidden:true];
        }
    }];
}

- (void)updateOrder:(NSInteger)index info:(RemoteOrderModel*)info {
    selectedButton.hidden = true;
    self.contentView.backgroundColor = RGB_COLOR(@"#FBE6FD", 1);
    type = CellTypeForOrder;
    [icon1 setHidden:true];
    [icon2 setHidden:true];
    nameLabel.text = info.giftname;
    socketTimeLabel.text = [NSString stringWithFormat:@"%@%@", info.shocktime, YZMsg(@"RemoteControllerCell_second")];
    coinLabel.text = [self changeToCurrency:info.price];
}

- (void)updateOrderForOnlySelect:(NSInteger)index info:(RemoteOrderModel*)info {
    selectedButton.hidden = false;
    self.contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.backgroundColor = [UIColor clearColor];
    type = CellTypeForOrder;
    [icon1 setHidden:true];
    [icon2 setHidden:true];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = info.giftname;
    socketTimeLabel.textColor = [UIColor whiteColor];
    socketTimeLabel.text = [NSString stringWithFormat:@"%@%@", info.shocktime, YZMsg(@"RemoteControllerCell_second")];
    coinLabel.textColor = [UIColor whiteColor];
    coinLabel.text = [self changeToCurrency:info.price];
}

- (NSString*)changeToCurrency:(NSString*)price {
    return [YBToolClass getRateCurrency:price showUnit:YES];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    if (selected) {
        if (selectedButton.isHidden) {
            self.contentView.layer.borderWidth = 1;
            switch (type) {
                case CellTypeForOrder:
                    self.contentView.layer.borderColor = RGB_COLOR(@"#E500AE", 1).CGColor;
                    break;
                case CellTypeForToy:
                    self.contentView.layer.borderColor = RGB_COLOR(@"#E84BBA", 1).CGColor;
                    break;
                default:
                    break;
            }
        } else {
            selectedButton.selected = true;
        }
    } else {
        self.contentView.layer.borderWidth = 0;
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
        selectedButton.selected = false;
    }
}

#pragma mark - UI
- (void)setupViews {
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = true;

    coinLabel = [[UILabel alloc] init];
    coinLabel.font = [UIFont systemFontOfSize:17];
    coinLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:coinLabel];
    WeakSelf;
    [coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.contentView).offset(-7);
        make.right.equalTo(weakSelf.contentView).offset(-10);
    }];

    UIStackView *verticalStackView = [[UIStackView alloc] init];
    verticalStackView.spacing = 6;
    verticalStackView.axis = UILayoutConstraintAxisVertical;
    [self.contentView addSubview:verticalStackView];
    [verticalStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView).offset(8);
        make.centerY.equalTo(weakSelf.contentView);
    }];

    icon1 = [[UIImageView alloc] init];
    icon1.contentMode = UIViewContentModeScaleAspectFit;
    icon1.image = [ImageBundle imagewithBundleName:@"controll_2.png"];
    icon2 = [[UIImageView alloc] init];
    icon2.contentMode = UIViewContentModeScaleAspectFit;
    nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:17];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.minimumScaleFactor = 0.5;
    nameLabel.adjustsFontSizeToFitWidth = true;

    UIStackView *horizontalStackView = [[UIStackView alloc] initWithArrangedSubviews:@[icon1, icon2, nameLabel]];
    horizontalStackView.spacing = 4;
    [verticalStackView addArrangedSubview:horizontalStackView];
    [icon1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@21);
    }];

    [icon2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@18);
    }];

    socketTimeLabel = [[UILabel alloc] init];
    socketTimeLabel.font = [UIFont systemFontOfSize:17];
    socketTimeLabel.textColor = RGB_COLOR(@"#555553", 1);
    [verticalStackView addArrangedSubview:socketTimeLabel];

    selectedButton = [[UIButton alloc] init];
    selectedButton.hidden = true;
    selectedButton.userInteractionEnabled = NO;
    [selectedButton setImage:[ImageBundle imagewithBundleName:@"orderListCell_off.png"] forState:UIControlStateNormal];
    [selectedButton setImage:[ImageBundle imagewithBundleName:@"orderListCell_on.png"] forState:UIControlStateSelected];
    [self.contentView addSubview:selectedButton];
    [selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView).offset(7);
        make.right.equalTo(weakSelf.contentView).offset(-10);
        make.size.equalTo(@20);
        make.left.greaterThanOrEqualTo(verticalStackView.mas_right);
    }];
}

@end
