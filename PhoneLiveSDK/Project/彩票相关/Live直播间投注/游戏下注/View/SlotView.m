//
//  SlotView.m
//  SlotDemo
//
//  Created by test on 2021/12/29.
//

#import "SlotView.h"
#import "SlotCell.h"
#import "SlotLineLayer.h"
#import "UIScrollView+ScrollAnimation.h"
#define MAX_ANIMATION_Delay 1
@interface SlotView()<UITableViewDelegate,UITableViewDataSource>{
    BOOL _isAnimating;
}
@property (weak, nonatomic) IBOutlet UITableView *tb_part_1;
@property (weak, nonatomic) IBOutlet UITableView *tb_part_2;
@property (weak, nonatomic) IBOutlet UITableView *tb_part_3;
@property (strong,nonatomic)NSArray <NSArray *>*map_list;//结果索引地图
@property (strong,nonatomic)NSArray <NSArray *>*datas;//slot展示数据
@property (strong,nonatomic)void(^animationComplete)(void);
@property (strong,nonatomic)NSArray <NSArray *>*last_results;
@end
static NSString *reuse_slotCell = @"reuseslotcellstring";
@implementation SlotView

+ (instancetype)instanceSlotViewWithFrame:(CGRect)frame{
    SlotView *instance = [[[XBundle currentXibBundleWithResourceName:@"SlotView"] loadNibNamed:@"SlotView" owner:nil options:nil] lastObject];
    instance.frame = frame;
    [instance configPartTable:instance.tb_part_1];
    [instance configPartTable:instance.tb_part_2];
    [instance configPartTable:instance.tb_part_3];
    instance.datas = @[@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"],
                   @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"],
                   @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"]];
    instance->_isAnimating = NO;
    [instance reverseDatas];
    [instance reloadData];
    return instance;
}
-(void)startSlotWithResult:(NSArray *)result animationCompleteHandler:(void(^)(void))handler{
    self.map_list = [self anlyzeDatas:result];
    if (_isAnimating) {
        return;
    }
    if (handler) {
        self.animationComplete = handler;
    }
    _isAnimating = YES;
    if (self.last_results) {
        //替换初始值
        NSInteger i = 0;
        NSMutableArray *newData = [NSMutableArray array];
        for (NSArray *resultItems in self.last_results) {
            if (i == 0) {
                NSMutableArray *dataItems = self.datas[i].mutableCopy;
                for (int j = 0; j<3; j++) {
                    NSDictionary *resultItem = resultItems[j];
                    [dataItems replaceObjectAtIndex:dataItems.count - (3-j) withObject:resultItem];
                }
                [newData addObject:dataItems.copy];
            }else if(i == 1){
                NSMutableArray *dataItems = self.datas[i].mutableCopy;
                for (int j = 0; j<3; j++) {
                    NSDictionary *resultItem = resultItems[j];
                    [dataItems replaceObjectAtIndex:dataItems.count - (3-j) withObject:resultItem];

                }
                [newData addObject:dataItems.copy];
            }else{
                NSMutableArray *dataItems = self.datas[i].mutableCopy;
                for (int j = 0; j<3; j++) {
                    NSDictionary *resultItem = resultItems[j];
                    [dataItems replaceObjectAtIndex:dataItems.count - (3-j) withObject:resultItem];
                }
                [newData addObject:dataItems.copy];
            }
            i++;
        }
        self.datas = newData.copy;
    }
    //追加当前结果
    NSInteger i = 0;
    NSMutableArray *newData = [NSMutableArray array];
    for (NSArray *resultItems in self.map_list) {
        if (i == 0) {
            NSMutableArray *dataItems = self.datas[i].mutableCopy;
            for (int j = 0; j<3; j++) {
                NSDictionary *resultItem = resultItems[j];
                [dataItems replaceObjectAtIndex:j withObject:resultItem];
            }
            [newData addObject:dataItems.copy];
        }else if(i == 1){
            NSMutableArray *dataItems = self.datas[i].mutableCopy;
            for (int j = 0; j<3; j++) {
                NSDictionary *resultItem = resultItems[j];
                [dataItems replaceObjectAtIndex:j withObject:resultItem];

            }
            [newData addObject:dataItems.copy];
        }else{
            NSMutableArray *dataItems = self.datas[i].mutableCopy;
            for (int j = 0; j<3; j++) {
                NSDictionary *resultItem = resultItems[j];
                [dataItems replaceObjectAtIndex:j withObject:resultItem];
            }
            [newData addObject:dataItems.copy];
        }
        i++;
    }
    self.datas = newData.copy;
    [self reloadData];
    self.last_results = self.map_list;
    for (int i = 0; i<3; i++) {
        if (i == 0) {
            [self doAnimation:self.tb_part_1 andDelay:0];
        }else if (i == 1){
            [self doAnimation:self.tb_part_2 andDelay:0.1];
        }else{
            [self doAnimation:self.tb_part_3 andDelay:0.2];
        }
    }
}

- (void)startLine:(NSArray<NSDictionary *> *)lines withLineCompleteHander:(void(^)(void))handler{
    NSMutableArray *cells = [NSMutableArray array];
    for (NSDictionary *line in lines) {
        NSMutableArray *lineCells = [NSMutableArray array];
        NSArray *ln = line[@"line"];
        for (int i = 0; i < 3; i++) {
            NSInteger tag = [ln[i] integerValue];
            NSInteger section = tag % 3;
            NSInteger row = tag / 3;
            if (section == 0) {
                if (row < self.tb_part_1.visibleCells.count) {
                    SlotCell *tagCell = self.tb_part_1.visibleCells[row];
                    tagCell.lineCount = tagCell.lineCount + 1;
                    tagCell.remainLineCount = tagCell.lineCount;
                    [lineCells addObject:tagCell];
                }
            }else if (section == 1) {
                if (row < self.tb_part_2.visibleCells.count) {
                    SlotCell *tagCell = self.tb_part_2.visibleCells[row];
                    tagCell.lineCount = tagCell.lineCount + 1;
                    tagCell.remainLineCount = tagCell.lineCount;
                    [lineCells addObject:tagCell];
                }
            }else{
                if (row < self.tb_part_3.visibleCells.count) {
                    SlotCell *tagCell = self.tb_part_3.visibleCells[row];
                    tagCell.lineCount = tagCell.lineCount + 1;
                    tagCell.remainLineCount = tagCell.lineCount;
                    [lineCells addObject:tagCell];
                }
            }
        }
        [cells addObject:lineCells.copy];
    }
    NSMutableArray *colors = @[[UIColor redColor],[UIColor blueColor],[UIColor yellowColor],[UIColor greenColor],[UIColor brownColor]].mutableCopy;
    for (NSArray *line in cells.copy) {
        //创建path
        UIBezierPath *path = [UIBezierPath bezierPath];
        SlotLineLayer *layer = [[SlotLineLayer alloc] init];
        //提取目标cell
        SlotCell *c_1 = line.firstObject;
        SlotCell *c_2 = line[1];
        SlotCell *c_3 = line.lastObject;
        CGRect r_1 = [c_1 convertRect:c_1.bounds toView:self];
        CGRect r_2 = [c_2 convertRect:c_2.bounds toView:self];
        CGRect r_3 = [c_3 convertRect:c_3.bounds toView:self];
        if (c_1.lineCount == 1) {
            //中点连接
            CGPoint pt_1 = CGPointMake(r_1.origin.x, r_1.origin.y + r_1.size.height / 2.0);
            CGPoint pt_2 = CGPointMake(r_1.origin.x + r_1.size.width / 2.0, r_1.origin.y + r_1.size.height / 2.0);
            [path moveToPoint:pt_1];
            [path addLineToPoint:pt_2];
        }else{
            //有多个连接处 从边点开始
            CGPoint pt_1 = CGPointMake(r_1.origin.x, r_1.origin.y + r_1.size.height / (c_1.remainLineCount + 0.25));
            [path moveToPoint:pt_1];
            CGPoint pt_2 = CGPointMake(r_1.origin.x + r_1.size.width / 2.0, r_1.origin.y + r_1.size.height / (c_1.remainLineCount + 0.25));
            [path addLineToPoint:pt_2];
        }
        if (c_2.lineCount == 1) {
            //中点连接
            CGPoint pt_1 = CGPointMake(r_2.origin.x + r_2.size.width / 2.0, r_2.origin.y + r_2.size.height / 2.0);
            [path addLineToPoint:pt_1];
        }else{
            //有多个连接处 从边点开始
            CGPoint pt_1 = CGPointMake(r_2.origin.x + r_2.size.width / 2.0, r_2.origin.y + r_2.size.height / (c_2.remainLineCount + 0.25));
            [path addLineToPoint:pt_1];
        }
        if (c_3.lineCount == 1) {
            //中点连接
            CGPoint pt_1 = CGPointMake(r_3.origin.x + r_3.size.width / 2.0, r_3.origin.y + r_3.size.height / 2.0);
            CGPoint pt_2 = CGPointMake(r_3.origin.x + r_3.size.width, r_3.origin.y + r_3.size.height / 2.0);
            [path addLineToPoint:pt_1];
            [path addLineToPoint:pt_2];
        }else{
            //有多个连接处 从边点开始
            CGPoint pt_1 = CGPointMake(r_3.origin.x + r_3.size.width / 2.0, r_3.origin.y + r_3.size.height / (c_3.remainLineCount + 0.25));
            CGPoint pt_2 = CGPointMake(r_3.origin.x + r_3.size.width, r_3.origin.y + r_3.size.height / (c_3.remainLineCount + 0.25));
            [path addLineToPoint:pt_1];
            [path addLineToPoint:pt_2];
        }
        //设置线头的样式：Butt 齐头   Square 多出一截方头 Round 多出一截圆头
        path.lineCapStyle = kCGLineCapButt;
        //设置线条连接处的样式（圆的、斜的、尖的）
        path.lineJoinStyle = kCGLineJoinMiter;
        //绘制路径
        [path stroke];
        layer.lineWidth = 3.0;
        layer.fillColor = UIColor.clearColor.CGColor;
        layer.strokeColor = [colors.firstObject CGColor];
        layer.path = path.CGPath;
        [self.layer addSublayer:layer];
        c_1.remainLineCount = c_1.remainLineCount - 1;
        c_2.remainLineCount = c_2.remainLineCount - 1;
        c_3.remainLineCount = c_3.remainLineCount - 1;
        [colors removeObjectAtIndex:0];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (handler) {
            handler();
        }
    });
}
- (void)configPartTable:(UITableView *)tb_part{
    tb_part.delegate = self;
    tb_part.dataSource = self;
    [tb_part registerNib:[UINib nibWithNibName:@"SlotCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellReuseIdentifier:reuse_slotCell];
    tb_part.userInteractionEnabled = NO;
    tb_part.estimatedRowHeight = 0;
    tb_part.estimatedSectionFooterHeight = 0;
    tb_part.estimatedSectionHeaderHeight = 0;
}
- (void)doAnimation:(UITableView *)tb_part andDelay:(CGFloat)delay{
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tb_part setContentOffset:CGPointMake(0, 0) withTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] duration:1];
        if (delay == 0.2) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf->_isAnimating = NO;
                if (strongSelf.animationComplete) {
                    strongSelf.animationComplete();
                }
            });
        }
    });
}
- (NSArray <NSArray *>*)anlyzeDatas:(NSArray *)datas{
    NSInteger idx = 0;
    NSMutableArray *n_a = [NSMutableArray array];
    NSMutableArray *a_1 = [NSMutableArray array];
    NSMutableArray *a_2 = [NSMutableArray array];
    NSMutableArray *a_3 = [NSMutableArray array];
    for (NSString *item in datas) {
        if (idx % 3 == 0) {
            [a_1 addObject:item];
        }else if (idx % 3 == 1){
            [a_2 addObject:item];
        }else{
            [a_3 addObject:item];
        }
        idx++;
    }
    [n_a addObject:a_1.copy];
    [n_a addObject:a_2.copy];
    [n_a addObject:a_3.copy];
    return n_a.copy;
}
- (void)reverseDatas{
    NSMutableArray *newData = [NSMutableArray array];
    for (NSArray *item in self.datas) {
        NSMutableArray *newItem = [NSMutableArray array];
        [newItem addObjectsFromArray:item];
        [newItem addObjectsFromArray:item];
        [newItem addObjectsFromArray:item];
        [newData addObject:[self gk_randomArrayWithArray:newItem.copy]];
    }
    self.datas = newData.copy;
}
/*
 *  @brief 将数组随机打乱
 */
- (NSArray *)gk_randomArrayWithArray:(NSArray *)arr{
    // 转为可变数组
    NSMutableArray * tmp = arr.mutableCopy;
    // 获取数组长度
    NSInteger count = tmp.count;
    // 开始循环
    while (count > 0) {
        // 获取随机角标
        NSInteger index = arc4random_uniform((int)(count - 1));
        // 获取角标对应的值
        id value = tmp[index];
        // 交换数组元素位置
        tmp[index] = tmp[count - 1];
        tmp[count - 1] = value;
        count--;
    }
    // 返回打乱顺序之后的数组
    return tmp.copy;
}

- (void)reloadData{
    dispatch_main_async_safe(^{
        [self.tb_part_1 reloadData];
        [self.tb_part_2 reloadData];
        [self.tb_part_3 reloadData];
        [self.tb_part_1 scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.datas[0].count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        [self.tb_part_2 scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.datas[1].count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        [self.tb_part_3 scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.datas[2].count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    });
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tb_part_1) {
        return self.datas[0].count;

    }else if (tableView == self.tb_part_2){
        return self.datas[1].count;

    }else{
        return self.datas[2].count;

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SlotCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_slotCell forIndexPath:indexPath];
    cell.lineCount = 0;
    cell.remainLineCount = 0;
    if (tableView == self.tb_part_1) {
        NSArray *part_1 = self.datas[0];
        cell.data = part_1[indexPath.row];
    }else if (tableView == self.tb_part_2) {
        NSArray *part_2 = self.datas[1];
        cell.data = part_2[indexPath.row];
    }else{
        NSArray *part_3 = self.datas[2];
        cell.data = part_3[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return tableView.height / 3.0;
}
@end
