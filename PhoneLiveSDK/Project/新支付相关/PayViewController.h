//
//  PayViewController.h
//

#import <UIKit/UIKit.h>

@interface PayViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *returnBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *serviceBtn;

@property (weak, nonatomic) IBOutlet UIView *marqueeView;
@property (weak, nonatomic) IBOutlet UIScrollView *pageScrollview;
//@property (weak, nonatomic) IBOutlet UIView *titleBgView;
@property (weak, nonatomic) IBOutlet UILabel *coinLab;

@property (weak, nonatomic) IBOutlet UIButton *listBtn;
@property (weak, nonatomic) IBOutlet UIButton *withDrawBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalHeight;
@property (nonatomic,strong) NSString *titleStr;

- (void)exitView;
//- (void)setLotteryType:(NSInteger)lotteryType;
- (void)setHomeMode:(BOOL)isHomeMode;
@end

