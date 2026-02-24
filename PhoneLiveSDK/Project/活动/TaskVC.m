//
//  TaskVC.m
//  phonelive
//
//  Created by 400 on 2020/9/21.
//  Copyright © 2020 toby. All rights reserved.
//

#import "TaskVC.h"
#import "UIView+Additions.h"
#import "TaskMenuCell.h"
#import "TaskModel.h"

#import "UIView+LBExtension.h"
@interface TaskVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,TaskJumpDelegate>

{
    
    NSInteger selectedIndexMenu;
    UIScrollView *scrollViewPage;
    BOOL isScrolling;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *topBackGroudView;
@property (weak, nonatomic) IBOutlet UICollectionView *menueCollectionView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantY;

//@property(nonatomic,retain)NSMutableArray *allData;

@property(nonatomic,retain)NSMutableDictionary *allDataDic;
@property(nonatomic,retain)NSMutableDictionary *allName_idDic;

@end

@implementation TaskVC
- (IBAction)closeAction:(UIButton *)sender {
    [self dismissView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.constantY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.6/2;
    
    self.titleLabel.text = YZMsg(@"taskTitleString");
    self.emptyLabel.text = YZMsg(@"taskEmptyString");
    
    self.allDataDic = [NSMutableDictionary dictionary];
    selectedIndexMenu = 0;
    self.bgView.layer.cornerRadius = 8;
    self.bgView.layer.masksToBounds = YES;
    [self.menueCollectionView registerNib:[UINib nibWithNibName:@"TaskMenuCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellWithReuseIdentifier:@"taskMenuIdenti"];
    self.menueCollectionView.delegate = self;
    self.menueCollectionView.dataSource = self;
    [self getTaskData];
    [self loadScrollView];
    // Do any additional setup after loading the view from its nib.
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
    NSString *userBaseUrl = [NSString stringWithFormat:@"User.getTaskList"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    self.emptyLabel.hidden = YES;
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        if(code == 0 && [info isKindOfClass:[NSArray class]] && [(NSArray*)info count]>0)
        {
            strongSelf.allDataDic = [NSMutableDictionary dictionary];
            NSArray *data = [((NSArray*)info).firstObject objectForKey:@"data"];
            if ([data isKindOfClass:[NSArray class]] && data.count>0) {
                for (NSDictionary *subDic in data) {
                    TaskModel *model = [TaskModel mj_objectWithKeyValues:subDic];
                    if (model.group && model.group.length>0) {
                        if (![strongSelf.allDataDic objectForKey:model.group]) {
                            NSMutableArray *array = [NSMutableArray array];
                            [array addObject:model];
                            [strongSelf.allDataDic setObject:array forKey:model.group];
                            if (strongSelf.allName_idDic == nil) {
                                strongSelf.allName_idDic = [NSMutableDictionary dictionary];
                            }
                            if (model.title_group_id && model.title_group_id.length>0) {
                                [strongSelf.allName_idDic setObject:model.group forKey:model.title_group_id];
                            }
                        }else{
                            NSMutableArray *array = [strongSelf.allDataDic objectForKey:model.group];
                            [array addObject:model];
                        }
                    }
                    
                }
            }
            [strongSelf.menueCollectionView reloadData];
            strongSelf->scrollViewPage.contentSize = CGSizeMake((SCREEN_WIDTH-30)*strongSelf.allDataDic.allKeys.count, strongSelf.contentView.height);
            
            [strongSelf showTaskAtIndex:0];
            if (strongSelf.allDataDic.allKeys.count < 1) {
                strongSelf.emptyLabel.hidden = NO;
            }
            if (strongSelf.titleGroupId!= nil) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    STRONGSELF
                    if (strongSelf == nil) {
                        return;
                    }
                    NSString *titleName = [strongSelf.allName_idDic objectForKey:strongSelf.titleGroupId];
                    if (titleName) {
                        NSInteger indexSelec = [strongSelf.allDataDic.allKeys indexOfObject:titleName];
                        if (indexSelec>0 && indexSelec<1000) {
                            [strongSelf selectedIndexGroup:indexSelec];
                        }
                    }
                });
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

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.allDataDic.allKeys.count;
}
//-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
////called when the user taps on an already-selected item in multi-select mode
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TaskMenuCell *cell = (TaskMenuCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"taskMenuIdenti" forIndexPath:indexPath];
    //cell.selectButton.titleLabel.textColor = [UIColor whiteColor];
    NSString *group = self.allDataDic.allKeys[indexPath.row];
   
    [cell.selectButton setTitle:group forState:UIControlStateNormal];
    [cell.selectButton addTarget:self action:@selector(buttonMenuAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (indexPath.row == selectedIndexMenu) {
        [cell.selectButton setTitleColor:RGB_COLOR(@"#FE298C", 1) forState:UIControlStateNormal];
        [cell setStatus:YES];
       // [cell.selectButton setBackgroundColor:RGB(231, 160, 110)];
    }else{
        [cell.selectButton setTitleColor:RGB_COLOR(@"#999999", 1) forState:UIControlStateNormal];
       // [cell.selectButton setBackgroundColor:[UIColor clearColor]];
        [cell setStatus:NO];
    }
    return cell;
}


-(void)buttonMenuAction:(UIButton*)button                      
{
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview;
    if ([cell isKindOfClass:[UICollectionViewCell class]]) {
        NSIndexPath *indexP = [self.menueCollectionView indexPathForCell:cell];
        NSLog(@"index:%ld",indexP.row);
        [self selectedIndexGroup:indexP.row];
    }
}


-(void)selectedIndexGroup:(NSInteger)indexCurrent{
    if (selectedIndexMenu == indexCurrent || isScrolling) {
//            [self scrollViewDidEndScroll:selectedIndexMenu];
        return;
    }
    selectedIndexMenu = indexCurrent;
    [self.menueCollectionView reloadData];
    [self showTaskAtIndex:selectedIndexMenu];
    //滚动到中间
    [scrollViewPage setContentOffset:CGPointMake(selectedIndexMenu*(SCREEN_WIDTH-30), 0) animated:YES];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf scrollViewDidEndScroll:strongSelf->selectedIndexMenu];
    });
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    
 
    NSString *group = self.allDataDic.allKeys[indexPath.row];
   
    CGSize size = [self boundingSizeWithString:group font:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium] constrainedToSize:CGSizeMake(1000, 30)];
    
    return CGSizeMake(size.width + 30, 30);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *group = self.allDataDic.allKeys[indexPath.row];
   
    CGSize size = [self boundingSizeWithString:group font:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium] constrainedToSize:CGSizeMake(1000, 30)];
    
    return CGSizeMake(size.width + 30, 30);
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.menueCollectionView]) {
        return;
    }
    NSInteger index = ((scrollView.contentOffset.x) /scrollView.width);
    
    CGFloat velocity = [scrollView.panGestureRecognizer velocityInView:scrollView].x;
    if (velocity < -0.1) {//左滚
        index  = index+1;
    } else if (velocity > 0.1) {//右边滚
        index  = index;
    }else{
        return;
    }
    
    if (selectedIndexMenu == index || index<0 || index>=self.allDataDic.allKeys.count) {
        return;
    }
    selectedIndexMenu = index;
    [self showTaskAtIndex:selectedIndexMenu];
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:scrollViewPage]) {
        isScrolling = YES;
    }
}
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:scrollViewPage]) {
        isScrolling = YES;
    }
}
-(void)showTaskAtIndex:(NSInteger)index
{
    
    if (self.allDataDic.allKeys.count>index && self.allDataDic.allKeys[index]!=nil) {
        TaskTableVC *tableTaskVC=[[TaskTableVC alloc]init];
        tableTaskVC.models = [self.allDataDic objectForKey:self.allDataDic.allKeys[index]];
        tableTaskVC.delelgate = self;
        tableTaskVC.tableView.tag = 100+index;
        [scrollViewPage addSubview:tableTaskVC.tableView];
        tableTaskVC.tableView.frame = CGRectMake(index*(SCREEN_WIDTH-30), 0, SCREEN_WIDTH-30, scrollViewPage.height);
        [self addChildViewController:tableTaskVC];
    }
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:scrollViewPage]) {
        // 停止类型1、停止类型2
        BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (scrollToScrollStop) {
            NSInteger index = (scrollView.contentOffset.x) /scrollView.width;
            [self scrollViewDidEndScroll:index];
        }
    }
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([scrollView isEqual:scrollViewPage]) {
        if (!decelerate) {
            // 停止类型3
            BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
            if (dragToDragStop) {
                NSInteger index = (scrollView.contentOffset.x) /scrollView.width;
                [self scrollViewDidEndScroll:index];
            }
        }
    }
}
#pragma mark - scrollView 滚动停止
- (void)scrollViewDidEndScroll:(NSInteger)index {
    selectedIndexMenu = index;
    NSLog(@"停止滚动了！！！");
    [self.menueCollectionView reloadData];
    
    [self.menueCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    BOOL repeat = NO;
    for (UIView *subView in scrollViewPage.subviews) {
        if ([subView isKindOfClass:[UITableView class]]) {
            if (subView.tag != selectedIndexMenu+100) {
                [subView removeFromSuperview];
                [subView.parentController removeFromParentViewController];
            }else{
                if (!repeat) {
                    repeat = YES;
                }else{
                    [subView removeFromSuperview];
                    [subView.parentController removeFromParentViewController];
                }
            }
        }
    }
    isScrolling = NO;
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
