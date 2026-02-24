//
//  FQLockGestureView.m
//  PhoneLiveSDK
//
//  Created on 2025/04/07.
//

#import "FQLockGestureView.h"

// 定义点的结构
typedef struct {
    CGPoint point;
    BOOL selected;
    NSInteger index;
    CFTimeInterval selectTime; // 选中时间，用于动画效果
} FQLockDot;

@interface FQLockGestureView() <CAAnimationDelegate>

@property (nonatomic, strong) FQLockConfig *config;
@property (nonatomic, strong) NSMutableArray *selectedDots;
@property (nonatomic, strong) NSMutableArray *allDots;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, strong) NSString *firstGesture;
@property (nonatomic, assign) BOOL isError;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, assign) BOOL isVerifiedOldPassword;
@property (nonatomic, strong) NSMutableArray *animationLayers; // 用于存储动画图层

// 用于存储手势密码的UserDefaults
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation FQLockGestureView

#pragma mark - 初始化方法

- (instancetype)initWithConfig:(FQLockConfig *)config {
    // 计算适配不同屏幕尺寸的视图大小
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // 初始化动画图层数组
    self.animationLayers = [NSMutableArray array];
    
    // 设置固定宽度，确保在不同设备上保持一致
    CGFloat width = MIN(screenWidth * 0.85, 350); // 最大宽度350，或者屏幕宽度的85%
    
    // 计算边距，确保水平居中
    CGFloat edgeMargin = (screenWidth - width) / 2;
    
    // 计算高度，通常与宽度相同以保持正方形
    CGFloat height = width;
    
    // 对于超长屏幕，调整高度
    CGFloat aspectRatio = screenHeight / screenWidth;
    if (aspectRatio > 2.0) { // iPhone X/XS/11 Pro/12/13/14/15 系列
        height = width * 0.9;
    }
    
    // 创建视图框架，确保水平居中
    CGRect frame = CGRectMake(edgeMargin, 0, width, height);
    
    // 仅设置水平位置，垂直位置将由外部直接设置
    frame.origin.y = 0; // 初始化为0，稍后将被外部设置覆盖
    
    self = [super initWithFrame:frame];
    if (self) {
        _config = config;
        _selectedDots = [NSMutableArray array];
        _allDots = [NSMutableArray array];
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _isError = NO;
        _isFinished = NO;
        _isVerifiedOldPassword = NO;
        
        // 添加屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        [self setupUI];
        [self setupGesture];
    }
    return self;
}

- (void)updateConfig:(FQLockConfig *)config {
    _config = config;
    _isError = NO;
    _isFinished = NO;
    _isVerifiedOldPassword = NO;
    _firstGesture = nil;
    [_selectedDots removeAllObjects];
    
    // 更新点的位置
    [self updateDotsPositionForCurrentScreenSize];
    
    [self setNeedsDisplay];
}

#pragma mark - UI设置

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    // 初始化点的位置
    [self updateDotsPositionForCurrentScreenSize];
}

- (void)updateDotsPositionForCurrentScreenSize {
    // 清除现有的点
    [_allDots removeAllObjects];
    
    // 获取当前视图尺寸
    CGSize viewSize = self.bounds.size;
    
    // 计算点的大小和间距，根据视图大小自适应
    CGFloat dotRadius = _config.dotRadius;
    if (dotRadius <= 0) dotRadius = 15.0; // 默认值
    
    CGFloat dotSize = dotRadius * 2;
    
    // 计算点之间的间距
    CGFloat gridSize = MIN(viewSize.width, viewSize.height) * 0.9; // 网格占据视图的 90%
    CGFloat spacing = (gridSize - 3 * dotSize) / 2; // 点之间的间距
    
    // 计算起始坐标，使网格居中
    CGFloat startX = (viewSize.width - gridSize) / 2;
    CGFloat startY = (viewSize.height - gridSize) / 2;
    
    // 中心点的位置
    CGFloat centerX = startX + dotSize/2 + (dotSize + spacing);
    CGFloat centerY = startY + dotSize/2 + (dotSize + spacing);
    
    // 额外的间距（向内移动5个像素）
    CGFloat extraPadding = 5.0;
    
    // 创建 3x3 的点阵
    for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
            CGFloat x, y;
            
            // 中心点不变，其他点向中心移动
            if (row == 1 && col == 1) { // 中心点
                x = centerX;
                y = centerY;
            } else { // 其他点
                // 计算原始位置
                x = startX + col * (dotSize + spacing) + dotSize/2;
                y = startY + row * (dotSize + spacing) + dotSize/2;
                
                // 根据位置调整
                if (col == 0) { // 左侧列
                    x += extraPadding;
                } else if (col == 2) { // 右侧列
                    x -= extraPadding;
                }
                
                if (row == 0) { // 上方行
                    y += extraPadding;
                } else if (row == 2) { // 下方行
                    y -= extraPadding;
                }
            }
            
            FQLockDot dot;
            dot.point = CGPointMake(x, y);
            dot.selected = NO;
            dot.index = row * 3 + col;
            
            [_allDots addObject:[NSValue valueWithBytes:&dot objCType:@encode(FQLockDot)]];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)orientationChanged:(NSNotification *)notification {
    // 屏幕旋转或尺寸变化时更新点的位置
    [self updateDotsPositionForCurrentScreenSize];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 当视图布局变化时更新点的位置
    [self updateDotsPositionForCurrentScreenSize];
}

- (void)dealloc {
    // 移除通知观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 清除所有动画图层
    for (CALayer *layer in self.animationLayers) {
        [layer removeFromSuperlayer];
    }
    [self.animationLayers removeAllObjects];
}

// 添加点选中时的动画效果
- (void)addAnimationForDotAtPoint:(CGPoint)point {
    UIColor *animationColor = _isError ? _config.errorColor : _config.themeColor;
    
    // 1. 创建内圆放大动画层 - 中间蓝色圆形
    CALayer *innerCircleLayer = [CALayer layer];
    innerCircleLayer.position = point;
    innerCircleLayer.bounds = CGRectMake(0, 0, _config.dotRadius * 1.2, _config.dotRadius * 1.2); // 初始大小稍小
    innerCircleLayer.cornerRadius = _config.dotRadius * 0.6;
    innerCircleLayer.backgroundColor = animationColor.CGColor;
    innerCircleLayer.opacity = 1.0; // 完全不透明
    [self.layer addSublayer:innerCircleLayer];
    [self.animationLayers addObject:innerCircleLayer];
    
    // 内圆放大动画
    CABasicAnimation *innerScaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    innerScaleAnimation.fromValue = @0.8; // 从小开始
    innerScaleAnimation.toValue = @1.0; // 放大到正常大小
    innerScaleAnimation.duration = 0.2;
    innerScaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [innerCircleLayer addAnimation:innerScaleAnimation forKey:@"innerScale"];
    
    // 2. 创建外圈动画层 - 蓝色外圈边框
    CALayer *outerCircleLayer = [CALayer layer];
    outerCircleLayer.position = point;
    // 外圈比正常点的直径大 2 像素
    CGFloat outerRadius = _config.dotRadius + 1.0; // 增加 1 像素半径（相当于直径增加 2 像素）
    outerCircleLayer.bounds = CGRectMake(0, 0, outerRadius * 2, outerRadius * 2);
    outerCircleLayer.cornerRadius = outerRadius;
    outerCircleLayer.borderWidth = 1.5; // 边框宽度
    outerCircleLayer.borderColor = animationColor.CGColor; // 蓝色边框
    outerCircleLayer.backgroundColor = [UIColor clearColor].CGColor; // 透明背景
    outerCircleLayer.opacity = 0.8;
    [self.layer insertSublayer:outerCircleLayer below:innerCircleLayer]; // 确保外圈在内圆下面
    [self.animationLayers addObject:outerCircleLayer];
    
    // 外圈放大动画
    CABasicAnimation *outerScaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    outerScaleAnimation.fromValue = @0.9; // 从小开始
    outerScaleAnimation.toValue = @1.0; // 放大到正常大小
    outerScaleAnimation.duration = 0.25;
    outerScaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [outerCircleLayer addAnimation:outerScaleAnimation forKey:@"outerScale"];
}

#pragma mark - 手势设置

- (void)setupGesture {
    // 添加拖动手势识别
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
    
    // 添加点击手势识别，用于单点触摸响应
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
    
    // 移除长按手势识别器，避免与拖动手势冲突
}

#pragma mark - 手势处理

// 处理点击手势
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    [self handleTouchAtPoint:point isFinal:YES];
}

// 长按手势已移除，避免与拖动手势冲突

// 处理拖动手势
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self resetGesture];
        [self checkDotAtPoint:point];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        // 更新当前点位置
        _currentPoint = point;
        
        // 检查是否有新的点可以被选中
        [self checkDotAtPoint:point];
        
        // 强制重绘
        [self setNeedsDisplay];
    } else if (gesture.state == UIGestureRecognizerStateEnded || 
               gesture.state == UIGestureRecognizerStateCancelled || 
               gesture.state == UIGestureRecognizerStateFailed) {
        // 处理手势结束、取消或失败的情况
        [self handleTouchAtPoint:point isFinal:YES];
    }
}

// 统一处理触摸点的方法
- (void)handleTouchAtPoint:(CGPoint)point isFinal:(BOOL)isFinal {
    if (isFinal) {
        _isFinished = YES;
        [self handleGestureComplete];
    }
    [self setNeedsDisplay];
}

- (void)checkDotAtPoint:(CGPoint)point {
    // 增加检测半径，使选择更容易
    CGFloat detectionRadius = 35; // 增加检测半径，原来是30
    
    for (NSValue *value in _allDots) {
        FQLockDot dot;
        [value getValue:&dot];
        
        // 计算点击位置与点的距离
        CGFloat distance = sqrt(pow(point.x - dot.point.x, 2) + pow(point.y - dot.point.y, 2));
        
        // 如果距离小于阈值，立即显示动画效果
        if (distance < detectionRadius) {
            // 如果该点已经被选中，则跳过
            if ([self isDotSelected:dot.index]) {
                continue;
            }
            
            // 选中该点
            FQLockDot newDot = dot;
            newDot.selected = YES;
            newDot.selectTime = CACurrentMediaTime(); // 记录选中时间
            
            // 更新allDots中的点
            NSInteger index = [_allDots indexOfObject:value];
            [_allDots replaceObjectAtIndex:index withObject:[NSValue valueWithBytes:&newDot objCType:@encode(FQLockDot)]];
            
            // 添加到已选中的点
            [_selectedDots addObject:@(dot.index)];
            
            // 震动反馈
            UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
            [generator prepare];
            [generator impactOccurred];
            
            // 立即添加动画效果 - 在手指按下的瞬间就显示
            [self addAnimationForDotAtPoint:dot.point];
            
            // 更新当前点为选中点的位置，避免连线断开
            _currentPoint = dot.point;
            
            [self setNeedsDisplay];
            break;
        }
    }
}

- (BOOL)isDotSelected:(NSInteger)index {
    return [_selectedDots containsObject:@(index)];
}

- (void)resetGesture {
    _isError = NO;
    _isFinished = NO;
    [_selectedDots removeAllObjects];
    _currentPoint = CGPointZero;
    
    // 移除所有动画图层
    for (CALayer *layer in self.animationLayers) {
        [layer removeFromSuperlayer];
    }
    [self.animationLayers removeAllObjects];
    
    // 重置所有点的状态
    NSMutableArray *newDots = [NSMutableArray array];
    for (NSValue *value in _allDots) {
        FQLockDot dot;
        [value getValue:&dot];
        dot.selected = NO;
        dot.selectTime = 0;
        [newDots addObject:[NSValue valueWithBytes:&dot objCType:@encode(FQLockDot)]];
    }
    
    _allDots = newDots;
    
    // 如果是重置密码模式且已经验证了旧密码，不要重置_isVerifiedOldPassword
    // 这样用户可以继续设置新密码
    if (_config.lockType != FQLockTypeReset || !_isVerifiedOldPassword) {
        // 对于其他模式，重置所有状态
        _isVerifiedOldPassword = NO;
    }
    
    [self setNeedsDisplay];
}

- (void)handleSettingGesture:(NSString *)gesture {
    if (!_firstGesture) {
        // 第一次设置
        _firstGesture = gesture;
        
        if ([self.delegate respondsToSelector:@selector(fq_gestureLockView:type:didCompleteSetFirstGesture:)]) {
            [self.delegate fq_gestureLockView:self type:_config.lockType didCompleteSetFirstGesture:gesture];
        }
     
        [self performSelector:@selector(resetGesture) withObject:nil afterDelay:0.5];
    } else {
        // 第二次设置，需要与第一次匹配
        BOOL isEqual = [gesture isEqualToString:_firstGesture];
        
        if (isEqual) {
            // 保存密码
            [self saveGesturePassword:gesture];
        } else {
            _isError = YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(fq_gestureLockView:type:didCompleteSetSecondGesture:result:)]) {
            [self.delegate fq_gestureLockView:self type:_config.lockType didCompleteSetSecondGesture:gesture result:isEqual];
        }
       
        [self performSelector:@selector(resetGesture) withObject:nil afterDelay:0.5];
        
        if (isEqual) {
            _firstGesture = nil;
        }
    }
}

- (void)handleVerifyGesture:(NSString *)gesture {
    // 验证密码
    NSString *savedPassword = [self getSavedGesturePassword];
    BOOL isEqual = [gesture isEqualToString:savedPassword];
    
    if (!isEqual) {
        _isError = YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(fq_gestureLockView:type:didCompleteVerifyGesture:result:)]) {
        [self.delegate fq_gestureLockView:self type:_config.lockType didCompleteVerifyGesture:gesture result:isEqual];
    }
    
    [self performSelector:@selector(resetGesture) withObject:nil afterDelay:0.5];
}

- (void)handleResetGesture:(NSString *)gesture {
    // 重置密码逻辑分为两个阶段：
    // 1. 验证旧密码
    // 2. 设置新密码（与设置密码逻辑相同）
    
    if (!_isVerifiedOldPassword) {
        // 第一阶段：验证旧密码
        NSString *savedGesture = [self getSavedGesturePassword];
        BOOL isEqual = [gesture isEqualToString:savedGesture];
        
        // 设置错误状态
        _isError = !isEqual;
        
        if (isEqual) {
            // 旧密码验证成功，进入设置新密码阶段
            _isVerifiedOldPassword = YES;
            _firstGesture = nil; // 清空第一次设置的手势
            
            if ([self.delegate respondsToSelector:@selector(fq_gestureLockView:type:didCompleteVerifyGesture:result:)]) {
                [self.delegate fq_gestureLockView:self type:_config.lockType didCompleteVerifyGesture:gesture result:YES];
            }
        } else {
            // 旧密码验证失败
            if ([self.delegate respondsToSelector:@selector(fq_gestureLockView:type:didCompleteVerifyGesture:result:)]) {
                [self.delegate fq_gestureLockView:self type:_config.lockType didCompleteVerifyGesture:gesture result:NO];
            }
        }
    } else {
        // 第二阶段：设置新密码（与设置密码逻辑相同）
        if (!_firstGesture) {
            // 第一次设置新密码
            _firstGesture = gesture;
            
            if ([self.delegate respondsToSelector:@selector(fq_gestureLockView:type:didCompleteSetFirstGesture:)]) {
                [self.delegate fq_gestureLockView:self type:_config.lockType didCompleteSetFirstGesture:gesture];
            }
        } else {
            // 第二次设置新密码，需要与第一次匹配
            BOOL isEqual = [gesture isEqualToString:_firstGesture];
            
            if (isEqual) {
                // 两次密码一致，保存新密码
                [self saveGesturePassword:gesture];
            }
            
            if ([self.delegate respondsToSelector:@selector(fq_gestureLockView:type:didCompleteSetSecondGesture:result:)]) {
                [self.delegate fq_gestureLockView:self type:_config.lockType didCompleteSetSecondGesture:gesture result:isEqual];
            }
        }
    }
   
    [self performSelector:@selector(resetGesture) withObject:nil afterDelay:0.5];
}

#pragma mark - 密码存储

- (NSString *)getGesturePassword {
    NSMutableString *password = [NSMutableString string];
    for (NSNumber *index in _selectedDots) {
        [password appendString:[index stringValue]];
    }
    return password;
}

- (void)saveGesturePassword:(NSString *)password {
    [_userDefaults setObject:password forKey:_config.passwordKey];
    [_userDefaults synchronize];
}

- (NSString *)getSavedGesturePassword {
    return [_userDefaults objectForKey:_config.passwordKey];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    if (flag) {
        CALayer *layer = [animation valueForKey:@"animationLayer"];
        if (layer) {
            [layer removeFromSuperlayer];
            [self.animationLayers removeObject:layer];
        }
    }
}

#pragma mark - 绘制方法

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 绘制半透明背景，增强现代感
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.03].CGColor);
    UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:12];
    CGContextAddPath(context, backgroundPath.CGPath);
    CGContextFillPath(context);
    
    // 添加微妙的边框
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.08].CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGContextAddPath(context, backgroundPath.CGPath);
    CGContextStrokePath(context);
    
    // 绘制连接线
    [self drawLinesInContext:context];
    
    // 绘制点
    [self drawDotsInContext:context];
}

- (void)drawDotsInContext:(CGContextRef)context {
    for (NSValue *value in _allDots) {
        FQLockDot dot;
        [value getValue:&dot];
        
        // 外圆 - 使用变量控制大小，参考HTML的13px直径
        CGFloat outerRadius = 6.5; // 直径13px，半径为6.5px
        CGRect outerRect = CGRectMake(dot.point.x - outerRadius, dot.point.y - outerRadius, outerRadius * 2, outerRadius * 2);
        UIBezierPath *outerCircle = [UIBezierPath bezierPathWithOvalInRect:outerRect];
        
        if (dot.selected) {
            UIColor *dotColor = _isError ? _config.errorColor : _config.themeColor;
            
            // 1. 绘制外圈环 - 参考HTML的.dot::before和.dot.selected::before
            // 外圈比正常点大很多，参考HTML的top:-10px;left:-10px;right:-10px;bottom:-10px
            // 选中后整体放大1.3倍，参考HTML的transform: scale(1.3)
            CGFloat scaleFactor = 1.3; // 选中后的放大倍数
            CGFloat outerRadiusEnlarged = outerRadius * scaleFactor; // 选中后内圆放大
            CGFloat outerBorderRadius = outerRadius + 10.0; // 外圈边框比内圆大10px
            outerBorderRadius *= scaleFactor; // 外圈边框也要同步放大
            
            // 创建外圈边框路径
            CGRect outerBorderRect = CGRectMake(dot.point.x - outerBorderRadius, dot.point.y - outerBorderRadius, 
                                             outerBorderRadius * 2, outerBorderRadius * 2);
            UIBezierPath *outerBorderPath = [UIBezierPath bezierPathWithOvalInRect:outerBorderRect];
            
            // 设置外圈边框颜色和宽度
            CGContextSetStrokeColorWithColor(context, [dotColor colorWithAlphaComponent:0.5].CGColor); // 半透明边框
            CGContextSetLineWidth(context, 1.0); // 边框宽度
            CGContextAddPath(context, outerBorderPath.CGPath);
            CGContextStrokePath(context);
            
            // 2. 绘制内圆 - 蓝色实心圆，参考HTML的.dot.selected
            // 选中后整体放大1.3倍，参考HTML的transform: scale(1.3)
            CGFloat innerRadius = outerRadius * scaleFactor; // 选中后内圆就是放大后的外圆大小
            CGRect innerRect = CGRectMake(dot.point.x - innerRadius, dot.point.y - innerRadius, innerRadius * 2, innerRadius * 2);
            UIBezierPath *innerCircle = [UIBezierPath bezierPathWithOvalInRect:innerRect];
            
            // 设置内圆填充颜色
            CGContextSetFillColorWithColor(context, dotColor.CGColor); // 实心蓝色
            
            // 添加阴影效果，参考HTML的box-shadow
            CGContextSetShadowWithColor(context, CGSizeZero, 10.0, [dotColor colorWithAlphaComponent:0.7].CGColor);
            CGContextAddPath(context, innerCircle.CGPath);
            CGContextFillPath(context);
            
            // 重置阴影设置
            CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
            
            // 计算选中后经过的时间
            CFTimeInterval currentTime = CACurrentMediaTime();
            CFTimeInterval timeSinceSelection = currentTime - dot.selectTime;
            
            // 如果选中时间很短，重绘视图以显示动画
            if (timeSinceSelection < 0.3) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.016 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self setNeedsDisplay];
                });
            }
        } else {
            // 未选中状态 - 参考HTML的.dot和.dot::before
            // 1. 绘制外圈 - 对应HTML的.dot::before
            CGFloat outerBorderRadius = outerRadius + 10.0; // 外圈边框比内圆大10px
            CGRect outerBorderRect = CGRectMake(dot.point.x - outerBorderRadius, dot.point.y - outerBorderRadius, 
                                             outerBorderRadius * 2, outerBorderRadius * 2);
            UIBezierPath *outerBorderPath = [UIBezierPath bezierPathWithOvalInRect:outerBorderRect];
            
            // 设置外圈边框颜色和宽度 - 对应HTML的border: 1px solid rgba(255, 255, 255, 0.05)
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.05].CGColor);
            CGContextSetLineWidth(context, 1.0);
            CGContextAddPath(context, outerBorderPath.CGPath);
            CGContextStrokePath(context);
            
            // 2. 绘制内圆 - 对应HTML的.dot
            // 使用半透明白色填充 - 对应HTML的background-color: rgba(255, 255, 255, 0.3)
            CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.3].CGColor);
            CGContextAddPath(context, outerCircle.CGPath);
            CGContextFillPath(context);
        }
    }
}

- (void)drawLinesInContext:(CGContextRef)context {
    if (_selectedDots.count <= 1) {
        return;
    }
    
    // 使用配置中的线宽
    CGContextSetLineWidth(context, _config.lineWidth);
    UIColor *lineColor = _isError ? _config.errorColor : _config.themeColor;
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    // 添加发光效果
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 3.0, [lineColor colorWithAlphaComponent:0.6].CGColor);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 绘制已选中点之间的连线
    for (int i = 0; i < _selectedDots.count; i++) {
        NSInteger index = [_selectedDots[i] integerValue];
        FQLockDot dot;
        [[_allDots objectAtIndex:index] getValue:&dot];
        
        if (i == 0) {
            [path moveToPoint:dot.point];
        } else {
            [path addLineToPoint:dot.point];
        }
    }
    
    // 如果有当前点且不等于零点，则绘制到当前点的线
    if (!CGPointEqualToPoint(_currentPoint, CGPointZero) && _selectedDots.count > 0) {
        NSInteger lastIndex = [_selectedDots.lastObject integerValue];
        FQLockDot lastDot;
        [[_allDots objectAtIndex:lastIndex] getValue:&lastDot];
        
        // 确保连线不会断开
        if (!_isFinished) {
            [path addLineToPoint:_currentPoint];
        }
    }
    
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
    
    // 重置阴影
    CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
}

- (CGPoint)getPointForDotIndex:(NSInteger)index {
    for (NSValue *value in _allDots) {
        FQLockDot dot;
        [value getValue:&dot];
        if (dot.index == index) {
            return dot.point;
        }
    }
    return CGPointZero;
}

#pragma mark - 手势完成处理

- (void)handleGestureComplete {
    // 如果选中的点少于最小要求数量
    if (_selectedDots.count < _config.lockLeastCount) {
        if ([self.delegate respondsToSelector:@selector(fq_gestureLockView:type:connectNumberLessThanNeedWithGesture:)]) {
            [self.delegate fq_gestureLockView:self type:_config.lockType connectNumberLessThanNeedWithGesture:[self getGesturePassword]];
        }
        _isError = YES;
      
        [self performSelector:@selector(resetGesture) withObject:nil afterDelay:0.5];
        return;
    }
    
    // 获取手势密码
    NSString *gesture = [self getGesturePassword];
    
    // 根据不同的锁类型处理
    switch (_config.lockType) {
        case FQLockTypeSetting:
            [self handleSettingGesture:gesture];
            break;
            
        case FQLockTypeClose:
            [self handleVerifyGesture:gesture];
            break;
            
        case FQLockTypeLogin:
            [self handleVerifyGesture:gesture];
            break;
            
        case FQLockTypeReset:
            [self handleResetGesture:gesture];
            break;
            
        default:
            break;
    }
}

@end
