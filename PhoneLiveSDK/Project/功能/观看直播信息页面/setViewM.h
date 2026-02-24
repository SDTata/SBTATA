#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "GrounderSuperView.h"
#import "hotModel.h"

@protocol frontviewDelegate <NSObject>
-(void)zhezhaoBTNdelegate;
-(void)gongxianbang;//跳贡献榜
-(void)zhubomessage;//点击主播弹窗
-(void)guanzhuZhuBo;//关注zhubo
-(void)showGuardView;//关注zhubo
-(void)showTopTodayView;//今日榜单
@end
@interface setViewM : UIView
{
    UILabel *labell;
    CGFloat guardWidth;
}

@property(nonatomic,assign)CGSize yingpiaoSize;
@property(nonatomic,assign)id<frontviewDelegate>frontviewDelegate;
@property(nonatomic,strong)UIButton *newattention;
@property(nonatomic,strong)UIButton *ZheZhaoBTN;    //遮罩层
@property(nonatomic,strong)UIImageView *bigAvatarImageView;//背景图片
@property(nonatomic,strong)UIView *leftView;        //左上角信息
@property(nonatomic,strong)UIButton *IconBTN;       //左上角主播头像
@property(nonatomic,strong)UILabel *idLabel;        //主播ID

@property(nonatomic,strong)UILabel *yingpiaoLabel;  //花浪
@property(nonatomic,strong)UIImageView *levelimage; //主播等级

@property(nonatomic,strong)UIButton *guardBtn;      //守护b按钮
@property(nonatomic,strong)UIButton *topTodayButton; //实时榜单
@property(nonatomic,strong)UIButton *speedButton;      //网速

-(instancetype)initWithModel:(hotModel *)playModel;
@property(nonatomic,strong)hotModel *zhuboModel;
-(void)changeState:(NSString *)texts;
-(void)changeGuardButtonFrame:(NSString *)nums;//改变守护按钮适应坐标
- (void)updateSpeedValue:(NSInteger)speed;

-(void)hiddenTopViewForChat:(BOOL)isHiden;
- (CGRect)getLeftViewFrame;
@end
