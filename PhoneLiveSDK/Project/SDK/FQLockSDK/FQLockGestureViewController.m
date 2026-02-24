//
//  FQLockGestureViewController.m
//  PhoneLiveSDK
//
//  Created by wuwuFQ on 2022/9/17.
//  Updated on 2025/04/07.
//

#import "FQLockGestureViewController.h"
#import "UIColor+RGB.h"
#import <UMCommon/UMCommon.h>
#import "FQLockHelper.h"
#import "FQLockGestureView.h"

#define kPassword @"FQ_PASSWORD"

@interface FQLockGestureViewController () <FQGestureLockViewDelegate>

@property (nonatomic, strong) FQLockGestureView *lockView;
@property (nonatomic, strong) FQLockConfig *lockConfig;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UIButton *forget_button;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *securityGridView;
@property (nonatomic, strong) UIView *lockIconView;
@property (nonatomic, assign) int loginNum;

@end

@implementation FQLockGestureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色为深色
    self.view.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.04 alpha:1.0]; // #0a0a0a
    
    // 设置导航栏和手势
    self.navigationController.navigationBar.backgroundColor = RGB(246, 246, 246);
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    // 设置标题
    if (self.lockType == FQLockTypeReset) {
        self.title = YZMsg(@"Modif_UnlockPassword");
    } else if (self.lockType == FQLockTypeClose) {
        self.title = YZMsg(@"Turn_GesturePasscode");
    } else {
        self.title = YZMsg(@"Set_GesturePasscode");
    }
    
    // 设置登录尝试次数
    self.loginNum = 4;
    

    
    // 添加屏幕尺寸变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(orientationChanged:) 
                                                 name:UIDeviceOrientationDidChangeNotification 
                                               object:nil];
    
    // 创建 UI 元素
    [self setupBackground];
    [self initLockView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // 如果是设置页面，不显示导航栏
    if (self.lockType == FQLockTypeSetting||self.lockType == FQLockTypeClose||self.lockType == FQLockTypeReset) {
        self.navigationController.navigationBarHidden = YES;
    } else {
        self.navigationController.navigationBarHidden = YES;
    }
    
    // 重新布局 UI 元素
    [self updateLayoutForCurrentScreenSize];
}

// 根据当前屏幕尺寸更新布局
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // 更新所有 UI 元素的布局
    [self updateLayoutForCurrentScreenSize];
}

-(void)setupNavigation{
    // 如果是设置页面，不显示导航栏
    if (self.lockType == FQLockTypeSetting) {
        return;
    }
    
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0,0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor = [UIColor whiteColor];
    UILabel *labels = [[UILabel alloc]init];
    labels.text = self.title;
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
        __weak typeof(self) weakSelf = self;
        [self dismissViewControllerAnimated:YES completion:^{
            if ( weakSelf.localLockBlock) {
                weakSelf.localLockBlock(YES);
            }
           
        }];
    
    
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 创建信息图标
- (UIImage *)createInfoIconWithColor:(UIColor *)color {
    CGSize size = CGSizeMake(20, 20);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 绘制圆圈
    CGFloat lineWidth = 1.0;
    CGRect circleRect = CGRectMake(lineWidth, lineWidth, size.width - 2 * lineWidth, size.height - 2 * lineWidth);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [color setStroke];
    circlePath.lineWidth = lineWidth;
    [circlePath stroke];
    
    // 绘制字母 i 的点
    CGFloat dotRadius = 1.5;
    CGRect dotRect = CGRectMake(size.width/2 - dotRadius, 5, dotRadius * 2, dotRadius * 2);
    UIBezierPath *dotPath = [UIBezierPath bezierPathWithOvalInRect:dotRect];
    [color setFill];
    [dotPath fill];
    
    // 绘制字母 i 的线
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(size.width/2, 9)];
    [linePath addLineToPoint:CGPointMake(size.width/2, 15)];
    linePath.lineWidth = 1.5;
    [color setStroke];
    [linePath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 忘记手势密码
- (void)forget_buttonClick {
    // 显示确认对话框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert")
                                                                             message:YZMsg(@"Turn_GesturePasscode_forget")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    // 添加确认按钮
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [FQLockHelper setLocalGestureEnable:NO forUserId:self.userID];
        [self.navigationController popViewControllerAnimated:NO];
        [self dismissViewControllerAnimated:NO completion:^{
         
        }];
        [[YBToolClass sharedInstance] quitLogin:YES];
    }];
    [alertController addAction:confirmAction];
    
    // 显示对话框
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (void)setupBackground {
    // 创建统一的深色背景
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0]; // 深色背景 #0d0d0d
    [self.view addSubview:self.backgroundView];
    
    // 添加微妙的渐变效果在顶部
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    topGradient.frame = CGRectMake(0, 0, self.view.bounds.size.width, 150);
    topGradient.colors = @[(id)[UIColor colorWithRed:0.15 green:0.15 blue:0.2 alpha:0.3].CGColor,
                           (id)[UIColor clearColor].CGColor];
    topGradient.locations = @[@0.0, @1.0];
    topGradient.startPoint = CGPointMake(0.5, 0.0);
    topGradient.endPoint = CGPointMake(0.5, 1.0);
    [self.backgroundView.layer addSublayer:topGradient];
    
    // 添加网格线条效果（类似于HTML中的网格背景）
    self.securityGridView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.securityGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.securityGridView.backgroundColor = [UIColor clearColor];
    
    // 添加网格线条
    CGFloat gridSpacing = 20.0;
    CGFloat lineWidth = 0.5;
    UIColor *gridColor = [UIColor colorWithWhite:1.0 alpha:0.05]; // 淡色网格线
    
    // 水平线
    for (CGFloat y = 0; y < self.view.bounds.size.height; y += gridSpacing) {
        UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, lineWidth)];
        horizontalLine.backgroundColor = gridColor;
        [self.securityGridView addSubview:horizontalLine];
    }
    
    // 垂直线
    for (CGFloat x = 0; x < self.view.bounds.size.width; x += gridSpacing) {
        UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(x, 0, lineWidth, self.view.bounds.size.height)];
        verticalLine.backgroundColor = gridColor;
        [self.securityGridView addSubview:verticalLine];
    }
    
    [self.view addSubview:self.securityGridView];
}

// 屏幕尺寸变化时调用
- (void)orientationChanged:(NSNotification *)notification {
    // 重新布局 UI 元素
    [self updateLayoutForCurrentScreenSize];
}

// 根据当前屏幕尺寸更新布局
- (void)updateLayoutForCurrentScreenSize {
    
    // 更新锁图标位置 - 使用参考点而不是百分比
    CGFloat topSafeArea = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat backButtonHeight = 24; // 返回按钮高度
    CGFloat lockIconTopMargin = 20; // 锁图标距离返回按钮的距离
    CGFloat lockIconY = topSafeArea + backButtonHeight + lockIconTopMargin + self.lockIconView.frame.size.height/2;
    
    self.lockIconView.center = CGPointMake(self.view.bounds.size.width / 2, lockIconY);
    
    // 更新标题标签位置
    UILabel *titleLabel = [self.view viewWithTag:1001];
    if (titleLabel) {
        titleLabel.frame = CGRectMake(0, self.lockIconView.frame.origin.y + self.lockIconView.frame.size.height + 10, self.view.bounds.size.width, 40);
    }
    
    // 更新消息标签位置
    if (self.msgLabel) {
        self.msgLabel.frame = CGRectMake(30, titleLabel.frame.origin.y + titleLabel.frame.size.height + 5, self.view.bounds.size.width - 60, 35);
    }
    
    // 更新锁视图配置
    if (self.lockConfig) {
//        self.lockConfig.lockViewCenterY = self.view.frame.size.height * 0.55;
        [self.lockView updateConfig:self.lockConfig];
    }
    self.lockView.top = self.msgLabel.top+self.msgLabel.size.height+5;
    self.lockView.centerX = self.view.width/2;
    // 更新忘记密码按钮位置
    if (self.forget_button) {
        self.forget_button.frame = CGRectMake((self.view.frame.size.width - 160) / 2, self.view.frame.size.height - 80, 160, 40);
    }
}

- (void)initLockView {
    // 获取屏幕尺寸和安全区域
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    CGFloat topSafeArea = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat bottomSafeArea = 0;
    BOOL isSmallScreen = (screenHeight <= 667); // iPhone SE/6/7/8等小屏幕设备
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        bottomSafeArea = window.safeAreaInsets.bottom;
    }
    
    // 定义各元素间的间距常量
    CGFloat bottomMargin = 10; // 元素距离底部的距离
    CGFloat elementSpacing = 10; // 元素之间的间距
    
    // 如果是设置页面，在左上角添加返回箭头
    UIButton *backButton;
    CGFloat backButtonBottom = 0;
    if (self.lockType == FQLockTypeSetting || self.lockType == FQLockTypeClose || self.lockType == FQLockTypeReset) {
        // 确保返回按钮从电池条下面开始布局
        backButton = [[UIButton alloc] initWithFrame:CGRectMake(16, topSafeArea, 24, 24)];
        [backButton setImage:[ImageBundle imagewithBundleName:@"arrow_return.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backButton];
        backButtonBottom = backButton.frame.origin.y + backButton.frame.size.height;
    }
    
    // 创建简洁的锁图标显示
    self.lockIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    
    // 计算锁图标的位置 - 使用参考点而不是百分比
    CGFloat lockIconTopMargin;
    CGFloat lockIconSize = 80; // 默认大屏幕图标尺寸
    
    if (isSmallScreen) {
        // 小屏幕设备上显著减小间距和图标尺寸
        lockIconTopMargin = 5; // 显著减小间距
        lockIconSize = 60; // 缩小图标尺寸
        
        // 调整锁图标视图的尺寸
        self.lockIconView.frame = CGRectMake(0, 0, lockIconSize, lockIconSize);
    } else {
        // 大屏幕设备使用更大的间距
        lockIconTopMargin = 20;
    }
    
    // 确保锁图标位置基于返回按钮底部
    CGFloat lockIconY = backButtonBottom + lockIconTopMargin;
    self.lockIconView.center = CGPointMake(screenWidth / 2, lockIconY + self.lockIconView.frame.size.height/2);
    self.lockIconView.backgroundColor = [UIColor clearColor];
    
    // 创建圆形背景 - 根据图片调整
    CGFloat circleSize = isSmallScreen ? 40 : 50;
    CGFloat circleMargin = (lockIconSize - circleSize) / 2;
    UIView *circleBackground = [[UIView alloc] initWithFrame:CGRectMake(circleMargin, circleMargin, circleSize, circleSize)];
    circleBackground.backgroundColor = [UIColor colorWithRed:0.067 green:0.067 blue:0.15 alpha:1.0]; // 非常深的蓝色背景
    circleBackground.layer.cornerRadius = circleSize / 2;
    [self.lockIconView addSubview:circleBackground];
    
    // 创建锁图标 - 根据第二张图片调整
    CGFloat lockWidth = isSmallScreen ? 18 : 22;
    CGFloat lockHeight = isSmallScreen ? 24 : 28;
    CGFloat lockX = (circleSize - lockWidth) / 2;
    CGFloat lockY = (circleSize - lockHeight) / 2;
    
    // 根据HTML中的SVG代码绘制锁图标
    UIBezierPath *lockPath = [UIBezierPath bezierPath];
    
    // 计算比例和位置
    CGFloat svgWidth = 24.0;
    CGFloat svgHeight = 24.0;
    CGFloat scaleX = lockWidth / svgWidth;
    CGFloat scaleY = lockHeight / svgHeight;
    
    // 锁的底部矩形部分 - 对应SVG中的第一个path
    // "M19 11H5C3.89543 11 3 11.8954 3 13V20C3 21.1046 3.89543 22 5 22H19C20.1046 22 21 21.1046 21 20V13C21 11.8954 20.1046 11 19 11Z"
    CGFloat bodyLeft = lockX;
    CGFloat bodyTop = lockY + lockHeight * 0.45; // 对应SVG中的y=11
    CGFloat bodyRight = lockX + lockWidth;
    CGFloat bodyBottom = lockY + lockHeight;
    CGFloat bodyCornerRadius = 2.0 * scaleX;
    
    UIBezierPath *bodyPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(bodyLeft, bodyTop, lockWidth, bodyBottom - bodyTop) cornerRadius:bodyCornerRadius];
    [lockPath appendPath:bodyPath];
    
    // 锁的拱形部分 - 对应SVG中的第二个path
    // "M7 11V7C7 5.67392 7.52678 4.40215 8.46447 3.46447C9.40215 2.52678 10.6739 2 12 2C13.3261 2 14.5979 2.52678 15.5355 3.46447C16.4732 4.40215 17 5.67392 17 7V11"
    CGFloat archLeft = lockX + lockWidth * 0.25; // 对应SVG中的x=7
    CGFloat archRight = lockX + lockWidth * 0.75; // 对应SVG中的x=17
    CGFloat archTop = lockY;
    CGFloat archConnectY = bodyTop;
    
    // 左侧竖线
    [lockPath moveToPoint:CGPointMake(archLeft, archConnectY)];
    [lockPath addLineToPoint:CGPointMake(archLeft, archConnectY - lockHeight * 0.2)];
    
    // 拱形部分
    CGFloat controlPointY = archTop + lockHeight * 0.1;
    CGFloat midX = lockX + lockWidth / 2;
    
    // 使用三次贝塞尔曲线绘制半圆形拱
    [lockPath addCurveToPoint:CGPointMake(midX, archTop)
                controlPoint1:CGPointMake(archLeft, controlPointY)
                controlPoint2:CGPointMake(midX - lockWidth * 0.15, archTop)];
    
    [lockPath addCurveToPoint:CGPointMake(archRight, archConnectY - lockHeight * 0.2)
                controlPoint1:CGPointMake(midX + lockWidth * 0.15, archTop)
                controlPoint2:CGPointMake(archRight, controlPointY)];
    
    // 右侧竖线
    [lockPath addLineToPoint:CGPointMake(archRight, archConnectY)];
    
    // 小圆点 - 对应SVG中的第三个path
    // "M12 16C12.5523 16 13 15.5523 13 15C13 14.4477 12.5523 14 12 14C11.4477 14 11 14.4477 11 15C11 15.5523 11.4477 16 12 16Z"
    CGFloat dotRadius = lockWidth * 0.08;
    CGPoint dotCenter = CGPointMake(midX, bodyTop + (bodyBottom - bodyTop) * 0.5);
    UIBezierPath *dotPath = [UIBezierPath bezierPathWithArcCenter:dotCenter radius:dotRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    // 创建锁图层
    CAShapeLayer *lockShapeLayer = [CAShapeLayer layer];
    lockShapeLayer.path = lockPath.CGPath;
    lockShapeLayer.strokeColor = [UIColor colorWithRed:0.25 green:0.48 blue:1.0 alpha:1.0].CGColor; // #407BFF
    lockShapeLayer.fillColor = [UIColor clearColor].CGColor;
    lockShapeLayer.lineWidth = 2.0;
    lockShapeLayer.lineCap = kCALineCapRound;
    lockShapeLayer.lineJoin = kCALineJoinRound;
    [circleBackground.layer addSublayer:lockShapeLayer];
    
    // 创建小圆点图层
    CAShapeLayer *dotShapeLayer = [CAShapeLayer layer];
    dotShapeLayer.path = dotPath.CGPath;
    dotShapeLayer.fillColor = [UIColor colorWithRed:0.25 green:0.48 blue:1.0 alpha:1.0].CGColor; // #407BFF
    dotShapeLayer.strokeColor = [UIColor colorWithRed:0.25 green:0.48 blue:1.0 alpha:1.0].CGColor; // #407BFF
    dotShapeLayer.lineWidth = 2.0;
    [circleBackground.layer addSublayer:dotShapeLayer];
    
    // 创建脉冲动画图层 - 使用单独的圆形图层增强效果
    CALayer *pulseLayer = [CALayer layer];
    // 使用比背景大一点的尺寸，确保有足够空间显示扩散效果
    CGFloat pulseSize = circleSize * 0.9;
    pulseLayer.frame = CGRectMake((circleSize - pulseSize) / 2, (circleSize - pulseSize) / 2, pulseSize, pulseSize);
    pulseLayer.cornerRadius = pulseSize / 2;
    pulseLayer.backgroundColor = [UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:0.1].CGColor; // 添加轻微的背景色
    pulseLayer.borderWidth = 1.0;
    pulseLayer.borderColor = [UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:0.4].CGColor;
    
    // 设置阴影颜色为与HTML中相同的颜色 rgba(64, 123, 255, 0.4)
    pulseLayer.shadowColor = [UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:0.4].CGColor;
    pulseLayer.shadowOffset = CGSizeMake(0, 0);
    pulseLayer.shadowRadius = 0; // 初始时阴影半径为0
    pulseLayer.shadowOpacity = 1.0; // 初始时完全不透明
    [circleBackground.layer insertSublayer:pulseLayer atIndex:0];
    
    // 添加静态光晕效果
    CALayer *glowLayer = [CALayer layer];
    glowLayer.frame = circleBackground.bounds;
    glowLayer.cornerRadius = circleSize / 2;
    glowLayer.shadowColor = [UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:0.3].CGColor;
    glowLayer.shadowOffset = CGSizeMake(0, 0);
    glowLayer.shadowRadius = 5.0;
    glowLayer.shadowOpacity = 1.0;
    [circleBackground.layer insertSublayer:glowLayer atIndex:0];
    
    // 保存脉冲图层引用，便于后续操作
    objc_setAssociatedObject(self, @"pulseLayer", pulseLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 创建定时器每2秒触发一次脉冲动画（与HTML中的2秒动画周期一致）
    NSTimer *pulseTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        // 触发脉冲动画
        [self triggerPulseAnimationForLayer:pulseLayer];
    }];
    
    // 将定时器添加到RunLoop中确保其正常运行
    [[NSRunLoop currentRunLoop] addTimer:pulseTimer forMode:NSRunLoopCommonModes];
    
    // 将定时器保存到视图控制器中，防止被释放
    objc_setAssociatedObject(self, @"pulseTimer", pulseTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self.view addSubview:self.lockIconView];
    
    // 立即触发一次脉冲动画
    [self triggerPulseAnimationForLayer:pulseLayer];
    
    // 创建标题标签 - 使用现代简洁的设计
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.tag = 1001; // 添加标签便于后续查找
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor whiteColor];
    
    // 设置标题标签位置
    titleLabel.frame = CGRectMake(0, self.lockIconView.frame.origin.y + self.lockIconView.frame.size.height + 10, self.view.bounds.size.width, 40);
    
    // 设置标题文本和颜色
    titleLabel.textColor = [UIColor whiteColor]; // 设置标题为白色
    
    if (self.lockType == FQLockTypeReset) {
        titleLabel.text = YZMsg(@"ReSet_GesturePasscode");
    } else if (self.lockType == FQLockTypeLogin) {
        titleLabel.text = YZMsg(@"Gesture_Password");
    } else {
        titleLabel.text = YZMsg(@"Set_GesturePasscode");
    }
    
    // 添加文本阴影效果增强可读性
    titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    titleLabel.layer.shadowRadius = 3.0;
    titleLabel.layer.shadowOpacity = 0.3;
    
    // 设置标签位置 - 小屏幕上显著减小间距
    CGFloat titleTopMargin = isSmallScreen ? 5 : 20; // 小屏幕上使用更小的间距
    
    // 小屏幕上使用更小的字体
    if (isSmallScreen) {
        titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightSemibold];
    }
    
    titleLabel.frame = CGRectMake(0, self.lockIconView.frame.origin.y + self.lockIconView.frame.size.height + titleTopMargin, self.view.bounds.size.width, 30);
    [self.view addSubview:titleLabel];
    
    // 创建消息标签 - 使用现代简洁的设计
    self.msgLabel = [[UILabel alloc] init];
    self.msgLabel.textAlignment = NSTextAlignmentCenter;
    self.msgLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.msgLabel.numberOfLines = 0;
    
    // 小屏幕上使用更小的字体和间距
    if (isSmallScreen) {
        self.msgLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    } else {
        self.msgLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    }
    
    // 设置消息标签位置 - 小屏幕上显著减小间距
    CGFloat msgLabelTopMargin = isSmallScreen ? 2 : 10; // 小屏幕上使用更小的间距
    CGFloat msgLabelHeight = isSmallScreen ? 25 : 40; // 小屏幕上显著减小高度
    
    self.msgLabel.frame = CGRectMake(30, titleLabel.frame.origin.y + titleLabel.frame.size.height + msgLabelTopMargin, 
                                    self.view.bounds.size.width - 60, msgLabelHeight);
    
    [self.view addSubview:self.msgLabel];
    
    // 设置消息文本
    if (self.lockType == FQLockTypeReset) {
        self.msgLabel.text = YZMsg(@"Draw_Original_Gesturepsd");
    } else {
        self.msgLabel.text = YZMsg(@"Draw_UnlockPattern");
    }
    
    // 创建锁视图配置
    self.lockConfig = [[FQLockConfig alloc] init];
    self.lockConfig.lockType = self.lockType; // 设置锁类型
    self.lockConfig.passwordKey = [NSString stringWithFormat:@"%@_%@", kPassword, self.userID];
    self.lockConfig.themeColor = [UIColor colorWithRed:0.25 green:0.48 blue:1.0 alpha:1.0]; // #407bff
    
    // 调整锁图标位置，在小屏幕上将其往上移动
    if (isSmallScreen) {
        // 小屏幕设备上将锁图标往上移动
        CGFloat newLockIconY = backButtonBottom + 2; // 显著减小与返回按钮的间距
        self.lockIconView.center = CGPointMake(screenWidth / 2, newLockIconY + self.lockIconView.frame.size.height/2);
        
        // 相应地调整标题标签位置
        titleLabel.frame = CGRectMake(20, self.lockIconView.frame.origin.y + self.lockIconView.frame.size.height + 5, 
                                      self.view.bounds.size.width - 40, titleLabel.frame.size.height);
    }
    
    // 计算标题和消息标签的实际高度
    CGSize titleSize = [titleLabel.text boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 40, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName: titleLabel.font}
                                                   context:nil].size;
    
    CGSize msgSize = [self.msgLabel.text boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 60, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName: self.msgLabel.font}
                                                    context:nil].size;
    
    // 调整标签高度以适应实际文本
    titleLabel.frame = CGRectMake(20, titleLabel.frame.origin.y, self.view.bounds.size.width - 40, titleSize.height + 5);
    self.msgLabel.frame = CGRectMake(30, titleLabel.frame.origin.y + titleLabel.frame.size.height + 5, 
                                   self.view.bounds.size.width - 60, msgSize.height + 5);
    
    // 确保手势绘制面板从标题下面开始布局 - 使用参考点
    CGFloat msgLabelBottom = self.msgLabel.frame.origin.y + self.msgLabel.frame.size.height;
    
    // 小屏幕设备上减小手势面板的高度和调整间距
    CGFloat gestureDrawingPanelHeight;
    CGFloat gestureDrawingMargin;
    BOOL useDirectFrameSetting = NO; // 标记是否直接设置面板的frame
    
    // 强制从第二个标题控件下面开始，不进行屏幕居中
    useDirectFrameSetting = YES; // 始终直接设置frame
    
    // 计算面板的顶部位置 - 强制从消息标签底部加5个像素开始
    CGFloat panelTop = msgLabelBottom + 5; // 固定为5像素的间距
    
    // 设置顶部对齐属性，确保从第二个标题控件下面开始
    self.lockConfig.lockViewTopY = panelTop;
    
    // 清除其他可能影响定位的属性
//    self.lockConfig.lockViewCenterY = 0; // 不使用中心对齐
    // 设置锁视图的其他属性
    self.lockConfig.lineWidth = 1.0; // 线条宽度
    self.lockConfig.dotRadius = 15.0; // 圆点半径
    self.lockConfig.dotInnerRadius = 5.0; // 内圆半径
    self.lockConfig.errorColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0]; // 错误颜色 #FF4040
    
    // 创建锁视图 - 注意我们不使用config中的定位属性
    // 清除可能影响定位的属性
    self.lockConfig.lockViewTopY = 0;
//    self.lockConfig.lockViewCenterY = 0;
    
    self.lockView = [[FQLockGestureView alloc] initWithConfig:self.lockConfig];
    self.lockView.delegate = self;
    
    // 计算面板的宽度（正方形）
    CGFloat panelWidth = screenWidth * 0.85; // 使用屏幕宽度的85%作为面板宽度
    if (screenWidth > 375) { // 大屏幕设备限制最大宽度
        panelWidth = 320; // 限制最大宽度
    }
    
    // 从第二个子标题控件（绘制解锁图案文本标签）下面5个像素处开始对齐
    CGFloat panelY = msgLabelBottom + 5; // 从消息标签底部加5个像素开始
    
    // 不进行水平居中，使用固定的左边距离
    CGFloat panelLeftMargin = 20; // 使用固定的左边距离
    
    // 先设置锁视图的frame，然后再添加到父视图
    self.lockView.frame = CGRectMake(panelLeftMargin, panelY, panelWidth, panelWidth); // 保持正方形
    
    // 添加到父视图
    [self.view addSubview:self.lockView];
    
    // 强制布局更新
    [self.lockView setNeedsLayout];
    [self.lockView layoutIfNeeded];
    
    if (self.lockType == FQLockTypeLogin) {
        if ([FQLockHelper isLocalGestureEnableForUserId:self.userID]) {
            // 创建现代化的"忘记手势密码"按钮
            self.forget_button = [[UIButton alloc] init];
            
            // 设置按钮外观
            self.forget_button.backgroundColor = [UIColor colorWithRed:0.25 green:0.48 blue:1.0 alpha:0.1]; // 半透明背景
            self.forget_button.layer.cornerRadius = 20;
            self.forget_button.layer.borderWidth = 1.0;
            self.forget_button.layer.borderColor = [UIColor colorWithRed:0.25 green:0.48 blue:1.0 alpha:0.3].CGColor;
            
            // 设置按钮文本
            [self.forget_button setTitle:YZMsg(@"忘记手势密码") forState:UIControlStateNormal];
            [self.forget_button setTitleColor:[UIColor colorWithRed:0.25 green:0.48 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            self.forget_button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            
            // 设置按钮位置 - 居中底部
            CGFloat bottomMargin = 80;
            // 适配底部安全区域
            if (@available(iOS 11.0, *)) {
                bottomMargin += self.view.safeAreaInsets.bottom;
            }
            self.forget_button.frame = CGRectMake((self.view.frame.size.width - 160) / 2, self.view.frame.size.height - bottomMargin, 160, 40);
            
            // 添加点击事件
            [self.forget_button addTarget:self action:@selector(forget_buttonClick) forControlEvents:UIControlEventTouchUpInside];
            
            // 添加按钮阴影
            self.forget_button.layer.shadowColor = [UIColor colorWithRed:0.25 green:0.48 blue:1.0 alpha:0.3].CGColor;
            self.forget_button.layer.shadowOffset = CGSizeMake(0, 2);
            self.forget_button.layer.shadowRadius = 4.0;
            self.forget_button.layer.shadowOpacity = 0.5;
            
            [self.view addSubview:self.forget_button];
        }
    } else if (self.lockType == FQLockTypeSetting||self.lockType == FQLockTypeReset) {
        // 获取屏幕尺寸和安全区域
        CGFloat screenWidth = self.view.bounds.size.width;
        CGFloat screenHeight = self.view.bounds.size.height;
        CGFloat bottomSafeArea = 0;
        
        if (@available(iOS 11.0, *)) {
            UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
            bottomSafeArea = window.safeAreaInsets.bottom;
        }
        
        // 获取手势绘制面板的底部位置
        CGFloat lockViewBottom = self.lockView.frame.origin.y + self.lockView.frame.size.height;
        
        // 定义各元素间的间距常量
        CGFloat bottomMargin = 10; // 元素距离底部的距离
        CGFloat elementSpacing = 10; // 元素之间的间距
        
        // 创建关闭手势密码按钮
        UIButton *forget_button = [[UIButton alloc] init];
        
        // 设置按钮样式为现代化风格
        forget_button.backgroundColor = [UIColor colorWithRed:0.25 green:0.48 blue:1.0 alpha:0.1]; // 半透明背景
        forget_button.layer.cornerRadius = 20;
        forget_button.layer.borderWidth = 1.0;
        forget_button.layer.borderColor = [UIColor colorWithRed:0.25 green:0.48 blue:1.0 alpha:0.3].CGColor;
        
        // 设置按钮文本和样式
        [forget_button setTitle:self.lockType == FQLockTypeReset?YZMsg(@"Turn_GesturePasscode"):YZMsg(@"Gesture_Neglect") forState:UIControlStateNormal];
        [forget_button setTitleColor:[UIColor colorWithRed:0.25 green:0.48 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        forget_button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        forget_button.tag = 100001;
        // 添加阴影效果使按钮更突出
        forget_button.layer.shadowColor = [UIColor colorWithRed:0.25 green:0.48 blue:1.0 alpha:0.5].CGColor;
        forget_button.layer.shadowOffset = CGSizeMake(0, 2);
        forget_button.layer.shadowRadius = 4.0;
        forget_button.layer.shadowOpacity = 0.5;
        
        if (self.lockType == FQLockTypeReset) {
            [forget_button addTarget:self action:@selector(turnOffGesturePassword) forControlEvents:UIControlEventTouchUpInside];
        }else{
            // 添加点击事件
            [forget_button addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        // 创建安全提示视图 - 完全匹配HTML中的风格
        UIView *securityTipView = [[UIView alloc] init];
        // rgba(12, 24, 36, 0.6) 背景色
        securityTipView.backgroundColor = [UIColor colorWithRed:12/255.0 green:24/255.0 blue:36/255.0 alpha:0.6];
        securityTipView.layer.cornerRadius = 8;
        // 添加模糊效果
        if (@available(iOS 13.0, *)) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurView.frame = securityTipView.bounds;
            blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurView.alpha = 0.5;
            blurView.layer.cornerRadius = 8;
            blurView.clipsToBounds = YES;
            [securityTipView addSubview:blurView];
        }
        
        // 添加左侧边框 - 对应HTML中的border-left
        CALayer *leftBorder = [CALayer layer];
        leftBorder.frame = CGRectMake(0, 0, 3, 0); // 高度将在后面设置
        leftBorder.backgroundColor = [UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:1.0].CGColor; // #407bff
        [securityTipView.layer addSublayer:leftBorder];
        
        // 添加阴影效果 - 对应HTML中的box-shadow
        securityTipView.layer.shadowColor = [UIColor blackColor].CGColor;
        securityTipView.layer.shadowOffset = CGSizeMake(0, 4);
        securityTipView.layer.shadowRadius = 6.0;
        securityTipView.layer.shadowOpacity = 0.2;
        
        // 创建信息图标 - 使用SVG路径绘制
        UIView *iconContainer = [[UIView alloc] initWithFrame:CGRectMake(20, 16, 20, 20)];
        
        CAShapeLayer *infoIconLayer = [CAShapeLayer layer];
        infoIconLayer.frame = iconContainer.bounds;
        infoIconLayer.strokeColor = [UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:1.0].CGColor; // #407bff
        infoIconLayer.fillColor = [UIColor clearColor].CGColor;
        infoIconLayer.lineWidth = 2.0;
        infoIconLayer.lineCap = kCALineCapRound;
        infoIconLayer.lineJoin = kCALineJoinRound;
        
        // 创建圆形路径
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 20, 20)];
        
        // 创建竖线路径 - 对应"M12 16V12"
        UIBezierPath *verticalLinePath = [UIBezierPath bezierPath];
        [verticalLinePath moveToPoint:CGPointMake(10, 16)];
        [verticalLinePath addLineToPoint:CGPointMake(10, 12)];
        
        // 创建点路径 - 对应"M12 8H12.01"
        UIBezierPath *dotPath = [UIBezierPath bezierPath];
        [dotPath moveToPoint:CGPointMake(10, 8)];
        [dotPath addLineToPoint:CGPointMake(10.01, 8)];
        
        // 合并路径
        UIBezierPath *combinedPath = [UIBezierPath bezierPath];
        [combinedPath appendPath:circlePath];
        [combinedPath appendPath:verticalLinePath];
        [combinedPath appendPath:dotPath];
        
        infoIconLayer.path = combinedPath.CGPath;
        [iconContainer.layer addSublayer:infoIconLayer];
        [securityTipView addSubview:iconContainer];
        
        // 创建安全提示文本标签 - 分为两部分：粗体标题和正文
        NSString *tipText = YZMsg(@"Turn_GesturePasscode_Warn");
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:tipText];
        
        // 设置“安全提示：”部分为粗体
        NSRange strongRange = [tipText rangeOfString:@"安全提示："];
        if (strongRange.location != NSNotFound) {
            [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:strongRange];
            [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:strongRange];
        }
        
        // 设置其余文本样式
        UILabel *securityTipLabel = [[UILabel alloc] init];
        securityTipLabel.attributedText = attributedText;
        securityTipLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8]; // rgba(255, 255, 255, 0.8)
        securityTipLabel.font = [UIFont systemFontOfSize:14];
        securityTipLabel.numberOfLines = 0;
        securityTipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        securityTipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        // 计算文本实际所需的高度
        CGSize maxSize = CGSizeMake(screenWidth - 60 - 55, CGFLOAT_MAX);
        CGRect textRect = [securityTipLabel.text boundingRectWithSize:maxSize
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: securityTipLabel.font}
                                                 context:nil];
        
        // 设置标签位置和大小
        securityTipLabel.frame = CGRectMake(45, 10, screenWidth - 60 - 55, textRect.size.height);
        [securityTipView addSubview:securityTipLabel];
        
        // 计算安全提示视图的高度
        CGFloat bottomPadding = 10; // 底部边距
        CGFloat tipViewHeight = securityTipLabel.frame.origin.y + securityTipLabel.frame.size.height + bottomPadding;
        
        // 计算按钮和提示视图的总高度
        CGFloat buttonHeight = 40;
        CGFloat totalElementsHeight = buttonHeight + elementSpacing + tipViewHeight;
        
        // 计算底部安全距离
        CGFloat safeBottom = screenHeight - bottomSafeArea - bottomMargin;
        
        // 首先尝试从底部往上对齐
        CGFloat tipViewBottom = safeBottom;
        CGFloat tipViewTop = tipViewBottom - tipViewHeight;
        CGFloat buttonBottom = tipViewTop - elementSpacing;
        CGFloat buttonTop = buttonBottom - buttonHeight;
        
        // 检查是否会与手势绘制面板重叠
        if (buttonTop < lockViewBottom + elementSpacing) {
            // 如果重叠，则从手势绘制面板底部往下对齐
            buttonTop = lockViewBottom + elementSpacing;
            buttonBottom = buttonTop + buttonHeight;
            tipViewTop = buttonBottom + elementSpacing;
            tipViewBottom = tipViewTop + tipViewHeight;
            
            // 检查是否超出屏幕底部
            if (tipViewBottom > safeBottom) {
                // 如果超出屏幕，需要调整顶部元素的位置
                // 调整锁图标和标题的位置，使其更靠近顶部
                // 这里只是记录超出情况，实际调整在屏幕高度不足时进行
                CGFloat overflow = tipViewBottom - safeBottom;
                // 如果超出屏幕底部，但超出不多，可以将安全提示视图缩小
                if (overflow <= 20) {
                    tipViewBottom = safeBottom;
                    tipViewTop = tipViewBottom - tipViewHeight + overflow;
                }
            }
        }
        
        // 设置按钮位置
        forget_button.frame = CGRectMake((screenWidth - 200) / 2, buttonTop, 200, buttonHeight);
        [self.view addSubview:forget_button];
        
        // 设置安全提示视图位置
        securityTipView.frame = CGRectMake(30, tipViewTop, screenWidth - 60, tipViewHeight);
        [self.view addSubview:securityTipView];
        
        // 最后再次检查是否超出屏幕底部
        CGFloat finalTipBottom = securityTipView.frame.origin.y + securityTipView.frame.size.height;
        if (finalTipBottom > safeBottom) {
            // 如果超出屏幕，调整位置到屏幕底部
            securityTipView.frame = CGRectMake(30, safeBottom - securityTipView.frame.size.height, screenWidth - 60, securityTipView.frame.size.height);
        }
        // 只在重置手势密码时初始隐藏按钮，设置手势密码时显示
        if (self.lockType == FQLockTypeReset) {
            forget_button.hidden = YES;
        } else if (self.lockType == FQLockTypeSetting) {
            forget_button.hidden = NO; // 确保设置手势密码时忽略按钮显示
        }
        
    }
    
//    if (self.lockType == FQLockTypeReset) {
//        UIButton *forget_button = [[UIButton alloc] init];
//        forget_button.frame = CGRectMake(self.view.frame.size.width *0.5 - 45, self.view.frame.size.height - 50, 90, 20);
//        [forget_button setTitle:NSLocalizedString(@"忘记手势密码", nil) forState:UIControlStateNormal];
//        [forget_button setTitleColor:[UIColor colorFromHexString:@"#0984F9"] forState:UIControlStateNormal];
//        forget_button.titleLabel.font = [UIFont systemFontOfSize:14];
//        [forget_button addTarget:self action:@selector(forget_buttonClick) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:forget_button];
//        self.forget_button = forget_button;
//    }
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

// 关闭手势密码
- (void)turnOffGesturePassword {
    // 显示确认对话框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert")
                                                                             message:YZMsg(@"Turn_GesturePasscode_close")
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    // 添加确认按钮
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 关闭手势密码
        [FQLockHelper setLocalGestureEnable:NO forUserId:self.userID];
        // 返回上一页
        [self goBack];
    }];
    [alertController addAction:confirmAction];
    
    // 显示对话框
    [self presentViewController:alertController animated:YES completion:nil];
}

/* 移除指纹和面容ID解锁功能
- (void)faceID_buttonClick {
    __weak typeof(self) weakSelf = self;
    [FQBiometryContext biometryAuthWithSucceedHandler:^{
        if (weakSelf.localLockBlock) {
            weakSelf.localLockBlock(YES);
        }
    } failureHandler:^(FQBiometryError errorCode) {
        
    }];
}

- (void)forget_buttonClick {
//    [FQAlertController showAlertWithController:self style:nil title:@"忘记手势密码" message:@"忘记手势密码需要重新登录，登录后锁屏保护自动关闭" leftActionText:@"取消" rightActionText:@"重新登录" leftActionHandler:^{
//
//    } rightActionHandler:^{
//        [TKLocalAuthHelper setLocalAuthEnable:NO forUserId:[self.authDelegate userId]];
//        [TKLocalAuthHelper setLocalGestureEnable:NO forUserId:[self.authDelegate userId]];
//        [self.authDelegate logoutAndShowLoginWithIdentity];
//    }];
    [FQLockHelper setLocalGestureEnable:NO forUserId:self.userID];
    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:^{
     
    }];
    [[YBToolClass sharedInstance] quitLogin:YES];
}

- (void)switch_buttonClick {
//    [FQAlertController showAlertWithController:self style:nil title:@"切换其他账号" message:@"是否要切换其他账号登录" leftActionText:@"取消" rightActionText:@"登录" leftActionHandler:^{
//
//    } rightActionHandler:^{
//        [self.authDelegate logoutAndShowLoginWithIdentity];
//    }];
}

*/

/* 移除指纹和面容ID解锁功能
- (void)authBtnClick {
    __weak typeof(self) weakSelf = self;
    [FQBiometryContext biometryAuthWithSucceedHandler:^{
        if (weakSelf.localLockBlock) {
            weakSelf.localLockBlock(YES);
        }
    } failureHandler:^(FQBiometryError errorCode) {
        
    }];
}

#pragma mark - <FQGestureLockViewDelegate>

/// 连线个数少于最少连接数，通知代理
/// @param view LockView
/// @param type <#type description#>
/// @param gesture 手势密码
*/

#pragma mark - FQGestureLockViewDelegate

- (void)fq_gestureLockView:(FQLockGestureView *)view type:(FQLockType)type connectNumberLessThanNeedWithGesture:(NSString *)gesture {
    self.msgLabel.text = YZMsg(@"Gesture_redraw");
    self.msgLabel.textColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0]; // #FF4040
    
    // 添加错误动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.5;
    animation.values = @[@(-10), @(10), @(-8), @(8), @(-5), @(5), @(0)];
    [self.msgLabel.layer addAnimation:animation forKey:@"shake"];
}

/// 第一次设置手势密码
/// @param view LockView
/// @param type <#type description#>
/// @param gesture 第一次手势密码
- (void)fq_gestureLockView:(FQLockGestureView *)view type:(FQLockType)type didCompleteSetFirstGesture:(NSString *)gesture {
    self.msgLabel.text = YZMsg(@"Draw_UnlockPatternAgain");
    self.msgLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
}

/// 第二次设置手势密码
/// @param view LockView
/// @param type <#type description#>
/// @param gesture 第二次手势密码
/// @param equal 第二次和第一次的手势密码匹配结果
- (void)fq_gestureLockView:(FQLockGestureView *)view type:(FQLockType)type didCompleteSetSecondGesture:(NSString *)gesture result:(BOOL)equal {
    if (equal) {
        [FQLockHelper setLocalGestureEnable:YES forUserId:self.userID];
        self.msgLabel.text = YZMsg(@"Successfully_GestureSet");
        self.msgLabel.textColor = [UIColor colorWithRed:0.18 green:0.83 blue:0.45 alpha:1.0]; // #2ed573
        
        // 添加成功动画
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = @(1.0);
        scaleAnimation.toValue = @(1.1);
        scaleAnimation.duration = 0.2;
        scaleAnimation.autoreverses = YES;
        [self.msgLabel.layer addAnimation:scaleAnimation forKey:@"success"];
        if (self.localLockBlock) {
            self.localLockBlock(YES);
        }
        [self performSelector:@selector(goBack) withObject:nil afterDelay:0.5];
        
    } else {
        self.msgLabel.text = YZMsg(@"LastDraw_Inconsistent");
        self.msgLabel.textColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0]; // #FF4040
        
        // 添加错误动画
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.duration = 0.5;
        animation.values = @[@(-10), @(10), @(-8), @(8), @(-5), @(5), @(0)];
        [self.msgLabel.layer addAnimation:animation forKey:@"shake"];
    }
}

/// 验证手势密码
/// - Parameters:
///   - view: LockView
///   - type: <#type description#>
///   - gesture: 验证的手势密码
///   - equal: 验证是否通过
- (void)fq_gestureLockView:(FQLockGestureView *)view type:(FQLockType)type didCompleteVerifyGesture:(NSString *)gesture result:(BOOL)equal {
    NSDictionary *dict = @{ @"eventType": @(0),
                             @"gesture_status": equal ? @(1) : @(0)};
    [MobClick event:@"gesture_passwork_click" attributes:dict];
    if (equal) {
        self.forget_button.hidden = YES;
        
        if (type == FQLockTypeClose) {
            // 关闭手势密码
            self.msgLabel.text = YZMsg(@"Draw_UnlockPattern");
            self.msgLabel.textColor = [UIColor colorFromHexString:@"#939599"];
            [FQLockHelper setLocalGestureEnable:NO forUserId:self.userID];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:0.5];
        } else if (type == FQLockTypeReset) {
            // 重置密码：验证旧密码成功后，提示用户设置新密码
            self.msgLabel.text = YZMsg(@"Draw_UnlockPattern");
            self.msgLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
            
            // 添加成功动画
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnimation.fromValue = @(1.0);
            scaleAnimation.toValue = @(1.1);
            scaleAnimation.duration = 0.2;
            scaleAnimation.autoreverses = YES;
            [self.msgLabel.layer addAnimation:scaleAnimation forKey:@"success"];
            
            UIButton *forgetBt = [self.view viewWithTag:100001];
            if (forgetBt) {
                forgetBt.hidden = NO;
            }
        } else {
            // 其他情况（登录验证成功）
            self.msgLabel.text = YZMsg(@"Draw_UnlockPattern");
            self.msgLabel.textColor = [UIColor colorFromHexString:@"#939599"];
            
            if (self.localLockBlock) {
                self.localLockBlock(YES);
            }
        }
    } else {
        if (type == FQLockTypeLogin) {
            // 登录验证失败
            if(self.loginNum <= 0){
                // 登录失败次数过多，重置手势密码并退出登录
                [FQLockHelper setLocalGestureEnable:NO forUserId:self.userID];
                [self.navigationController popViewControllerAnimated:NO];
                __weak typeof(self) weakSelf = self;
                [self dismissViewControllerAnimated:NO completion:^{
                    weakSelf.localLockBlock(YES);
                }];
                [[YBToolClass sharedInstance] quitLogin:YES];
            } else {
                // 显示剩余尝试次数
                self.msgLabel.text = [NSString stringWithFormat:YZMsg(@"Draw_PasswordErrorNum%d"),self.loginNum];
                self.msgLabel.textColor = [UIColor colorFromHexString:@"#FF4040"];
            }
            self.loginNum--;
        } else if (type == FQLockTypeReset) {
            // 重置密码：验证旧密码失败
            self.msgLabel.text = YZMsg(@"Draw_PasswordError");
            self.msgLabel.textColor = [UIColor colorFromHexString:@"#FF4040"];
            
            // 添加错误动画
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.duration = 0.5;
            animation.values = @[@(-10), @(10), @(-8), @(8), @(-5), @(5), @(0)];
            [self.msgLabel.layer addAnimation:animation forKey:@"shake"];
        } else {
            // 其他验证失败情况
            self.msgLabel.text = YZMsg(@"Draw_PasswordError");
            self.msgLabel.textColor = [UIColor colorFromHexString:@"#FF4040"];
            
            // 添加错误动画
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.duration = 0.5;
            animation.values = @[@(-10), @(10), @(-8), @(8), @(-5), @(5), @(0)];
            [self.msgLabel.layer addAnimation:animation forKey:@"shake"];
        }
    }
}

- (void)triggerPulseAnimationForLayer:(CALayer *)layer {
    // 重置图层状态
    [layer removeAllAnimations];
    
    // 使用两种动画组合增强效果：阴影动画和缩放动画
    
    // 1. 阴影动画 - 增强阴影效果
    CAKeyframeAnimation *shadowRadiusAnimation = [CAKeyframeAnimation animationWithKeyPath:@"shadowRadius"];
    shadowRadiusAnimation.values = @[@0, @20, @0]; // 增大阴影半径使其更明显
    shadowRadiusAnimation.keyTimes = @[@0.0, @0.7, @1.0];
    
    // 阴影颜色动画
    CAKeyframeAnimation *shadowColorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"shadowColor"];
    shadowColorAnimation.values = @[
        (__bridge id)[UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:0.7].CGColor, // 增强初始透明度
        (__bridge id)[UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:0.0].CGColor,
        (__bridge id)[UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:0.0].CGColor
    ];
    shadowColorAnimation.keyTimes = @[@0.0, @0.7, @1.0];
    
    // 阴影透明度动画
    CAKeyframeAnimation *shadowOpacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowOpacityAnimation.values = @[@1.0, @0.7, @0.0];
    shadowOpacityAnimation.keyTimes = @[@0.0, @0.7, @1.0];
    
    // 2. 缩放动画 - 增加扩散效果
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[@1.0, @1.5, @1.0]; // 先放大再缩小
    scaleAnimation.keyTimes = @[@0.0, @0.7, @1.0];
    
    // 边框颜色动画
    CAKeyframeAnimation *borderColorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"borderColor"];
    borderColorAnimation.values = @[
        (__bridge id)[UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:0.5].CGColor,
        (__bridge id)[UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:0.0].CGColor,
        (__bridge id)[UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:0.0].CGColor
    ];
    borderColorAnimation.keyTimes = @[@0.0, @0.7, @1.0];
    
    // 组合所有动画
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[shadowRadiusAnimation, shadowColorAnimation, shadowOpacityAnimation, scaleAnimation, borderColorAnimation];
    animationGroup.duration = 2.0;
    animationGroup.repeatCount = 1;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // 添加动画
    [layer addAnimation:animationGroup forKey:@"pulseAnimation"];
    
    // 动画结束后重置图层状态
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        layer.transform = CATransform3DIdentity; // 重置变换
        layer.borderColor = [UIColor colorWithRed:64/255.0 green:123/255.0 blue:255/255.0 alpha:0.4].CGColor; // 重置边框颜色
    });
}

@end
