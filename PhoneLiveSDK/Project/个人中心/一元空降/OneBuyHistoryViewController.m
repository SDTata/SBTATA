//
//  OneBuyViewController.m
//  phonelive2
//
//  Created by 400 on 2022/6/12.
//  Copyright © 2022 toby. All rights reserved.
//

#import "OneBuyHistoryViewController.h"
#import "OneBuyHistroyTableViewCell.h"
@interface OneBuyHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    int page;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *datas;

@end

@implementation OneBuyHistoryViewController
- (IBAction)backNavigation:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datas = [NSMutableArray array];
    page = 1;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"OneBuyHistroyTableViewCell" bundle:[XBundle currentXibBundleWithResourceName:@""]] forCellReuseIdentifier:@"OneBuyHistroyTableViewCell"];
  
    [self getData];
    
    WeakSelf
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf == nil) {
            return;
        }
        strongSelf->page = 1;
        [strongSelf getData];
    }];
    ((MJRefreshNormalHeader*)_tableView.mj_header).stateLabel.textColor = [UIColor blackColor];
    ((MJRefreshNormalHeader*)_tableView.mj_header).arrowView.tintColor = [UIColor blackColor];
    ((MJRefreshNormalHeader*)_tableView.mj_header).activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    ((MJRefreshNormalHeader*)_tableView.mj_header).lastUpdatedTimeLabel.textColor = [UIColor blackColor];

    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->page +=1;
        [strongSelf getData];
    }];
    
}
#pragma mark - UITableView delegate datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OneBuyHistroyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OneBuyHistroyTableViewCell"];
    
    NSDictionary *subDic = self.datas[indexPath.row];
    
    cell.label1.text = [NSString stringWithFormat:@"%@期",subDic[@"period"]];
    NSString *timeS = [NSString stringWithFormat:@"%@",subDic[@"open_time"]];
    NSTimeInterval timeInv=[timeS doubleValue];
    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:timeInv];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY/MM/dd"];//设定时间格式,这里可以设置成自己需要的格式
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    cell.label2.text = dateString;
   
    cell.label4.text = [NSString stringWithFormat:@"%ld",(long)[subDic[@"my_bet"] integerValue]];
    NSString *win_uid = [NSString stringWithFormat:@"%@",subDic[@"win_uid"]];
    NSString *winName = subDic[@"win_name"];
    if ([[Config getOwnID] isEqualToString:win_uid]) {
        cell.label3.font = [UIFont boldSystemFontOfSize:12];
        cell.label3.text = [NSString stringWithFormat:@"%@(中奖)",winName];
        cell.label3.textColor = [UIColor redColor];
    }else{
        cell.label3.font = [UIFont systemFontOfSize:12];
        cell.label3.text = [NSString stringWithFormat:@"%@",winName];
        cell.label3.textColor = RGB(250, 115, 198);
    }
    return cell;
}

-(void)getData{
    
//    datas
    NSString *requestURLStr = @"User.getFuckActivityOpenRecord";
    WeakSelf
    [[YBNetworking sharedManager]postNetworkWithUrl:requestURLStr withBaseDomian:YES andParameter:@{@"page":@(page)} data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.tableView.mj_header endRefreshing];
        [strongSelf.tableView.mj_footer endRefreshing];
        if (code == 0) {
            if(![info isKindOfClass:[NSArray class]]|| [(NSArray*)info count]<=0){
                [MBProgressHUD showError:msg];
                return;
            }
            NSArray *infoA = [NSArray arrayWithArray:info[0]];;
            if (strongSelf->page == 1) {
                [strongSelf.datas removeAllObjects];
                if (infoA.count<1) {
                    UIImageView *imgView = [[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:@"yykj_noneData"]];
                    imgView.contentMode = UIViewContentModeCenter;
                    strongSelf.tableView.tableFooterView = imgView;
                }else{
                    strongSelf.tableView.tableFooterView = nil;
                }
            }else{
                strongSelf.tableView.tableFooterView = nil;
            }
            [strongSelf.datas addObjectsFromArray:infoA];
            if (infoA.count <=40) {
                [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                if (strongSelf->page == 1) {
                    [strongSelf.tableView.mj_footer setHidden:true];
                }
               
            }
            
            [strongSelf.tableView reloadData];
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError *error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.tableView.mj_header endRefreshing];
        [strongSelf.tableView.mj_footer endRefreshing];
        [MBProgressHUD showError:error.localizedDescription];
    
        
    }];
    
}

@end
