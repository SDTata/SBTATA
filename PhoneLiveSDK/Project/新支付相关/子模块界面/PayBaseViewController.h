// PayBaseViewController.h

@interface PayBaseViewController : UIViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeight;

-(NSArray *)getRequireKeys;
-(NSDictionary *)getRequestParams;
@end
