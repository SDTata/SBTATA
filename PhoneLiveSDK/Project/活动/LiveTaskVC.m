//
//  TaskVC.m
//  phonelive
//
//  Created by 400 on 2020/9/21.
//  Copyright © 2020 toby. All rights reserved.
//

#import "LiveTaskVC.h"
#import "UIView+Additions.h"
#import "TaskModel.h"
#import "LiveTaskModel.h"

#import "UIView+LBExtension.h"
@interface LiveTaskVC ()<UIScrollViewDelegate,TaskJumpDelegate>
{
    UIScrollView *scrollViewPage;
    BOOL isScrolling;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *topBackGroudView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantY;

//@property(nonatomic,retain)NSMutableArray *allData;

@property(nonatomic,retain)NSMutableArray *allDataArr;

@end

@implementation LiveTaskVC
- (IBAction)closeAction:(UIButton *)sender {
    [self dismissView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.constantY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.6/2;
    self.titleLabel.text = YZMsg(@"livetaskTitleString");
    self.emptyLabel.text = YZMsg(@"taskEmptyString");
    self.bgView.layer.cornerRadius = 8;
    self.bgView.layer.masksToBounds = YES;
    self.allDataArr = [NSMutableArray array];
    [self getTaskData];
    [self loadScrollView];
}

-(void)loadScrollView
{
    scrollViewPage = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    scrollViewPage.delegate = self;
    scrollViewPage.pagingEnabled = YES;
    scrollViewPage.backgroundColor= [UIColor clearColor];
    scrollViewPage.contentSize = CGSizeMake(SCREEN_WIDTH-30, _contentView.height);
    [_contentView addSubview:scrollViewPage];
    [scrollViewPage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(0);
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.topBackGroudView.width = SCREEN_WIDTH-30;
    [self.topBackGroudView addGradientView:RGB_COLOR(@"#FF87E7", 1) endColor:RGB_COLOR(@"#FE278A", 1)];
    self.constantY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.6/2;
    [self.view layoutIfNeeded];
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.3 animations:^{
        self.constantY.constant = 0;
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissView];
}
-(void)dismissView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.constantY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.6/2;;
        self.view.backgroundColor = [UIColor clearColor];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}
-(void)getTaskData
{
    NSString *userBaseUrl = [NSString stringWithFormat:@"User.getLiveTaskList&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    self.emptyLabel.hidden = YES;
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        if(code == 0 && [info isKindOfClass:[NSArray class]]&& [(NSArray*)info count]>0)
        {
            strongSelf.allDataArr = [LiveTaskModel mj_objectArrayWithKeyValuesArray:info];
            strongSelf->scrollViewPage.contentSize = CGSizeMake((SCREEN_WIDTH-30), strongSelf.contentView.height);
            [strongSelf showTaskAtIndex:0];
            if (strongSelf.allDataArr.count < 1) {
                strongSelf.emptyLabel.hidden = NO;
            }
        }else{
            strongSelf.emptyLabel.hidden = NO;
        }
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.emptyLabel.hidden = NO;
        [hud hideAnimated:YES];
    }];
}

// text size
- (CGSize)boundingSizeWithString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGSize textSize = CGSizeZero;
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED && __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0)
    
    if (![string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        // below ios7
        textSize = [string sizeWithFont:font
                      constrainedToSize:size
                          lineBreakMode:NSLineBreakByWordWrapping];
    }
    else
#endif
    {
        //iOS 7
        CGRect frame = [string boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName:font } context:nil];
        textSize = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    
    return textSize;
}


-(void)showTaskAtIndex:(NSInteger)index
{
    TaskTableVC *tableTaskVC=[[TaskTableVC alloc]init];
    tableTaskVC.type = @"1";
    tableTaskVC.models = self.allDataArr;
    tableTaskVC.delelgate = self;
    tableTaskVC.tableView.tag = 100+index;
    [scrollViewPage addSubview:tableTaskVC.tableView];
    tableTaskVC.tableView.frame = CGRectMake(index*(SCREEN_WIDTH-30), 0, SCREEN_WIDTH-30, scrollViewPage.height);
    [self addChildViewController:tableTaskVC];
    
}

-(void)taskJumpWithTaskID:(NSInteger)taskID
{
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.constantY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.6/2;;
        strongSelf.view.backgroundColor = [UIColor clearColor];
        [strongSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf dismissViewControllerAnimated:NO completion:^{
            if (strongSelf.delelgate) {
                [strongSelf.delelgate taskJumpWithTaskID:taskID];
            }
        }];
       
    }];
    
}
@end
