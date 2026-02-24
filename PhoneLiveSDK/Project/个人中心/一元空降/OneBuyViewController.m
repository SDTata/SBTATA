//
//  OneBuyViewController.m
//  phonelive2
//
//  Created by 400 on 2022/6/12.
//  Copyright © 2022 toby. All rights reserved.
//

#import "OneBuyViewController.h"
#import "OneBuyTableViewCell.h"
@interface OneBuyViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *title3;

@property(nonatomic,strong)NSArray *datas;
@end

@implementation OneBuyViewController
- (IBAction)backNavigation:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.title3.text = [NSString stringWithFormat:@"投注%@",[common name_coin]];
    [self.tableView registerNib:[UINib nibWithNibName:@"OneBuyTableViewCell" bundle:[XBundle currentXibBundleWithResourceName:@""]] forCellReuseIdentifier:@"OneBuyTableViewCell"];
    [self getData];
}

-(void)getData{
    
//    datas
    NSString *requestURLStr = @"User.getFuckActivityBetInfo";
    WeakSelf
    [[YBNetworking sharedManager]postNetworkWithUrl:requestURLStr withBaseDomian:YES andParameter:nil data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if(![info isKindOfClass:[NSArray class]] || [(NSArray*)info count]<=0){
                [MBProgressHUD showError:msg];
                return;
            }
            strongSelf.datas = [NSArray arrayWithArray:info[0]];
            if (strongSelf.datas.count<1) {
                UIImageView *imgView = [[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:@"yykj_noneData"]];
                imgView.contentMode = UIViewContentModeCenter;
                strongSelf.tableView.tableFooterView = imgView;
            }else{
                strongSelf.tableView.tableFooterView = nil;
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
        [MBProgressHUD showError:error.localizedDescription];
    
        
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
    OneBuyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OneBuyTableViewCell"];
    
    NSDictionary *subDic = self.datas[indexPath.row];
    
    cell.label1.text = [NSString stringWithFormat:@"%@",subDic[@"name"]];
    NSString *timeS = [NSString stringWithFormat:@"%@",subDic[@"bet_time"]];
    NSTimeInterval timeInv=[timeS doubleValue];
    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:timeInv];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY/MM/dd"];//设定时间格式,这里可以设置成自己需要的格式
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    cell.label2.text = dateString;
    cell.label3.text = [NSString stringWithFormat:@"%ld",(long)[subDic[@"bet_coin"] integerValue]];
    
    return cell;
}

@end
