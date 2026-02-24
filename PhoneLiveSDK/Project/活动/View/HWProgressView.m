#import "HWProgressView.h"

#define KProgressPadding 1.0f
@interface HWProgressView ()

@property (nonatomic, weak) UIView *tView;
@property (nonatomic, weak) UIView *borderView;

@end

@implementation HWProgressView

-(void)awakeFromNib
{
    [super awakeFromNib];
    UIView *borderView = [[UIView alloc] initWithFrame:self.bounds];
    borderView.layer.cornerRadius = self.bounds.size.height * 0.5;
    borderView.layer.masksToBounds = YES;
    borderView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
    
    self.borderView=borderView;
    [self addSubview:borderView];
    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self);
    }];
    //进度
    UIView *tView = [[UIView alloc] init];
    tView.backgroundColor = [UIColor redColor];
    tView.layer.cornerRadius = (self.bounds.size.height) * 0.5;
    tView.layer.masksToBounds = YES;
    [self addSubview:tView];
    self.tView = tView;
    [_tView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(borderView);
    }];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIView *borderView = [[UIView alloc] initWithFrame:self.bounds];
        borderView.layer.cornerRadius = self.bounds.size.height * 0.5;
        borderView.layer.masksToBounds = YES;
        borderView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
        
        self.borderView=borderView;
        [self addSubview:borderView];
        [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(self);
        }];
        //进度
        UIView *tView = [[UIView alloc] init];
        tView.backgroundColor = [UIColor redColor];
        tView.layer.cornerRadius = (self.bounds.size.height) * 0.5;
        tView.layer.masksToBounds = YES;
        [self addSubview:tView];
        self.tView = tView;
        [_tView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(borderView);
        }];
    }

    return self;
}

-(void)setProgerssColor:(UIColor *)progerssColor{
    _progerssColor=progerssColor;
    _tView.backgroundColor=progerssColor;
}

-(void)setProgerStokeWidth:(CGFloat)progerStokeWidth{
    _progerStokeWidth=progerStokeWidth;
    _borderView.layer.borderWidth = progerStokeWidth;

}
-(void)setProgerssStokeBackgroundColor:(UIColor *)progerssStokeBackgroundColor{
    _progerssStokeBackgroundColor=progerssStokeBackgroundColor;
     _borderView.layer.borderColor = [progerssStokeBackgroundColor CGColor];
}
-(void)setProgerssBackgroundColor:(UIColor *)progerssBackgroundColor{
    _progerssBackgroundColor = progerssBackgroundColor;
    _borderView.backgroundColor=progerssBackgroundColor;
}

//更新进度
- (void)setProgress:(CGFloat)progress
{
    if (progress>1.0) {
        progress = 1.0;
    }
    _progress = progress;
    [_borderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self);
    }];
    [_tView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(_borderView);
        make.width.equalTo(_borderView.mas_width).multipliedBy(progress*1.0);
    }];
}

@end
