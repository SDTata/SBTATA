//
//  TopTodayView.m
//  phonelive
//
//  Created by 400 on 2020/7/28.
//  Copyright © 2020 toby. All rights reserved.
//

#import "TopTodayView.h"
#import "TopTodayCell.h"
#import "NSDate+BRPickerView.h"
#import "Config.h"
#import "UIImageView+WebCache.h"
typedef void (^CallbackView)(void);

@interface TopTodayView()<UITableViewDelegate,UITableViewDataSource>
{
    TopTodayModel *modelCurrent;
    NSTimer *hartTimer;
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftSendConstriant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftConstriantR;
@property (weak, nonatomic) IBOutlet UILabel *topTodayTitleLabel;


@end

@implementation TopTodayView

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.topTodayTitleLabel.text = YZMsg(@"TopTodayView_title");
    self.lastUpdateTimeLabel.text = [NSString stringWithFormat:@"%@",YZMsg(@"TopTodayView_update_time_title")];
    [self.giftSendButton setTitle:YZMsg(@"TopTodayView_SendGift") forState:UIControlStateNormal];
    self.giftSendButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.giftSendButton.titleLabel.minimumScaleFactor = 0.2;
    hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:20];
    if (!hartTimer) {
        hartTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getRequestData) userInfo:nil repeats:YES];
    }
    //绘制圆角 要设置的圆角 使用“|”来组合
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, 50) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    //设置大小
    maskLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    //设置图形样子
    maskLayer.path = maskPath.CGPath;
    self.topView.layer.mask = maskLayer;
    self.giftSendButton.layer.cornerRadius = 5;
    self.giftSendButton.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 25;
    self.avatarImageView.layer.masksToBounds = YES;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [UIView new];
    [self getRequestData];
}


- (IBAction)sendAction:(id)sender {
    
    [self endView:^{
        if (self.delegate) {
            [self.delegate sendGiftAction];
        }
    }];
    
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endView:^{
        
    }];
}
-(void)endView:(CallbackView)callbacl{
    if (hartTimer) {
        [hartTimer invalidate];
        hartTimer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.top = SCREEN_HEIGHT;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf removeFromSuperview];
        callbacl();
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datasArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    TopTodayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopTodayCell"];
    if (!cell) {
        cell = [[[XBundle currentXibBundleWithResourceName:@"TopTodayCell"] loadNibNamed:@"TopTodayCell" owner:nil options:nil] lastObject];
    }
    cell.model = self.datasArray[indexPath.row];
    [cell updateIsFirst:indexPath.row == 0];
    return cell;
}
-(NSArray<TopTodayModel*>*)datasArray
{
    if (_datasArray == nil) {
        _datasArray = [NSArray array];
    }
    return _datasArray;
}


-(void)getRequestData
{
    self.lastUpdateTimeLabel.text = [NSString stringWithFormat:@"%@%@",YZMsg(@"TopTodayView_update_time_title"),[NSDate br_getDateString:[NSDate date] format:@"yyyy-MM-dd HH:mm:ss"]];
    
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getDayGiftRank" withBaseDomian:YES andParameter:@{@"uid":[Config getOwnID],@"token":[Config getOwnToken]} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if(strongSelf == nil)
        {
            return;
        }
        [strongSelf->hud hideAnimated:YES];
        if (code == 0) {
            if ([info isKindOfClass:[NSArray class]]&& ((NSArray*)info).count > 0) {
                info = [(NSArray*)info firstObject];
            }
            NSArray *infoArray = [info objectForKey:@"data"];
            NSMutableArray<TopTodayModel*> *datas = [NSMutableArray array];
            if([infoArray isKindOfClass:[NSArray class]])
            {
                for (int i= 0;i<infoArray.count;i++) {
                    NSDictionary *subDic = infoArray[i];
                    TopTodayModel *model = [TopTodayModel mj_objectWithKeyValues:subDic];
                    model.index = i;
                    if ([model.uid isEqualToString:minstr(strongSelf.model.zhuboID)]) {
                        if (datas.count>0) {
                            model.numberLast =model.coin;
                        }else{
                            model.numberLast = nil;
                        }
                        
                        strongSelf->modelCurrent = model;
                    }
                    [datas addObject:model];
                }
            }
            if (strongSelf->modelCurrent == nil) {
                strongSelf->modelCurrent = [TopTodayModel new];
                if (strongSelf.model == nil) {
                    strongSelf->modelCurrent.coin = nil;
                    strongSelf->modelCurrent.index = datas.count;
                    strongSelf->modelCurrent.name = [Config getOwnNicename];
                    strongSelf->modelCurrent.uid = [Config getOwnID];
                    strongSelf->modelCurrent.photo = [Config getavatarThumb];
                    strongSelf->modelCurrent.numberLast = datas.lastObject.coin;
                }else{
                    strongSelf->modelCurrent.coin = nil;
                    strongSelf->modelCurrent.index = datas.count;
                    strongSelf->modelCurrent.name = strongSelf.model.zhuboName;
                    strongSelf->modelCurrent.uid = strongSelf.model.zhuboID;
                    strongSelf->modelCurrent.photo = strongSelf.model.zhuboIcon;
                    strongSelf->modelCurrent.numberLast = datas.lastObject.coin;;
                }
            }
            [strongSelf updatcurrentModel:strongSelf->modelCurrent];
            strongSelf.datasArray = datas;
            [strongSelf.tableView reloadData];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if(strongSelf == nil)
        {
            return;
        }
        [strongSelf->hud hideAnimated:YES];
    }];
}

+(TopTodayView*)showInView:(UIView *)superView model:(nullable hotModel*)model delegate:(nullable id)delegate
{
    TopTodayView *todayTopView = [[[XBundle currentXibBundleWithResourceName:@"TopTodayView"] loadNibNamed:@"TopTodayView" owner:nil options:nil] lastObject];
    if (todayTopView) {
        todayTopView.frame = CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        todayTopView.model = model;
        todayTopView.delegate = delegate;
        [superView addSubview:todayTopView];
        [UIView animateWithDuration:0.25 animations:^{
            todayTopView.top = 0;
        } completion:^(BOOL finished) {
            
        }];
        if (model == nil) {
            todayTopView.giftSendButton.hidden = YES;
            todayTopView.giftConstriantR.constant = 0;
            todayTopView.giftSendConstriant.constant = 0;
            
        }
    }
    return todayTopView;
}

-(void)updatcurrentModel:(TopTodayModel*)model
{
    self.currentUserLevelabel.text = model?minnum(model.index+1):minnum(self.datasArray.count+1);
    if (model.photo!=nil&&model.photo.length>0) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.photo] placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
    }
    self.nickNameLabel.text = model.name;
    if (model.numberLast!=nil && model.numberLast.length>0 && [model.numberLast doubleValue]>0.01) {
        NSString *currencyCoin = [YBToolClass getRateCurrency:minstr(model.numberLast) showUnit:YES];
        self.deslabel.text = [NSString stringWithFormat:@"%@%@",YZMsg(@"TopTodayView_LevelAlert_title"),currencyCoin];
    }else{
        self.deslabel.text = @"";
    }
    
    UIColor *color = [UIColor lightGrayColor];
    switch (model.index) {
        case 0:
            color = [UIColor redColor];
            break;
        case 1:
            color = [UIColor systemPinkColor];
            break;
        case 2:
            color = [UIColor lightGrayColor];
            break;
        case 3:
            color = [UIColor blackColor];
            break;
        default:
            break;
    }
    self.currentUserLevelabel.textColor = color;
}

@end

@implementation TopTodayModel


@end
