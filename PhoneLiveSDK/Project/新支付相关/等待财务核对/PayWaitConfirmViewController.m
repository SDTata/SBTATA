//
//  PayWaitConfirmViewController.m
//
//

#import "PayWaitConfirmViewController.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface PayWaitConfirmViewController (){
    
    BOOL bUICreated; // UI是否创建
}
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;


@end

@implementation PayWaitConfirmViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    [self refreshUI];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.navigationItem.title = @"投注中心";
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    self.warningLabel.text = YZMsg(@"pay_wait_page_des");
    [self.homeBtn setTitle:YZMsg(@"pay_wait_page_back") forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated{
}

-(void)refreshUI{
    if(!bUICreated){
        [self initUI];
    }
}

-(void)initUI{
    bUICreated = true;
    
    [self.backBtn addTarget:self action:@selector(doBackVC) forControlEvents:UIControlEventTouchUpInside];
    [self.homeBtn addTarget:self action:@selector(doReturnHome) forControlEvents:UIControlEventTouchUpInside];
}

- (void)doBackVC {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doReturnHome {
    //遍历控制器
//    for (UIViewController *controller in self.navigationController.viewControllers) {
//        if ([controller isKindOfClass:ZYTabBarController.class]) {
//            [self.navigationController popToViewController:controller animated:YES];
//        }
//    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (UIImage *)createImageWithColor:(UIColor *)color rect:(CGRect)rect radius:(float)radius {
    //设置长宽
//    CGRect rect = rect;//CGRectMake(0.0f, 0.0f, 80.0f, 30.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *original = resultImage;
    CGRect frame = CGRectMake(0, 0, original.size.width, original.size.height);
    // 开始一个Image的上下文
    UIGraphicsBeginImageContextWithOptions(original.size, NO, 1.0);
    // 添加圆角
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:radius] addClip];
    // 绘制图片
    [original drawInRect:frame];
    // 接受绘制成功的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
