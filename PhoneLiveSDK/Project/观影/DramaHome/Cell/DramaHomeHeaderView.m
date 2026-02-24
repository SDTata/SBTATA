//
//  DramaHomeHeaderView.m
//  DramaTest
//
//  Created by s5346 on 2024/5/3.
//

#import "DramaHomeHeaderView.h"

@interface DramaHomeHeaderView ()

@property(nonatomic, strong) UIStackView *stackView;

@end

@implementation DramaHomeHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

#pragma mark - UI
- (void)setupViews {
    [self addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];

    if (self.stackView.arrangedSubviews.count > 0) {
        [self changeType:self.stackView.arrangedSubviews[0]];
    }
}

- (void)changeType:(UIButton*)sender {
    if (sender.isSelected) {
        return;
    }
    for (UIButton *button in self.stackView.arrangedSubviews) {
        button.selected = NO;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
    }

    sender.selected = NO;
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sender.backgroundColor = RGB_COLOR(@"#B73AF5", 1);

    [self.delegate DramaHomeHeaderViewDelegateForSelectType:sender.tag];
}

#pragma mark - lazy
- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] init];
        _stackView.spacing = 20;

        NSArray *titleArray = @[YZMsg(@"DramaHomeHeaderView_latest"), YZMsg(@"DramaHomeHeaderView_hot")];

        for (int i = 0; i < titleArray.count; i++) {
            UIButton *button = [[UIButton alloc] init];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            button.titleLabel.minimumScaleFactor = 0.5;
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            [button setTitle:titleArray[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor whiteColor];
            button.layer.cornerRadius = 14;
            button.tag = i;
            [button addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventTouchUpInside];
            [_stackView addArrangedSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@RatioBaseWidth360(120));
                make.height.equalTo(@28);
            }];
        }
    }
    return _stackView;
}

@end
