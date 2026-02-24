//
//  VIPVC.m
//  phonelive2
//
//  Created by 400 on 2021/7/4.
//  Copyright © 2021 toby. All rights reserved.
//

#import "VIPVC.h"
#import "VIPDesCell.h"

@interface VIPVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *reward_list;
}
@property (weak, nonatomic) IBOutlet UIView *selectedView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollbgView;
@property (weak, nonatomic) IBOutlet UILabel *title1;
@property (weak, nonatomic) IBOutlet UILabel *title2;


@property (weak, nonatomic) IBOutlet UILabel *currentLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLevelSubLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelProLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *levelProView;

@property (weak, nonatomic) IBOutlet UILabel *level1Label;
@property (weak, nonatomic) IBOutlet UILabel *level2Label;

@property (weak, nonatomic) IBOutlet UIButton *titleLeftButton;
@property (weak, nonatomic) IBOutlet UILabel *leveldesLabel;
@property (weak, nonatomic) IBOutlet UIView *gift1View;
@property (weak, nonatomic) IBOutlet UIView *gift2View;
@property (weak, nonatomic) IBOutlet UIView *gift3View;

@property (weak, nonatomic) IBOutlet UIImageView *kingIconImgV;

@property(nonatomic,strong)NSMutableArray *datas;

@property (weak, nonatomic) IBOutlet UILabel *kingRuleLabel1;

@property (weak, nonatomic) IBOutlet UILabel *kingRuleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *kingRuleLabel3;
@property (weak, nonatomic) IBOutlet UILabel *kingRuleLabel4;


@end

@implementation VIPVC
-(void)navigation{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0,0, _window_width, (ShowDiff>0?ShowDiff:20) + 44)];
    navtion.backgroundColor = [UIColor clearColor];
   
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBtn.frame = CGRectMake(8, ShowDiff>0?ShowDiff:20,40,44);
//    [returnBtn setHighlighted:YES];
//    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"person_back_white"] forState:UIControlStateNormal];
//    [returnBtn setBackgroundImage:[UIImage sd_imageWithColor:[UIColor clearColor] size:CGSizeMake(40, 44)]];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-180)/2.0, ShowDiff>0?ShowDiff:20, 180, 44)];
    titleLabel.userInteractionEnabled = YES;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.text = YZMsg(@"VIPVC_title");
    [navtion addSubview:titleLabel];
    
//    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];
    [self.view addSubview:navtion];
}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _gift1View.hidden = YES;
    _gift2View.hidden = YES;
    _gift3View.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    [self navigation];
    self.scrollbgView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.datas = [NSMutableArray array];
    self.title1.userInteractionEnabled = YES;
    self.title2.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapG1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap1Action)];
    [self.title1 addGestureRecognizer:tapG1];
    
    UITapGestureRecognizer *tapG2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap2Action)];
    [self.title2 addGestureRecognizer:tapG2];
    
    NSArray *giftVis = @[self.gift1View,self.gift2View,self.gift3View];
    for (int i=0; i<giftVis.count; i++) {
        UIView *giftView = giftVis[i];
        UIButton *but3 = (UIButton*)[giftView viewWithTag:1003];
        [but3 addTarget:self action:@selector(rewardAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.title1.text = YZMsg(@"VIPVC_KingRights");
    self.title2.text = YZMsg(@"VIPVC_KingDetailRule");
    self.title2.textColor = [UIColor whiteColor];
    self.kingIconImgV.image = [ImageBundle imagewithBundleName:@"kingV_icon"];
    self.kingRuleLabel1.text = YZMsg(@"VIPVC_KingRuleLevel");
    self.kingRuleLabel2.text = YZMsg(@"VIPVC_KingRuleChargeRange");
    self.kingRuleLabel3.text = YZMsg(@"VIPVC_KingRuleUpHandsel");
    self.kingRuleLabel4.text = YZMsg(@"VIPVC_KingRuleWeekSalary");
    
    [self getRequest];
    
}
-(void)tap1Action
{
    [self.scrollbgView setContentOffset:CGPointMake(0, 0) animated:YES];
}
-(void)tap2Action
{
    [self.scrollbgView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
}

-(void)getRequest{
    NSString *urlStr = @"Kingreward.getList";
    WeakSelf
    [[YBNetworking sharedManager]postNetworkWithUrl:urlStr withBaseDomian:YES andParameter:nil data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if(![info isKindOfClass:[NSArray class]]|| [(NSArray*)info count]<=0){
                [MBProgressHUD showError:msg];
                return;
            }
            NSDictionary *subDic = info[0];
            NSString *leve_c_cur = subDic[@"leve_c_cur"];
            NSString *leve_c_start = subDic[@"leve_c_start"];
            NSString *leve_c_end = subDic[@"leve_c_end"];
            NSString *level = subDic[@"level"];
            strongSelf->reward_list = subDic[@"reward_list"];
            NSArray *list = subDic[@"list"];
            
            strongSelf.datas = [NSMutableArray arrayWithArray:list];
            strongSelf.currentLevelLabel.text = [NSString stringWithFormat:YZMsg(@"VIPVC_KingLeve%@_title"),level];
            strongSelf.currentLevelSubLabel.text = [NSString stringWithFormat:YZMsg(@"VIPVC_KingLeveCurrent%@"),level];
            strongSelf.levelProLabel.text = [NSString stringWithFormat:YZMsg(@"VIPVC_Charge%@_UpKingLeve%ld"),[YBToolClass getRateCurrency:@([leve_c_end integerValue] - [leve_c_cur integerValue]).stringValue showUnit:YES], [level integerValue] + 1];
            
            float curProg = ([leve_c_cur floatValue] - [leve_c_start floatValue])/([leve_c_end floatValue] -[leve_c_start floatValue]);
            strongSelf.levelProView.progress = curProg;
            strongSelf.level1Label.text = [NSString stringWithFormat:@"V%@",level];
            strongSelf.level2Label.text = [NSString stringWithFormat:@"V%d",([level intValue]+1)];
            [strongSelf.titleLeftButton setTitle:[NSString stringWithFormat:YZMsg(@"VIPVC_KingLeve%@_title"),level] forState:UIControlStateNormal];
            strongSelf.leveldesLabel.text = [NSString stringWithFormat:YZMsg(@"VIPVC_KingLeve%@_Rights"),level];
            NSArray *giftVis = @[strongSelf.gift1View,strongSelf.gift2View,strongSelf.gift3View];
            for (int i=0; i<strongSelf->reward_list.count; i++) {
                UIView *giftView = giftVis[i];
                giftView.hidden = NO;
                NSDictionary *subDic1 = strongSelf->reward_list[i];
                NSInteger reward_can_get = [subDic1[@"reward_can_get"] integerValue];
                NSInteger reward_type = [subDic1[@"reward_type"] integerValue];
                NSInteger reward_next_time = [subDic1[@"reward_next_time"] integerValue];
                UILabel *labelg1 = (UILabel*)[giftView viewWithTag:1001];
                UILabel *labelg2 =  (UILabel*)[giftView viewWithTag:1002];
                UIButton *but3 = (UIButton*)[giftView viewWithTag:1003];
                [but3 setTitle:YZMsg(@"tasktoget") forState:UIControlStateNormal];
                but3.titleLabel.minimumScaleFactor = 0.5;
                but3.titleLabel.adjustsFontSizeToFitWidth = YES;
                
                if (reward_can_get == 0| reward_can_get == 2) {
                    if (reward_can_get == 0) {
                        [but3 setTitle:YZMsg(@"VIPVC_Can'tGet") forState:UIControlStateDisabled];
                    }else{
                        if (reward_type == 1) {
                            but3.titleLabel.minimumScaleFactor = 0.5;
                            but3.titleLabel.adjustsFontSizeToFitWidth = YES;
                            [but3 setTitle:[NSString stringWithFormat:YZMsg(@"VIPVC_NextTime%@"),[self timeWithTimeIntervalString:reward_next_time]] forState:UIControlStateDisabled];
                        }else{
                            [but3 setTitle:YZMsg(@"redDetails_already_got") forState:UIControlStateDisabled];
                        }
                       
                    }
                    but3.enabled = false;
                }else{
                    but3.enabled = YES;
                }
                
                labelg1.text = subDic1[@"reward_money"];
                labelg2.text = subDic1[@"reward_title"];
                
            }
            
            [strongSelf.tableView reloadData];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:error.localizedDescription];
    }];
}

- (NSString *)timeWithTimeIntervalString:(NSInteger )timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeString];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}


-(void)rewardAction:(UIButton*)button{
    NSInteger tagVi = button.superview.tag;
    if (reward_list) {
        NSDictionary *subd = reward_list[tagVi-10000];
        NSString *typeStr = subd[@"reward_type"];
        NSString *urlStr = @"Kingreward.getreward";
        WeakSelf
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        [hud hideAnimated:YES afterDelay:15];
        [[YBNetworking sharedManager]postNetworkWithUrl:urlStr withBaseDomian:YES andParameter:@{@"reward_type":typeStr?typeStr:@""} data:nil success:^(int code, NSArray *info, NSString *msg) {
            [hud hideAnimated:YES];
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (code == 0) {
                [MBProgressHUD showError:msg];
                [strongSelf getRequest];
          
            }else{
                [MBProgressHUD showError:msg];
            }
        }fail:^(NSError *error) {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:error.localizedDescription];
        }];
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //使用重用机制，IDENTIFIER作为重用机制查找的标识，tableview查找可用cell时通过IDENTIFIER检索，如果有则cell不为nil
    static NSString * Identifier=@"VIPDesCell";
    VIPDesCell * cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (!cell) {
        cell=[[[XBundle currentXibBundleWithResourceName:@"VIPDesCell"] loadNibNamed:@"VIPDesCell" owner:self options:nil] lastObject];
    }
    if (indexPath.row%2 == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    }else{
        cell.backgroundColor = RGB(245,245,245);
    }
    NSDictionary *subdic = self.datas[indexPath.row];
    NSString *level = subdic[@"level"];
    NSString *c_charge = subdic[@"c_charge"];
    NSString *week_reward = subdic[@"week_reward"];
    NSString *levelup_reward = subdic[@"levelup_reward"];
    cell.label1.text =  [NSString stringWithFormat:YZMsg(@"VIPVC_KingLeve%@_title"),level];
    cell.label2.text = [NSString stringWithFormat:@"%@+", [YBToolClass getRateCurrency:c_charge showUnit:YES]];
    cell.label3.text = [NSString stringWithFormat:@"%@", [YBToolClass getRateCurrency:levelup_reward showUnit:YES]];
    cell.label4.text = [NSString stringWithFormat:@"%@", [YBToolClass getRateCurrency:week_reward showUnit:YES]];
    
    
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.scrollbgView]) {
        self.selectedView.left = 30+(self.title1.width-self.selectedView.width)/2 + scrollView.contentOffset.x*((30+self.title1.width)/SCREEN_WIDTH);
        if (self.selectedView.left>70) {
            self.title1.textColor = [UIColor whiteColor];
            self.title2.textColor = RGB(233,47,144);
        }else{
            self.title1.textColor = RGB(233,47,144);
            self.title2.textColor = [UIColor whiteColor];
        }
    }
    
}

@end
