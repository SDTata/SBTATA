//
//  LanguageVC.m
//  phonelive2
//
//  Created by 400 on 2021/8/16.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LanguageVC.h"
#import "LanguageCell.h"
#import "AppDelegate.h"
#import "MJRefreshConfig.h"
@interface LanguageVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,strong)NSArray *languagesData;
@end

@implementation LanguageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navtion];
    self.languagesData = [[RookieTools shareInstance] supportlanguages];
    self.tableView.rowHeight = 44;
    self.tableView.frame = CGRectMake(0, 64+statusbarHeight, _window_width, _window_height - 64 - statusbarHeight);
}
-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0,0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor = [UIColor whiteColor];
    UILabel *labels = [[UILabel alloc]init];
    labels.text = YZMsg(@"swichLanguage");
    [labels setFont:navtionTitleFont];
    labels.textColor = navtionTitleColor;
    labels.frame = CGRectMake(0,statusbarHeight,_window_width,84);
    labels.textAlignment = NSTextAlignmentCenter;
    [navtion addSubview:labels];
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *bigBTN = [[UIButton alloc]initWithFrame:CGRectMake(0, statusbarHeight, _window_width/2, 64)];
    [bigBTN addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:bigBTN];
    returnBtn.frame = CGRectMake(8,24 + statusbarHeight,40,40);
    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];
    UIButton *btnttttt = [UIButton buttonWithType:UIButtonTypeCustom];
    btnttttt.backgroundColor = [UIColor clearColor];
    [btnttttt addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    btnttttt.frame = CGRectMake(0,0,100,64);
    [navtion addSubview:btnttttt];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];
    [self.view addSubview:navtion];
}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * Identifier=@"LanguageCell";
    LanguageCell * cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (!cell) {
        cell=[[[XBundle currentXibBundleWithResourceName:@"LanguageCell"] loadNibNamed:@"LanguageCell" owner:self options:nil] lastObject];
    }
    cell.titleLabel.text = YZMsg(self.languagesData[indexPath.row]);
    if ([self.languagesData[indexPath.row] isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:CurrentLanguage]]) {
        cell.selectedButton.selected = true;
    }else{
        cell.selectedButton.selected = false;
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //判断当前分区返回分区行数
    return self.languagesData.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //返回分区数
    return 1;
}

//点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.languagesData[indexPath.row] isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:CurrentLanguage]]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.languagesData[indexPath.row] forKey:CurrentLanguage];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [MJRefreshConfig defaultConfig].languageCode  = self.languagesData[indexPath.row];
    
    MBProgressHUD *hub =   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WeakSelf
    [[MXBADelegate sharedAppDelegate] getConfig:false complete:^(NSString *errormsg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [[MXBADelegate sharedAppDelegate] getAppConfig:^(NSString *errormsg, NSDictionary *json) {
            STRONGSELF
            if (!strongSelf) return;
            [hub hideAnimated:YES];
            [[RookieTools shareInstance] resetLanguageNow:strongSelf.languagesData[indexPath.row]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLanguage" object:nil];
            [strongSelf.tableView reloadData];
        }];
    }];
    
    
}
@end
