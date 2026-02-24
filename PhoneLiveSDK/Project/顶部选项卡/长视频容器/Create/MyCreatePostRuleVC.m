//
//  MyCreatePostRuleVC.m
//  phonelive2
//
//  Created by vick on 2024/7/20.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyCreatePostRuleVC.h"
#import "MyCreatePostRuleCell.h"
#import "PostVideoViewController.h"

@interface MyCreatePostRuleVC ()

@property (nonatomic, strong) VKBaseTableView *tableView;

@end

@implementation MyCreatePostRuleVC

- (VKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseTableView new];
        _tableView.viewStyle = VKTableViewStyleGrouped;
        _tableView.registerSectionHeaderClass = [MyCreatePostRuleSectionCell class];
        _tableView.registerCellClass = [MyCreatePostRuleCell class];
        _tableView.automaticDimension = YES;
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.layer.cornerRadius = 20;
        _tableView.layer.masksToBounds = YES;
        
        _tableView.rowsParseBlock = ^NSArray *(RuleSection *section) {
            return section.rules;
        };
        
        UILabel *headerLabel = [UIView vk_label:YZMsg(@"post_video_rules_title") font:vkFont(14) color:UIColor.blackColor];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.frame = CGRectMake(0, 0, VK_SCREEN_W, 40);
        _tableView.tableHeaderView = headerLabel;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupData];
}

- (void)setupView {
    self.view.backgroundColor = vkColorRGB(231, 227, 235);
    self.view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.view.layer.cornerRadius = 20;
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(30);
        make.bottom.mas_equalTo(-0);
    }];
    
    UIView *contentView = [UIView new];
    [scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.width.mas_equalTo(scrollView);
    }];
    
    [contentView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
        make.bottom.mas_equalTo(-10);
    }];
}

- (void)setupData {
    NSMutableArray *results = [NSMutableArray array];
    
    RuleSection *section1 = [RuleSection new];
    section1.title = YZMsg(@"post_video_desc_section1");
    section1.rules = @[YZMsg(@"post_video_desc_rulse1")];
    [results addObject:section1];
    
    RuleSection *section2 = [RuleSection new];
    section2.title = YZMsg(@"post_video_desc_section2");
    section2.rules = @[YZMsg(@"post_video_desc_rulse2_1"), YZMsg(@"post_video_desc_rulse2_2"), YZMsg(@"post_video_desc_rulse2_3")];
    [results addObject:section2];
    
    RuleSection *section3 = [RuleSection new];
    section3.title = YZMsg(@"post_video_desc_section3");
    section3.rules = @[YZMsg(@"post_video_desc_rulse3_1"), YZMsg(@"post_video_desc_rulse3_2")];
    [results addObject:section3];
    
    RuleSection *section4 = [RuleSection new];
    section4.title = YZMsg(@"post_video_desc_section4");
    section4.rules = @[YZMsg(@"post_video_desc_rulse4")];
    [results addObject:section4];
    
    RuleSection *section5 = [RuleSection new];
    section5.title = YZMsg(@"post_video_desc_section5");
    section5.rules = @[YZMsg(@"post_video_desc_rulse5_1"), YZMsg(@"post_video_desc_rulse5_2")];
    [results addObject:section5];
    
    RuleSection *section6 = [RuleSection new];
    section6.title = YZMsg(@"post_video_desc_section6");
    section6.rules = @[YZMsg(@"post_video_desc_rulse6_1"), YZMsg(@"post_video_desc_rulse6_2")];
    [results addObject:section6];
    
    self.tableView.dataItems = results;
    [self.tableView reloadData];
    
    vkGcdAfter(0.0, ^{
        [self.tableView layoutIfNeeded];
        CGFloat height = self.tableView.contentSize.height;
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_greaterThanOrEqualTo(height);
        }];
    });
}

@end
