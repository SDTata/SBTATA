//
//  EditNiceName.m
//  yunbaolive
//
//  Created by cat on 16/3/13.
//  Copyright © 2016年 cat. All rights reserved.
//

#import "EditContactInfo.h"
#import "UIColor+Util.h"
#import "ContactEditInfoCell.h"
@interface EditContactInfo ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    //UITextField *input;
    int setvisname;
    UIActivityIndicatorView *testActivityIndicator;//菊花
}
@property(nonatomic,strong)UITableView *tb_contact;
@property(nonatomic,strong)NSArray *app_list;
@end
static NSString *reuse_contactEditInfoCell = @"reusecontacteditinfocell";
@implementation EditContactInfo
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    setvisname = 1;
    self.navigationController.navigationBarHidden = YES;
    

    [self navtion];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    setvisname = 0;

}
-(void)navtion{
    
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    navtion.backgroundColor = RGB(246,246,246);
    UILabel *label = [[UILabel alloc]init];
    label.text = YZMsg(@"EditContactInfo_editMyConatct");
    //label.font = FNOT;
    [label setFont:[UIFont fontWithName:@"Heiti SC" size:14]];
    
    label.textColor = [UIColor blackColor];
    label.frame = CGRectMake(0, statusbarHeight,_window_width,84);
    // label.center = navtion.center;
    label.textAlignment = NSTextAlignmentCenter;
    [navtion addSubview:label];
    
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
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
    
    [self.view addSubview:navtion];
    
    
    UIButton *BtnSave = [[UIButton alloc] initWithFrame:CGRectMake(_window_width-60,24+statusbarHeight,60,40)];
    [BtnSave setTitle:YZMsg(@"public_Save") forState:UIControlStateNormal];
    [BtnSave setTitleColor:RGB_COLOR(@"#FE0B78", 1) forState:0];
    BtnSave.titleLabel.font = [UIFont systemFontOfSize:14];
    [BtnSave addTarget:self action:@selector(contactInfoSave) forControlEvents:UIControlEventTouchUpInside];
    
    [navtion addSubview:BtnSave];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];

}
-(void)doReturn{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    float NavHeight = 64 + statusbarHeight;//包涵通知栏的20px
    self.view.backgroundColor = RGB(244, 245, 246);
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, NavHeight, _window_width, _window_height - NavHeight)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    [backView addSubview:self.tb_contact];
    self.app_list = [Config getAppList];
    /*
    input = [[UITextField alloc] init];
    
    input.frame = CGRectMake(20,0,_window_width-40, 50);
    input.layer.cornerRadius = 3;
    input.font = fontThin(15);

    input.delegate =self;
    input.layer.masksToBounds = YES;
    
    NSString *contact_info = [Config getOwnContactInfo];
    if(!contact_info || contact_info.length == 0){
        input.text = YZMsg(@"EditContactInfo_Empty");
    }else{
        input.text = contact_info;
    }
    
    
    [input setBackgroundColor:[UIColor whiteColor]];
    input.clearButtonMode = UITextFieldViewModeAlways;
    [backView addSubview:input];
    UILabel *lab = [[UILabel alloc] init];
    lab.text = YZMsg(@"EditContactInfo_inputTip");
    lab.font = fontThin(11);

    [lab setTextColor:[UIColor colorWithRed:45.0/255 green:45.0/255 blue:45.0/255 alpha:1]];
    lab.frame = CGRectMake(20, backView.bottom, 200, 20);
    [self.view addSubview:lab];
    
   
    [input becomeFirstResponder];
     */
}

-(void)contactInfoSave
{
    dispatch_group_t saveGroup = dispatch_group_create();
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    testActivityIndicator.center = self.view.center;
    [self.view addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor blackColor];
    [testActivityIndicator startAnimating]; // 开始旋转
    __block BOOL isSuccess = YES;
    WeakSelf
    for (int i = 0; i < self.app_list.count; i++) {
        LiveAppItem *app = self.app_list[i];
        NSString *url = [NSString stringWithFormat:@"User.saveContact&uid=%@&token=%@&contact=%@&id=%@",[Config getOwnID],[Config getOwnToken],app.info,app.id];
        /*
        NSString *url = [NSString stringWithFormat:@"User.saveContact"];
        NSDictionary *dic = @{
            @"uid":[Config getOwnID],
            @"token":[Config getOwnToken],
            @"contact":app.info,
            @"id":app.id
        };
         */
        dispatch_group_enter(saveGroup);
        [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:YES andParameter:nil  data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            dispatch_group_leave(saveGroup);
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (code == 0) {
                [[NSNotificationCenter defaultCenter]postNotificationName:KGetBaseInfoNotification object:nil];
            }else{
                isSuccess = NO;
                if(msg){
                    [MBProgressHUD showError:minstr(msg)];
                }
            }
        } fail:^(NSError * _Nonnull error) {
            isSuccess = NO;
            dispatch_group_leave(saveGroup);
        }];
    };
    dispatch_group_notify(saveGroup, dispatch_get_main_queue(), ^{
        STRONGSELF
        //本地更新联系方式
        if (isSuccess) {
            LiveUser *user = [Config myProfile];
            user.app_list = strongSelf.app_list;
            [Config updateProfile:user];
        }
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
        [strongSelf.navigationController popViewControllerAnimated:YES];
    });
    
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.app_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactEditInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_contactEditInfoCell forIndexPath:indexPath];
    cell.app = self.app_list[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*
    if (textField == input) {
        
        if (input.text.length > 20)
        {
            
            [MBProgressHUD showError:@"字太多啦~"];

            return NO;
        }
    }
    */
    return YES;
}


- (UITableView *)tb_contact{
    if (!_tb_contact) {
        float NavHeight = 64 + statusbarHeight;
        _tb_contact = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height - NavHeight) style:UITableViewStylePlain];
        _tb_contact.backgroundColor = RGB(244, 245, 246);
        _tb_contact.delegate = self;
        _tb_contact.dataSource = self;
        _tb_contact.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tb_contact registerNib:[UINib nibWithNibName:@"ContactEditInfoCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellReuseIdentifier:reuse_contactEditInfoCell];
    }
    return _tb_contact;
}

@end
