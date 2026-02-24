//
//  CommonTableViewController.h
//

#import <UIKit/UIKit.h>

@interface CommonTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;

@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel;
@property (weak, nonatomic) IBOutlet UIButton *chargeBtn;
@property (weak, nonatomic) IBOutlet UIButton *betBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchChipBtn;
@property (weak, nonatomic) IBOutlet UIButton *historyIssueBtn;
@property (weak, nonatomic) IBOutlet UIButton *betHistoryIssueBtn;

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

//
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionBottomSpace;

// 左侧滑动
@property (weak, nonatomic) IBOutlet UITableView *leftTablew;

@property(strong,nonatomic,readonly) NSArray * allData;
@property(copy,nonatomic,readonly) id block;
/**
 *  是否 记录滑动位置
 */
@property(assign,nonatomic) BOOL isRecordLastScroll;
/**
 *   记录滑动位置 是否需要 动画
 */
@property(assign,nonatomic) BOOL isRecordLastScrollAnimated;

@property(assign,nonatomic,readonly) NSInteger selectIndex;
/**
 *  为了 不修改原来的，因此增加了一个属性，选中指定 行数
 */
@property(assign,nonatomic) NSInteger needToScorllerIndex;
/**
 *  颜色属性配置
 */

/**
 *  左边背景颜色
 */
@property(strong,nonatomic) UIColor * leftBgColor;
/**
 *  左边点中文字颜色
 */
@property(strong,nonatomic) UIColor * leftSelectColor;
/**
 *  左边点中背景颜色
 */
@property(strong,nonatomic) UIColor * leftSelectBgColor;

/**
 *  左边未点中文字颜色
 */

@property(strong,nonatomic) UIColor * leftUnSelectColor;
/**
 *  左边未点中背景颜色
 */
@property(strong,nonatomic) UIColor * leftUnSelectBgColor;
/**
 *  tablew 的分割线
 */
@property(strong,nonatomic) UIColor * leftSeparatorColor;

- (void)exitView;
- (void)setLotteryType:(NSInteger)lotteryType;
- (void)setLotteryWays:(NSArray *)_ways;
- (NSMutableArray *)getSelectedOptions;
- (void)clearSelectedStatus;
- (void)randomSelected;
- (NSInteger)getMinZhu;
- (NSInteger)getMaxZhu;
- (void) setBottomSpace:(CGFloat) height;

-(NSString*)getOptionName;
-(NSString*)getOptionNameSt;
@end

