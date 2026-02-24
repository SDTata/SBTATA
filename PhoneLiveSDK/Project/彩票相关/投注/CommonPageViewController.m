//
//  CommonPageViewController.m
//  XLPageViewControllerExample
//
//  Created by MengXianLiang on 2019/5/10.
//  Copyright © 2019 xianliang meng. All rights reserved.
//

#import "CommonPageViewController.h"
#import "CommonCollectionViewController2.h"
#import "XLPageViewController.h"

@interface CommonPageViewController ()<XLPageViewControllerDelegate,XLPageViewControllerDataSrouce>{
    CollectionShowMode showMode;
}

@property (nonatomic, strong) XLPageViewController *pageViewController;

@end

@implementation CommonPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self initPageViewController];
    [self refreshTitle];
}

- (void)refreshTitle{
    NSArray *options = self.way[@"options"];
    NSMutableArray *titles = [NSMutableArray array];
    
    showMode = CollectionShowMode_NOTITLE;
    if(self.way[@"mutx"]){
        NSInteger maxCount = options.count;
        for (int i = 0; i < maxCount; i++) {
            NSDictionary *dict = options[i];
            if(dict[@"name"]){
                showMode = CollectionShowMode_NORMAL;
                [titles addObject:dict[@"st"]];
            }
        }
    }else{
        [titles addObject:YZMsg(@"CommonPageVC_notitle")];
    }
    
//    if(showMode == CollectionShowMode_NOTITLE){
//        [titles addObject:@"无标题"];
//    }
    self.titles = titles;
}

- (void)initPageViewController {
    XLPageViewControllerConfig *config = [XLPageViewControllerConfig defaultConfig];
    config.shadowLineColor = UIColor.whiteColor;
    config.titleSelectedColor = UIColor.whiteColor;
    config.titleNormalColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
    self.config = config;
    self.pageViewController = [[XLPageViewController alloc] initWithConfig:self.config];
    self.pageViewController.view.frame = self.view.bounds;
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    self.pageViewController.view.backgroundColor = UIColor.clearColor;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
}

- (void)setCurrentWay:(NSDictionary *)way{
    self.way = way;
    NSMutableArray *arr = [NSMutableArray array];
    if([self isSpecial2]){
        // 赛车结构 转成通用结构
        id dcit = self.way[@"options"];
        if([dcit isKindOfClass:[NSDictionary class]]){
            NSArray *values = [dcit allValues];
            NSArray *keys = [dcit allKeys];
            for (int i = 0; i < keys.count; i ++) {
                [arr addObject:@{@"name":keys[i], @"data":values[i]}];
            }
        }
        self.way = @{@"name":self.way[@"name"], @"options":arr};
    }
}

#pragma mark -
#pragma mark TableViewDelegate&DataSource
- (UIViewController *)pageViewController:(XLPageViewController *)pageViewController viewControllerForIndex:(NSInteger)index {
    CommonCollectionViewController2 *vc = [[CommonCollectionViewController2 alloc]initWithNibName:@"CommonCollectionViewController2" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    [vc setLotteryType:self.curLotteryType];
    
    [vc setShowMode:showMode];
    if(self.way[@"mutx"]){
        //[vc setLotteryOptions:self.way[@"options"][index]];
        [self.pageViewController displayTitleview:true];
        NSDictionary *dict = self.way[@"options"][index];
        if([dict objectForKey:@"maxZhu"]){
            [vc setMaxZhu:[dict[@"minZhu"] integerValue] > 0 ? [dict[@"minZhu"] integerValue] : [dict[@"maxZhu"] integerValue]];
        }else{
            [vc setMaxZhu:999];
        }
        [vc setLotterySectionOptions:@[self.way[@"options"][index]]];
    }else{
        [self.pageViewController displayTitleview:false];
        
        if([self isSpecial1]){
            [vc setLotterySectionOptions:@[@{@"data":self.way[@"options"], @"name":self.way[@"name"], @"st":self.way[@"st"]?self.way[@"st"]:@""}]];
        }else if([self isSpecial2]){
            [vc setLotterySectionOptions:@[@{@"data":self.way[@"options"], @"name":self.way[@"name"],@"st":self.way[@"st"]?self.way[@"st"]:@""}]];
        }else{
            [vc setLotterySectionOptions:self.way[@"options"]];
        }
    }
    vc.contentView.backgroundColor = UIColor.clearColor;
    vc.view.backgroundColor = UIColor.clearColor;
    vc.rightCollection.backgroundColor = UIColor.clearColor;
    
    return vc;
}

- (NSString *)pageViewController:(XLPageViewController *)pageViewController titleForIndex:(NSInteger)index {
    
    return self.titles[index];
}

- (NSInteger)pageViewControllerNumberOfPage {
    return self.titles.count;
}

- (void)pageViewController:(XLPageViewController *)pageViewController didSelectedAtIndex:(NSInteger)index {
    NSLog(@"切换到了：%@",self.titles[index]);
}

- (void)reloadData{
    [self refreshTitle];
    
    NSInteger selectedIndex = self.pageViewController.selectedIndex;
    
    CommonCollectionViewController2 *vc = (CommonCollectionViewController2 *)[self.pageViewController getVCByIndex:selectedIndex];
    [vc setShowMode:showMode];
    if(self.way[@"mutx"]){
        //[vc setLotteryOptions:self.way[@"options"][selectedIndex]];
        [self.pageViewController displayTitleview:true];
        NSDictionary *dict = self.way[@"options"][selectedIndex];
        if([dict objectForKey:@"maxZhu"]){
            [vc setMaxZhu:[dict[@"maxZhu"] integerValue]];
        }else{
            [vc setMaxZhu:999];
        }
        if ([self.way[@"options"] isKindOfClass:[NSArray class]]) {
            NSArray *arrays = self.way[@"options"];
            if (arrays.count>selectedIndex) {
                [vc setLotterySectionOptions:@[self.way[@"options"][selectedIndex]]];
            }
        }
    }else{
        [self.pageViewController displayTitleview:false];
        
        if([self isSpecial1]){
            [vc setLotterySectionOptions:@[@{@"data":self.way[@"options"], @"name":self.way[@"name"],@"st":self.way[@"st"]?self.way[@"st"]:@""}]];
        }else if([self isSpecial2]){
            [vc setLotterySectionOptions:@[@{@"data":self.way[@"options"], @"name":self.way[@"name"],@"st":self.way[@"st"]?self.way[@"st"]:@""}]];
        }else{
            [vc setLotterySectionOptions:self.way[@"options"]];
        }
    }
    [self.pageViewController reloadData];
    self.pageViewController.selectedIndex = 0;
    [self.pageViewController reloadData];
    [vc.rightCollection reloadData];
}

-(BOOL)isSpecial1{
    // 处理快三的特殊情况(猜总和、猜对子等等)
    BOOL bSpecial1 = false;
    id arr = self.way[@"options"];
    if([arr isKindOfClass:[NSArray class]]){
        id dict = arr[0];
        if([dict isKindOfClass:[NSDictionary class]]){
            if([dict objectForKey:@"title"]){
                bSpecial1 = true;
            }
        }
    }
    
    return bSpecial1;
}

-(BOOL)isSpecial2{
    // 处理快三的特殊情况(猜总和、猜对子等等)
    BOOL bSpecial2 = false;
    id dcit = self.way[@"options"];
    if([dcit isKindOfClass:[NSDictionary class]]){
        id val = nil;
        NSArray *values = [dcit allValues];
        if ([values count] != 0)
            val = [values objectAtIndex:0];
        
        if([val isKindOfClass:[NSArray class]]){
            NSArray *arr = val;
            id dict = [arr firstObject];
            if([dict objectForKey:@"title"]){
                bSpecial2 = true;
            }
        }
    }
    
    return bSpecial2;
}



-(NSMutableArray *)getSelectedOptions{
    NSInteger selectedIndex = self.pageViewController.selectedIndex;
    CommonCollectionViewController2 *vc = (CommonCollectionViewController2 *)[self.pageViewController getVCByIndex:selectedIndex];
    
    return [vc getSelectedOptions];
}

- (void)clearSelectedStatus{
    NSInteger selectedIndex = self.pageViewController.selectedIndex;
    CommonCollectionViewController2 *vc = (CommonCollectionViewController2 *)[self.pageViewController getVCByIndex:selectedIndex];
    
    return [vc clearSelectedStatus];
}

- (void)randomSelected{
    NSInteger selectedIndex = self.pageViewController.selectedIndex;
    CommonCollectionViewController2 *vc = (CommonCollectionViewController2 *)[self.pageViewController getVCByIndex:selectedIndex];
    
    [vc randomSelected:[self getMinZhu]];
}

- (NSInteger)getMinZhu{
    NSInteger selectedIndex = self.pageViewController.selectedIndex;
    if(self.way[@"mutx"]){
        NSDictionary *dict = self.way[@"options"][selectedIndex];
        if([dict objectForKey:@"minZhu"]){
            return [dict[@"minZhu"] integerValue];
        }else{
            return 1;
        }
    }else{
        return 1;
    }
}

- (NSInteger)getMaxZhu{
    NSInteger selectedIndex = self.pageViewController.selectedIndex;
    if(self.way[@"mutx"]){
        NSDictionary *dict = self.way[@"options"][selectedIndex];
        if([dict objectForKey:@"maxZhu"]){
            return [dict[@"maxZhu"] integerValue];
        }else{
            return 999;
        }
    }else{
        return 999;
    }
}

@end
