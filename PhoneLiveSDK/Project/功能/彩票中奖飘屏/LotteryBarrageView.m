//
//  LotteryBarrageView.m
//  phonelive
//
//  Created by 400 on 2020/7/31.
//  Copyright © 2020 toby. All rights reserved.
//

#import "LotteryBarrageView.h"
@interface LotteryBarrageView()

@property (weak, nonatomic) IBOutlet UIImageView *winTypeImgView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleWithClickLabel;

@property(nonatomic,strong)LotteryBarrageModel *model;

@property(nonatomic,copy)Callback callback;

@property(nonatomic,weak)id<LotteryBarrageDelegate> delegate;

@end

@implementation LotteryBarrageView

+(LotteryBarrageView*)showInView:(UIView *)superView Model:(LotteryBarrageModel*)model complete:(Callback)callbacks delegate:(id)delegate
{
    CGFloat hhh = 240+statusbarHeight;
    UIView *superViewSub = [[UIView alloc]initWithFrame:CGRectMake(0, hhh, SCREEN_WIDTH, 80)];
    superViewSub.tag = 104;
    superViewSub.backgroundColor = [UIColor clearColor];
    [superView addSubview:superViewSub];
    
    LotteryBarrageView *view = [[[XBundle currentXibBundleWithResourceName:@"LotteryBarrageView"] loadNibNamed:@"LotteryBarrageView" owner:nil options:nil] firstObject];
    view.delegate = delegate;
    view.callback = callbacks;
    view.backgroundColor = [UIColor clearColor];
    [superViewSub addSubview:view];
    
    view.top = 0;
    view.left = SCREEN_WIDTH;
    view.width = SCREEN_WIDTH;
    UITapGestureRecognizer  *gets = [[UITapGestureRecognizer alloc]initWithTarget:view action:@selector(animationShipClick:)];
    superViewSub.userInteractionEnabled = YES;
    [superViewSub addGestureRecognizer:gets];
    
    view.model = model;
    return view;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.titleWithClickLabel.text = YZMsg(@"LotteryBarrageView_clickTitle");
}

-(void)animationShipClick:(UITapGestureRecognizer *)gesture{
    //获取动画的UIImageView
    UIView * moveShipImageView = self;
    //获取动画UIImageView在view上的位置
    CGPoint touchPoint = [gesture locationInView:self.superview];
    if ([moveShipImageView.layer.presentationLayer hitTest:touchPoint]) {
        if (self.delegate) {
            [self.delegate lotteryBarrageClick:self.model];
        }
        
    }
    
}
-(void)layoutSubviews
{
    [super layoutSubviews];
}
-(void)setModel:(LotteryBarrageModel *)model
{
    if (self == nil) {
        return;
    }
    _model = model;
    UIView *sup = self.superview;
 
    self.winTypeImgView.image = [ImageBundle imagewithBundleName:model.showImgName];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[model.content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    self.contentLabel.attributedText = attrStr;
    [self layoutIfNeeded];
    [self setNeedsLayout];
    self.height = self.bgView.bottom + self.bgView.top;
    if (sup) {
        sup.height = self.height;
    }
    self.bgView.layer.cornerRadius = self.bgView.height/2.0;
    self.bgView.layer.masksToBounds = YES;
    WeakSelf
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseOut animations:^{
        if (weakSelf!=nil) {
            weakSelf.left = SCREEN_WIDTH-self.bgView.width;
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:4 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveLinear animations:^{
            if (weakSelf!=nil) {
                weakSelf.left = -10;
            }
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseIn animations:^{
                if (weakSelf!=nil) {
                    weakSelf.left = - weakSelf.bgView.width-10;
                }
            } completion:^(BOOL finished) {
                if (weakSelf!=nil) {
                    [weakSelf removeFromSuperview];
                    if (sup) {
                        [sup removeFromSuperview];
                    }
                    weakSelf.callback();
                }
                
            }];
            
        }];
        
    }];
    
}

-(void)dealloc
{
    NSLog(@"dealloc");
}
@end
