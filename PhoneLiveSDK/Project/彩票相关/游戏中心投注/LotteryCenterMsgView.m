//
//  LotteryCenterMsgView.m
//  phonelive2
//
//  Created by lucas on 2022/6/25.
//  Copyright © 2022 toby. All rights reserved.
//

#import "LotteryCenterMsgView.h"
#import "chatCenterMsgCell.h"

@interface LotteryCenterMsgView()<UITableViewDelegate,UITableViewDataSource>
// 表格视图
@property (nonatomic,strong) UITableView *tableView;
//数据源数组
@property (nonatomic, strong) NSMutableArray *dataModelArray;

@end

@implementation LotteryCenterMsgView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.userInteractionEnabled = NO;
        self.tableView.scrollEnabled = NO;
        [self addSubview:self.tableView];
    }
    return self;
}

-(void)addMsgList:(chatCenterModel *)msg{
    [self.dataModelArray addObject:msg];
    if (self.dataModelArray.count >3) {
        [self.dataModelArray  removeObjectAtIndex:0];
    }
    [self.tableView reloadData];
    [self jumpLast];
}

-(void)jumpLast
{
    NSUInteger rowCount = [self.tableView numberOfRowsInSection:0];
    if (rowCount!=NSNotFound) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
        if(indexPath.row!= self.dataModelArray.count-1) {
            return;
        }
        if (indexPath.row>0) {
            [self.tableView scrollToRowAtIndexPath:indexPath
                                     atScrollPosition:UITableViewScrollPositionBottom animated:1];
        }
    }
}

#pragma mark - <代理方法>
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:1];
    chatCenterMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"chatCenterMsgCell"]];
    if (!cell) {
        cell = [[[XBundle currentXibBundleWithResourceName:@"chatCenterMsgCell"] loadNibNamed:@"chatCenterMsgCell" owner:nil options:nil] lastObject];
    }
    if (indexPath.row == 0) {
        cell.chatLabel.alpha = 0.3;
    }else if (indexPath.row == 1) {
        cell.chatLabel.alpha = 0.6;
    }else{
        cell.chatLabel.alpha = 1;
    }
    cell.chatView.hidden = YES;
    chatCenterModel * model = self.dataModelArray[indexPath.row];
    cell.centerModel = model;
    return cell;
}

-(NSMutableArray *)dataModelArray{
    if (!_dataModelArray) {
        _dataModelArray = [[NSMutableArray alloc] init];
        for (int i = 0; i<3; i ++) {
            chatModel * model = [[chatModel alloc] init];
            [_dataModelArray addObject:model];
        }
    }
    return _dataModelArray;
}
@end
