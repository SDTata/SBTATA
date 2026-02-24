//
//  WinningRecordChildVC.m
//  phonelive2
//
//  Created by user on 2024/8/27.
//  Copyright © 2024 toby. All rights reserved.
//

#import "WinningRecordChildVC.h"
#import "WinningRecordTableViewCell.h"

@interface WinningRecordChildVC ()
@property (nonatomic, strong) UIStackView *noDataStackView;
@property (nonatomic, strong) VKBaseTableView *tableView;
@end

@implementation WinningRecordChildVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self.tableView vk_headerBeginRefresh];
    _weakify(self)
    [self getLuckydrawRecord:self.recordType block:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        _strongify(self)
        NSArray *records = networkData.data[@"record"];
        self.noDataStackView.hidden = records.count > 0;
        if (self.recordType == 0) {
            [self.tableView vk_refreshFinish: records];
        } else {
            NSArray *recordList = networkData.data[@"record_list"];
            NSMutableDictionary *groupedRecords = [NSMutableDictionary dictionary];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDateFormatter *dateOnlyFormatter = [[NSDateFormatter alloc] init];
            [dateOnlyFormatter setDateFormat:@"yyyy-MM-dd"];
            for (NSDictionary *record in recordList) {
                NSString *tm = record[@"tm"];
                NSDate *fullDate = [dateFormatter dateFromString:tm];
                NSString *dateOnly = [dateOnlyFormatter stringFromDate:fullDate];
                if (!groupedRecords[dateOnly]) {
                    groupedRecords[dateOnly] = [NSMutableArray array];
                }
                [groupedRecords[dateOnly] addObject:record];
            }
            NSMutableArray *finalArray = [NSMutableArray array];
            [groupedRecords enumerateKeysAndObjectsUsingBlock:^(NSString *date, NSArray *records, BOOL *stop) {
                NSDictionary *groupedObject = @{@"date": date, @"record": records};
                [finalArray addObject:groupedObject];
            }];
            [self.tableView vk_refreshFinish: [finalArray copy]];
        }
    }];
}

- (void)setupView {
    UIStackView *noDataStackView = [UIStackView new];
    noDataStackView.axis = UILayoutConstraintAxisVertical;
    noDataStackView.spacing = 5;
    noDataStackView.hidden = YES;
    [self.view addSubview:noDataStackView];
    self.noDataStackView = noDataStackView;
    [noDataStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).multipliedBy(0.75);
    }];
    
    UIImageView *noDataImg = [UIImageView new];
    noDataImg.image = [ImageBundle imagewithBundleName:@"winning_record_imgNoDateWheel"];
    noDataImg.contentMode = UIViewContentModeScaleAspectFit;
    [noDataStackView addArrangedSubview:noDataImg];
    [noDataImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@RatioBaseWidth375(150));
    }];
    UILabel *noDataTitleLabel = [UILabel new];
    noDataTitleLabel.textAlignment = NSTextAlignmentCenter;
    noDataTitleLabel.font = [UIFont boldSystemFontOfSize:14];
    noDataTitleLabel.textColor = vkColorRGBA(0, 0, 0, 0.7);
    noDataTitleLabel.text = YZMsg(@"Winning_record_welcome");
    [noDataStackView addArrangedSubview:noDataTitleLabel];
    [noDataTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
    }];
    
    UILabel *noDataSubTitleLabel = [UILabel new];
    noDataSubTitleLabel.textAlignment = NSTextAlignmentCenter;
    noDataSubTitleLabel.font = [UIFont boldSystemFontOfSize:12];
    noDataSubTitleLabel.textColor = vkColorRGBA(0, 0, 0, 0.5);
    noDataSubTitleLabel.text = YZMsg(@"Winning_record_lucky");
    [noDataStackView addArrangedSubview:noDataSubTitleLabel];
    [noDataSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    if (self.recordType == 1) {
        self.tableView.viewStyle = VKTableViewStyleGrouped;
        self.tableView.registerSectionHeaderClass = [WinningRecordSectionCell class];
        self.tableView.rowsParseBlock = ^NSArray *(NSDictionary *section) {
            return section[@"record"]; // --- 假資料待更新 ---
        };
        self.tableView.extraData = @(self.recordType);
    }
}

- (VKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseTableView new];
        _tableView.viewStyle = VKTableViewStyleSingle;
        _tableView.automaticDimension = YES;
        _tableView.registerCellClass = [WinningRecordTableViewCell class];
    }
    return _tableView;
}

- (void)getLuckydrawRecord:(int)type block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"record_type"] = @(type);
    [LotteryNetworkUtil baseRequest:@"Live.luckydrawRecord" params:dict block:block];
}


@end
