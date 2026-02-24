//
//  SwitchLotteryViewController.m
//
//

#import "SwitchLotteryViewController.h"
#import "LotteryCollectionViewCell.h"
#import "LotteryBetViewController.h"
#import "LotteryBetViewController_NN.h"
#import "ChipSwitchViewController.h"
#import "BetConfirmViewController.h"
#import "GameHomeMainVC.h"
#import "LotteryBetViewController_YFKS.h"
#import "UIImageView+WebCache.h"
#import "LotteryBetViewController_BJL.h"
#import "LotteryBetViewController_ZP.h"
#import "LotteryBetViewController_LB.h"
#import "LotteryBetViewController_ZJH.h"
#import "LotteryBetViewController_LH.h"
#import "LotteryBetViewController_SC.h"
#import "LotteryBetViewController_LHC.h"
#import "LotteryBetViewController_SSC.h"
#import "LotteryBetViewController_NNN.h"
#import "LotteryBetViewController_Fullscreen.h"
#import "LotteryBetHallVC.h"
#import "LobbyLotteryVC_New.h"
#import "LobbyLotteryVC.h"
#import <UMCommon/UMCommon.h>
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kLotteryCollectionViewCell @"LotteryCollectionViewCell"
#define kImageDefaultName @"tempShop2"
@protocol GameFooter <NSObject>
- (void)doExitView;
@end
@interface GameFooter : UIView

@property(nonatomic,strong)UIButton *exitButton;
@property(nonatomic,weak)id <GameFooter> delegate;

@end
@implementation GameFooter
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self createSubView];
    }
    return self;
}
- (void)createSubView{
    self.backgroundColor = [UIColor clearColor];
    self.exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.exitButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.68];
    self.exitButton.layer.cornerRadius = AD(6);
    self.exitButton.layer.masksToBounds = YES;
    self.exitButton.frame = CGRectMake(0, 7, self.width, 44);
    [self.exitButton setTitle:YZMsg(@"public_cancel") forState:UIControlStateNormal];
    [self.exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.exitButton.titleLabel.font = [UIFont systemFontOfSize:AD(18) weight:UIFontWeightRegular];
    [self.exitButton addTarget:self action:@selector(clickExit:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.exitButton];
}
- (void)clickExit:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(doExitView)]) {
        [self.delegate doExitView];
    }
}
@end
@protocol GameHeader <NSObject>

-(void)doSelectLottry:(NSInteger)gameTag gameName:(NSString *)gameName;
@end
@interface GameHeader : UIView
@property(weak,nonatomic)id <GameHeader> delegate;
@property (nonatomic,assign)BOOL isFromGameCenter;
@end

@implementation GameHeader

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self createSubView];
    }
    return self;
}
- (void)createSubView{
    [self createGameContent];
}
- (void)reloadData{
    if (self.subviews.count > 0) {
        for (UIView *sb in self.subviews) {
            [sb removeFromSuperview];
        }
    }
    [self createGameContent];
}
- (void)createGameContent {
    NSArray *game_list = [common getlotteryc];

    NSInteger gameCount = game_list.count;
    int numPreLine = 4;
    CGFloat trim_space = 23; // 前后留空
    CGFloat gap = 30;
    CGFloat btnWidth = (SCREEN_WIDTH - 25 - trim_space * 2 - (numPreLine - 1) * gap) / numPreLine;
    CGFloat btnHeight = btnWidth + 11.5 + 12.5 + 10;

    if (gameCount > 0) {
        NSInteger numRows = (gameCount + numPreLine - 1) / numPreLine;
        CGFloat avgH = numRows * btnHeight;

        UIView *games = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 25, avgH)];
        games.backgroundColor = [UIColor colorWithWhite:0 alpha:0.68];
        games.layer.cornerRadius = 6;
        games.layer.masksToBounds = YES;
        games.userInteractionEnabled = YES;
        [self addSubview:games];

        if (gameCount <= 0) {
            games.hidden = YES;
        } else {
            games.hidden = NO;
        }

        for (int i = 0; i < gameCount; i++) {
            CGFloat x = trim_space + (i % numPreLine) * (btnWidth + gap);
            CGFloat y = 10+(i / numPreLine) * btnHeight;

            NSDictionary *_game = game_list[i];
            if (_isFromGameCenter && [_game[@"lotteryType"] integerValue] == 0) {
                continue;
            }
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(x, y, btnWidth, btnWidth);
            btn.tag = [_game[@"lotteryType"] integerValue];
            btn.titleLabel.text = _game[@"name"];
            btn.userInteractionEnabled = YES;
            [btn addTarget:self action:@selector(jumpGame:) forControlEvents:UIControlEventTouchUpInside];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [btn sd_setImageWithURL:[NSURL URLWithString:_game[@"logo"]] forState:UIControlStateNormal placeholderImage:GamePlaceholdImage];
            [games addSubview:btn];

            UILabel *labTitle1 = [[UILabel alloc] initWithFrame:CGRectMake(x - 10, CGRectGetMaxY(btn.frame) + 1, btnWidth + 20, 20)];
            [labTitle1 setFont:[UIFont systemFontOfSize:13.0]];
            labTitle1.adjustsFontSizeToFitWidth = YES;
            labTitle1.minimumScaleFactor = 0.5;
            labTitle1.numberOfLines = 2;
            labTitle1.textAlignment = NSTextAlignmentCenter;
            [labTitle1 setTextColor:[UIColor whiteColor]];
            [labTitle1 setText:_game[@"name"]];
            [games addSubview:labTitle1];
        }
    }
}


- (void)jumpGame:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(doSelectLottry:gameName:)]) {
        [self.delegate doSelectLottry:sender.tag gameName: sender.titleLabel.text];
    }
}
@end

@interface SwitchLotteryViewController ()<UITableViewDelegate,UITableViewDataSource,GameHeader,GameFooter>{
    UIActivityIndicatorView *testActivityIndicator;//菊花
    
    NSMutableArray *allData;
    BOOL bUICreated; // UI是否创建
    UIViewController *lottery;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabHeightConstraint;

@property (nonatomic,strong)GameHeader *header;
@property (nonatomic,strong)GameFooter *footer;
@end

@implementation SwitchLotteryViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"moneyChange" object:nil];
    [self getInfo];
    self.view.bottom = 2 * _window_height;
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        //        self.view.frame = f;
        strongSelf.view.bottom = _window_height;
    } completion:^(BOOL finished) {
        STRONGSELF
        [NSNotificationCenter.defaultCenter postNotificationName:KLiveCanScrollNotification object:@0];
        if (strongSelf == nil) {
            return;
        }
        // 监听阴影层点击事件
        /*
        UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc]initWithTarget:strongSelf action:@selector(exitView)];
        [strongSelf.view addGestureRecognizer:myTap];
         */
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.navigationItem.title = @"投注中心";
    
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
  
    
    // 菊花
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    // testActivityIndicator.center = self.view.center;
//    testActivityIndicator.center = self.contentView.center;
    [self.view addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor whiteColor];
    [testActivityIndicator startAnimating]; // 开始旋转
    [testActivityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}
-(void)exitView{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.bottom = 2 *_window_height;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)getInfo{
    NSString * type = @"live";
    if(self.isFromGameCenter){
        type = @"lobby";
    }
    

    if ([common getlotteryc]) {
        allData =[NSMutableArray arrayWithArray:[common getlotteryc]];
        [testActivityIndicator stopAnimating]; // 结束旋转
        [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        [self refreshUI];
        NSString *userBaseUrl = [NSString stringWithFormat:@"Lottery.getLotteryList&uid=%@&token=%@&type=%@",[Config getOwnID],[Config getOwnToken],type];
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if(code == 0)
            {
                NSDictionary *dict = [info firstObject];
                strongSelf->allData = dict[@"lotteryList"];;
                [common savelotterycontroller:strongSelf->allData];
                dispatch_main_async_safe(^{
                    [strongSelf refreshUI];
                });
            }
            
        } fail:^(NSError * _Nonnull error) {
           
        }];
    }else{
        
        NSString *userBaseUrl = [NSString stringWithFormat:@"Lottery.getLotteryList&uid=%@&token=%@&type=%@",[Config getOwnID],[Config getOwnToken],type];
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            NSLog(@"xxxxxxxxx%@",info);
            [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
            [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
            if(code == 0)
            {
                // test code start
    //            NSString *dataStr = @"{\"name\":\"一分时时彩\",\"logo\":\"http://qd.bzkebzs.cn/logo_circle/620.png\",\"status\":0,\"left_time\":53,\"left_coin\":10,\"last_result\":[{\"bg\":\"http://www.baidu.com/red\",\"showString\":\"1\"}],\"bet_type\":[{\"name\":\"个位\",\"options\":[{\"name\":\"大\",\"rate\":\"1.97\",\"id\":1},{\"name\":\"小\",\"rate\":\"1.97\",\"id\":2}]},{\"name\":\"龙虎万千\",\"options\":[{\"name\":\"龙\",\"rate\":\"2.17\",\"id\":3},{\"name\":\"虎\",\"rate\":\"2.17\",\"id\":4},{\"name\":\"和\",\"rate\":\"9.97\",\"id\":5}]},{\"name\":\"十位\",\"options\":[{\"name\":\"单\",\"rate\":\"2.17\",\"id\":6},{\"name\":\"双\",\"rate\":\"2.17\",\"id\":7}]}]}";
    //            NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];//转化为data
    //            NSArray *info = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];//转化为字典
                // test code end
                
                NSLog(@"%@",info);
                NSDictionary *dict = [info firstObject];
                strongSelf->allData = dict[@"lotteryList"];;
                [common savelotterycontroller:strongSelf->allData];
                
                dispatch_main_async_safe(^{
                    [strongSelf refreshUI];
                });
            }
            else{
                strongSelf->allData = [NSMutableArray arrayWithArray:[common getlotteryc]];
                dispatch_main_async_safe(^{
                    [strongSelf refreshUI];
                });
            }
            
        } fail:^(NSError * _Nonnull error) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
            [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
            strongSelf->allData = [NSMutableArray arrayWithArray:[common getlotteryc]];
            dispatch_main_async_safe(^{
                [strongSelf refreshUI];
            });
        }];
    }
   
    
}

-(void)refreshUI{
   
    if(!bUICreated){
        [self initUI];
    }else{
        [self.header reloadData];
    }
    
}

-(void)initUI{
    bUICreated = true;
    
    // 初始化投注选项
    //[self initCollection];
    
    [self initTableView];
}

- (void)initTableView{
    NSArray *ad_list = [common getlotteryc];

    NSInteger gameCount = ad_list.count;
    int numPreLine = 4;
    CGFloat avgW = 0;
    CGFloat avgH = 0;
    CGFloat trim_space = 23; // 前后留空
    CGFloat gap = 10;

    if (gameCount > 0) {
        avgW = (SCREEN_WIDTH-25 - trim_space * 2 - (numPreLine - 1) * gap) / numPreLine;
        avgH = ceil(gameCount*1.0 / numPreLine) * (avgW + 11.5 + 12.5 + 10);
    }
    self.view.userInteractionEnabled = true;
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doExitView)];
    [self.view addGestureRecognizer:tapG];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"livegamecellreuse"];
    self.header = [[GameHeader alloc] initWithFrame:CGRectMake(0, 0, _window_width - 25, avgH-ceil(gameCount*1.0 / numPreLine)*15)];
    self.header.isFromGameCenter = self.isFromGameCenter;
    self.footer = [[GameFooter alloc] initWithFrame:CGRectMake(0, 0, _window_width - 25, 51)];
    self.header.delegate = self;
    self.footer.delegate = self;
    self.tableView.tableHeaderView = self.header;
    self.tableView.tableFooterView = self.footer;
    self.tabHeightConstraint.constant = 51+avgH;
    [self.header reloadData];
}

-(void)doSelectLottry:(NSInteger)gameTag gameName:(NSString *)gameName {
    self.gameTag = gameTag;
    
    if (_isFromGameCenter) {
       
        if((gameTag == 26 || gameTag == 27) && ![YBToolClass sharedInstance].default_old_view){
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            VC.lotteryDelegate = self.lotteryDelegate;
            [VC setLotteryType:gameTag];
            [self.navigationController pushViewController:VC animated:YES];
        }else if(gameTag == 14 && ![YBToolClass sharedInstance].default_oldSC_view){
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            VC.lotteryDelegate = self.lotteryDelegate;
            [VC setLotteryType:gameTag];
            [self.navigationController pushViewController:VC animated:YES];
        }else if(gameTag == 28 && ![YBToolClass sharedInstance].default_oldBJL_view){
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            VC.lotteryDelegate = self.lotteryDelegate;
            [VC setLotteryType:gameTag];
            [self.navigationController pushViewController:VC animated:YES];
        }else if(gameTag == 29 && ![YBToolClass sharedInstance].default_oldZJH_view){
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            VC.lotteryDelegate = self.lotteryDelegate;
            [VC setLotteryType:gameTag];
            [self.navigationController pushViewController:VC animated:YES];
        }else if(gameTag == 30 && ![YBToolClass sharedInstance].default_oldZP_view){
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            VC.lotteryDelegate = self.lotteryDelegate;
            [VC setLotteryType:gameTag];
            [self.navigationController pushViewController:VC animated:YES];
        }else if(gameTag == 31 && ![YBToolClass sharedInstance].default_oldLH_view){
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            VC.lotteryDelegate = self.lotteryDelegate;
            [VC setLotteryType:gameTag];
            [self.navigationController pushViewController:VC animated:YES];
        }else if (gameTag == 32 ||gameTag == 7 || gameTag == 8 || gameTag == 6 || gameTag == 11){
            LobbyLotteryVC_New *VC = [[LobbyLotteryVC_New alloc]initWithNibName:@"LobbyLotteryVC_New" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            VC.lotteryDelegate = self.lotteryDelegate;
            [VC setLotteryType:gameTag];
            [self.navigationController pushViewController:VC animated:YES];
        }else{
            LotteryBetViewController_Fullscreen * VC = [[LotteryBetViewController_Fullscreen alloc]initWithNibName:@"LotteryBetViewController_Fullscreen" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            VC.lotteryDelegate = self.lotteryDelegate;
            [VC setLotteryType: gameTag];
            [self.navigationController pushViewController:VC animated:YES];
        }
        NSMutableArray *subVCs = [NSMutableArray arrayWithArray:[[MXBADelegate sharedAppDelegate] navigationViewController].viewControllers];
        UIViewController *VCLast = nil;
        for (int i=0; i<subVCs.count-1; i++) {
            UIViewController *viewVC = subVCs[i];
            if ([viewVC isKindOfClass:[LotteryBetViewController_Fullscreen class]]||
                [viewVC isKindOfClass:[LobbyLotteryVC_New class]]||
                [viewVC isKindOfClass:[LotteryBetHallVC class]]) {
                [viewVC performSelector:@selector(releaseView)];
                VCLast = viewVC;
            }
        }
        if (VCLast==nil) {
            if ([_lotteryDelegate isKindOfClass:[UIViewController class]]) {
                subVCs = [NSMutableArray arrayWithArray:((UIViewController*)_lotteryDelegate).navigationController.viewControllers];
                for (int i=0; i<subVCs.count-1; i++) {
                   UIViewController *viewVC = subVCs[i];
                    if ([viewVC isKindOfClass:[LotteryBetViewController_Fullscreen class]]||
                        [viewVC isKindOfClass:[LobbyLotteryVC_New class]]||
                        [viewVC isKindOfClass:[LotteryBetHallVC class]]) {
                        [viewVC performSelector:@selector(releaseView)];
                        VCLast = viewVC;
                    }
                }
            }
        }
        
        if (VCLast!= nil) {
            [subVCs removeObject:VCLast];
        }
        if ([_lotteryDelegate isKindOfClass:[UIViewController class]]) {
            ((UIViewController*)_lotteryDelegate).navigationController.viewControllers = subVCs;
        }else{
            [[MXBADelegate sharedAppDelegate] navigationViewController].viewControllers = subVCs;
        }
       
    }
    else {
        if(gameTag == 0){
            [GameToolClass setCurGameCenterDefaultType:@"lottery"];
            GameHomeMainVC *VC = [[GameHomeMainVC alloc] init];
            [self.navigationController pushViewController:VC animated:YES];
            lottery = nil;
    //        [GameToolClass enterGame:@"ky" kindID:@"0" autoExchange:[common getAutoExchange] success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
    //
    //        } fail:^{
    //
    //        }];
        }else{
            CGFloat height = LotteryWindowNewHeigh;
            if(BetType(gameTag) == LotteryBetTypeNN){
                if ([YBToolClass sharedInstance].default_oldNN_view) {
                    lottery = (LotteryBetViewController*)[[LotteryBetViewController_NN alloc]initWithNibName:@"LotteryBetViewController_NN" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                    height = LotteryWindowOldNNHeigh;
                    ((LotteryBetViewController_NN*)lottery).lotteryDelegate = self.lotteryDelegate;
                } else {
                    lottery = (LotteryBetViewController*)[[LotteryBetViewController_NNN alloc]initWithNibName:@"LotteryBetViewController_NNN" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                    height = LotteryWindowOldNNHeigh;
                    ((LotteryBetViewController_NN*)lottery).lotteryDelegate = self.lotteryDelegate;
                }
            }else if(BetType(gameTag) == LotteryBetTypeYFKS && ![YBToolClass sharedInstance].default_old_view){
                lottery = (LotteryBetViewController*)[[LotteryBetViewController_YFKS alloc]initWithNibName:@"LotteryBetViewController_YFKS" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                height = LotteryWindowNewHeighYFKS;
                ((LotteryBetViewController_YFKS*)lottery).lotteryDelegate = self.lotteryDelegate;
            }else if(BetType(gameTag) == LotteryBetTypeBJL && ![YBToolClass sharedInstance].default_oldBJL_view){
                lottery = (LotteryBetViewController*)[[LotteryBetViewController_BJL alloc]initWithNibName:@"LotteryBetViewController_BJL" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                height = LotteryWindowNewHeighBJL;
                ((LotteryBetViewController_BJL*)lottery).lotteryDelegate = self.lotteryDelegate;
            }else if(BetType(gameTag) == LotteryBetTypeZP && ![YBToolClass sharedInstance].default_oldZP_view){
                lottery = (LotteryBetViewController*)[[LotteryBetViewController_ZP alloc]initWithNibName:@"LotteryBetViewController_ZP" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                height = LotteryWindowNewHeighZP;
                ((LotteryBetViewController_ZP*)lottery).lotteryDelegate = self.lotteryDelegate;
            }else if(BetType(gameTag) == LotteryBetTypeZJH && ![YBToolClass sharedInstance].default_oldZJH_view){
                //0-0
                lottery = (LotteryBetViewController*)[[LotteryBetViewController_ZJH alloc]initWithNibName:@"LotteryBetViewController_ZJH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                ((LotteryBetViewController_ZJH*)lottery).lotteryDelegate = self.lotteryDelegate;
                height = LotteryWindowNewHeighZJH;
            }else if(BetType(gameTag) == LotteryBetTypeLH && ![YBToolClass sharedInstance].default_oldLH_view){
                lottery = (LotteryBetViewController*)[[LotteryBetViewController_LH alloc]initWithNibName:@"LotteryBetViewController_LH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                ((LotteryBetViewController_ZJH*)lottery).lotteryDelegate = self.lotteryDelegate;
                height = LotteryWindowNewHeighLH;
            }else if(BetType(gameTag) == LotteryBetTypeLB){
                lottery = (LotteryBetViewController*)[[LotteryBetViewController_LB alloc]initWithNibName:@"LotteryBetViewController_LB" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                ((LotteryBetViewController_LB*)lottery).lotteryDelegate = self.lotteryDelegate;
            }else if(BetType(gameTag) == LotteryBetTypeSC && ![YBToolClass sharedInstance].default_oldSC_view){
                height = LotteryWindowNewHeighSC;
                lottery = (LotteryBetViewController*)[[LotteryBetViewController_SC alloc]initWithNibName:@"LotteryBetViewController_SC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                ((LotteryBetViewController_SC*)lottery).lotteryDelegate = self.lotteryDelegate;
            }else if(BetType(gameTag) == LotteryBetTypeLHC && ![YBToolClass sharedInstance].default_oldLHC_view){
                height = LotteryWindowNewHeighLHC;
                lottery = (LotteryBetViewController*)[[LotteryBetViewController_LHC alloc]initWithNibName:@"LotteryBetViewController_LHC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                ((LotteryBetViewController_LHC*)lottery).lotteryDelegate = self.lotteryDelegate;
            }else if(BetType(gameTag) == LotteryBetTypeSSC && ![YBToolClass sharedInstance].default_oldSSC_view){
                height = LotteryWindowNewHeighSSC;
                lottery = (LotteryBetViewController*)[[LotteryBetViewController_SSC alloc]initWithNibName:@"LotteryBetViewController_SSC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                ((LotteryBetViewController_SSC*)lottery).lotteryDelegate = self.lotteryDelegate;
            }else{
                height = LotteryWindowOldHeigh;
                lottery = [[LotteryBetViewController alloc]initWithNibName:@"LotteryBetViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                ((LotteryBetViewController*)lottery).lotteryDelegate = self.lotteryDelegate;
            }
            [(LotteryBetViewController *)lottery setLotteryType:gameTag];
            [YBToolClass sharedInstance].lotteryLiveWindowHeight = height+ShowDiff;
            
            if (self.parentViewController) {
                [self.parentViewController.view addSubview:lottery.view];
                [self.parentViewController addChildViewController:lottery];
            }else{
                [self.view addSubview:lottery.view];
                [self addChildViewController:lottery];
            }
            lottery.view.frame = CGRectMake(0, SCREEN_HEIGHT-height-ShowDiff, SCREEN_WIDTH, height+ShowDiff);
            
        }
    }
    
    
    [self exitView];
    if ([self.lotteryDelegate  respondsToSelector:@selector(setCurlotteryVC:)]) {
        lottery.navigationItem.title = gameName;
        [self.lotteryDelegate setCurlotteryVC:(LotteryBetViewController *)lottery];
        
        if (lottery==nil) {
            NSDictionary *dict = @{ @"eventType": @(0),
                                    @"game_name": gameName};
            [MobClick event:@"live_room_game_name_click" attributes:dict];
        }
       
    }
    
}
- (void)doExitView{
    [NSNotificationCenter.defaultCenter postNotificationName:KLiveCanScrollNotification object:@1];
    [self exitView];
}
-(void)lotteryCancless
{
    lottery = nil;
}

#pragma mark - tableView -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"livegamecellreuse" forIndexPath:indexPath];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
///                       -----------------------------------------------------------------------------------------                             ///
//- (UIImage *)createImageWithColor:(UIColor *)color rect:(CGRect)rect radius:(float)radius {
//    //设置长宽
////    CGRect rect = rect;//CGRectMake(0.0f, 0.0f, 80.0f, 30.0f);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    UIImage *original = resultImage;
//    CGRect frame = CGRectMake(0, 0, original.size.width, original.size.height);
//    // 开始一个Image的上下文
//    UIGraphicsBeginImageContextWithOptions(original.size, NO, 1.0);
//    // 添加圆角
//    [[UIBezierPath bezierPathWithRoundedRect:frame
//                                cornerRadius:radius] addClip];
//    // 绘制图片
//    [original drawInRect:frame];
//    // 接受绘制成功的图片
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}

-(void)getPoolDataInfo{
    if(lottery  && [((LotteryBetViewController_LB*)lottery) respondsToSelector:@selector(getPoolDataInfo)] ){
        [((LotteryBetViewController_LB*)lottery) getPoolDataInfo];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
