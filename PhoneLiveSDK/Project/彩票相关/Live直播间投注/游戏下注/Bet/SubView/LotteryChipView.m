//
//  LotteryChipView.m
//  phonelive2
//
//  Created by vick on 2023/11/24.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryChipView.h"
#import "PayViewController.h"
#import "WMZDialog.h"
#import "LotteryCustomChipView.h"

@implementation LotteryChipCell

+ (CGFloat)itemWidth {
    return 38;
}

+ (CGFloat)itemHeight {
    return 38;
}

- (void)updateView {
    UIImageView *iconImgView = [UIImageView new];
    [self.contentView addSubview:iconImgView];
    self.iconImgView = iconImgView;
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsMake(4, 4, 4, 4));
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFont(12) color:UIColor.blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.5;
    titleLabel.numberOfLines = 2;
    [self.iconImgView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(4);
        make.right.mas_equalTo(-4);
        make.top.mas_equalTo(4);
        make.bottom.mas_equalTo(-4);
    }];
}

- (void)updateData {
    ChipsModel *model = self.itemModel;
    self.iconImgView.image = [ImageBundle imagewithBundleName:model.chipIcon];
    self.titleLabel.text = model.chipStr;
    
    if (model.selected) {
        [UIView animateWithDuration:0.3 animations:^{
            self.iconImgView.transform = CGAffineTransformMakeScale(1.23, 1.23);
        }];
    } else {
        self.iconImgView.transform = CGAffineTransformIdentity;
    }
}

@end


@interface LotteryChipView ()

@property (nonatomic, strong) UIView *moneyView;
@property (nonatomic, strong) VKBaseCollectionView *tableView;

@end

@implementation LotteryChipView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self setupData];
    }
    return self;
}

- (UIView *)moneyView {
    if (!_moneyView) {
        _moneyView = [UIView new];
        [_moneyView vk_addTapAction:self selector:@selector(doCharge)];
        
        UIImageView *addImgView = [UIImageView new];
        addImgView.image = [ImageBundle imagewithBundleName:@"charge_arrow"];
        [_moneyView addSubview:addImgView];
        [addImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(16);
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        UILabel *moneyLabel = [UIView vk_label:@"0" font:vkFont(14) color:UIColor.whiteColor];
        [_moneyView addSubview:moneyLabel];
        self.moneyLabel = moneyLabel;
        [moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(addImgView.mas_left).offset(-0);
            make.centerY.mas_equalTo(0);
        }];
    }
    return _moneyView;
}

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.viewStyle = VKCollectionViewStyleHorizontal;
        _tableView.registerCellClass = [LotteryChipCell class];
        
        _weakify(self)
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, ChipsModel *item) {
            _strongify(self)
            if (item.isEdit && (item.chipNumber <= 0 || item.selected)) {
                [self doCustomChip];
            }else{
                VKBLOCK(self.selectBlock, item);
            }
            [self.tableView selectIndexPath:indexPath key:@"selected"];
        };
    }
    return _tableView;
}

- (UIButton *)continueBtn {
    if (!_continueBtn) {
        _continueBtn = [UIView vk_button:YZMsg(@"game_continue_bet") image:nil font:vkFont(14) color:UIColor.whiteColor];
        [_continueBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"continue_nomal"] forState:UIControlStateNormal];
        [_continueBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"continue_gray"] forState:UIControlStateDisabled];
        _continueBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        _continueBtn.titleLabel.minimumScaleFactor = 0.5;
        _continueBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 6, 0);
        [_continueBtn vk_addTapAction:self selector:@selector(clickContinueAction)];
        _continueBtn.enabled = NO;
    }
    return _continueBtn;
}

- (void)setupView {
    [self addSubview:self.moneyView];
    [self.moneyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(30);
    }];
    
    [self addSubview:self.continueBtn];
    [self.continueBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(60);
        make.centerY.mas_equalTo(0);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.moneyView.mas_right).offset(0);
        make.right.mas_equalTo(self.continueBtn.mas_left).offset(-10);
        make.height.mas_equalTo(LotteryChipCell.itemHeight);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)setupData {
    self.tableView.dataItems =  [[ChipsListModel sharedInstance] chipListArrays];
    [self.tableView reloadData];
    
    vkGcdAfter(0.0, ^{
        [self.tableView setDefalutIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    });
}

- (void)refreshBalance {
    LiveUser *user = [Config myProfile];
    self.moneyLabel.text = [YBToolClass getRateBalance:user.coin showUnit:YES];
}

/// 充值
- (void)doCharge {
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    [vkTopVC().navigationController pushViewController:payView animated:YES];
}

/// 自定义筹码弹窗
- (void)doCustomChip {
    
    LotteryCustomChipView *view = [LotteryCustomChipView new];
    [view showFromCenter];
    
    WeakSelf
    view.clickConfirmBlock = ^(double amount) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        for (ChipsModel *model in strongSelf.tableView.dataItems) {
            if (model.isEdit) {
                model.chipNumber = amount;
                model.chipStr = [NSString stringWithFormat:@"?\n%@", [YBToolClass currencyCoverToK:[YBToolClass getRateCurrency:[NSString stringWithFormat:@"%.2f", amount] showUnit: NO]]];
                model.customChipNumber = model.chipNumber;
                VKBLOCK(strongSelf.selectBlock, model);
            }
        }
        [strongSelf.tableView reloadData];
    };
}

/// 续投
- (void)clickContinueAction {
    VKBLOCK(self.continueBlock);
}

@end
