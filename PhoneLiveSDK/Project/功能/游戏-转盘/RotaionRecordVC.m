//
//  RotaionRecordVC.m
//  phonelive2
//
//  Created by 400 on 2021/5/26.
//  Copyright © 2021 toby. All rights reserved.
//

#import "RotaionRecordVC.h"

@interface RotaionRecordVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *djjlBgImgV;
@property (weak, nonatomic) IBOutlet UIButton *recordAll;
@property (weak, nonatomic) IBOutlet UIButton *recordMy;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *data;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constansY;

@property(nonatomic,assign)int recordTypeNu;
@end

@implementation RotaionRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _recordTypeNu = 0;
    self.constansY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.703636/2;
    UIImage *imgBg = [ImageBundle imagewithBundleName:@"zjjlbg"];
    imgBg = [imgBg resizableImageWithCapInsets:UIEdgeInsetsMake(140, 40, 40, 40)];
    self.djjlBgImgV.image = imgBg;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 20;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.recordAll setImage:[ImageBundle imagewithBundleName:YZMsg(@"RotaionRecordVC_recordAll_N")] forState:UIControlStateNormal];
    [self.recordAll setImage:[ImageBundle imagewithBundleName:YZMsg(@"RotaionRecordVC_recordAll_S")] forState:UIControlStateSelected];
    
    [self.recordMy setImage:[ImageBundle imagewithBundleName:YZMsg(@"RotaionRecordVC_recordMy_N")] forState:UIControlStateNormal];
    [self.recordMy setImage:[ImageBundle imagewithBundleName:YZMsg(@"RotaionRecordVC_recordMy_S")] forState:UIControlStateSelected];
    
    [self requestData];
}
-(void)requestData {
    NSString *userBaseUrl = @"Live.luckydrawRecord";
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow  animated:YES];
    WeakSelf
     [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:@{@"record_type":@(_recordTypeNu)}  data:nil success:^(int code, NSArray *info, NSString *msg) {
         STRONGSELF
         if (strongSelf == nil) {
             return;
         }
         [hud hideAnimated:YES];
         if (code == 0 && info.count>0) {
             if(![info isKindOfClass:[NSArray class]]||[(NSArray*)info count]<=0){
                 [MBProgressHUD showError:msg];
                 return;
             }
             NSDictionary *resultDic= info[0];
             NSArray *recordsA = resultDic[@"record"];
             if (recordsA.count>0) {
                 strongSelf.data = [NSMutableArray arrayWithArray:recordsA];
             }else{
                 strongSelf.data = [NSMutableArray array];
             }
             [strongSelf.tableView reloadData];
         }else{
             strongSelf.data = [NSMutableArray array];
             [strongSelf.tableView reloadData];
             [MBProgressHUD showError:msg];
         }
         
     } fail:^(NSError *error) {
         
         [hud hideAnimated:YES];
     }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.constansY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.703636/2;
    [self.view layoutIfNeeded];
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.3 animations:^{
        self.constansY.constant = 0;
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.3 animations:^{
        self.constansY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.703636/2;;
        self.view.backgroundColor = [UIColor clearColor];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    
    
    
}

// 每行显示的内容是什么
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // 从重用池中查找对应的cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"ABC"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ABC"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(5);
            make.bottom.top.mas_equalTo(1);
        }];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
    }
    NSAttributedString * attStr = [[NSAttributedString alloc] initWithData:[self.data[indexPath.row] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    cell.textLabel.attributedText=attStr;
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

// 一组中有多少行
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

// 有多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (IBAction)recordAllaction:(UIButton *)sender {
    sender.selected = YES;
    self.recordMy.selected = NO;
    _recordTypeNu = 0;
    [self requestData];
}
- (IBAction)recordMyactuon:(UIButton *)sender {
    sender.selected = YES;
    self.recordAll.selected = NO;
    _recordTypeNu = 1;
    [self requestData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
