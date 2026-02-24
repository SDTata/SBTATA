//
//  FirstInvestAlert.m
//  phonelive2
//
//  Created by test on 2021/6/11.
//  Copyright © 2021 toby. All rights reserved.
//

#import "FirstInvestAlert.h"
#import "PayViewController.h"
#import "UIImageView+WebCache.h"
#import <UMCommon/UMCommon.h>

@interface FirstInvestAlertBottomCell:UICollectionViewCell
@property (strong, nonatomic) UIImageView *iv_background;
@property (strong, nonatomic) UIImageView *iv_logo;
@property (strong, nonatomic) UILabel *lb_title;
@property (strong, nonatomic) UILabel *lb_count;
@end

@implementation FirstInvestAlertBottomCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initialUI];
    }
    return self;
}
- (void)initialUI{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.iv_background = [[UIImageView alloc] initWithFrame:self.bounds];
    self.iv_background.contentMode = UIViewContentModeScaleToFill;
    self.iv_background.image = [ImageBundle imagewithBundleName:@"fi_bottombg"];
    [self.contentView addSubview:self.iv_background];
    self.lb_title = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.width, 30)];
    self.lb_title.font = [UIFont systemFontOfSize:14];
    self.lb_title.adjustsFontSizeToFitWidth = YES;
    self.lb_title.minimumScaleFactor = 0.3;
    self.lb_title.numberOfLines = 2;
    self.lb_title.textColor = [UIColor orangeColor];
    self.lb_title.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.lb_title];
    self.iv_logo = [[UIImageView alloc] initWithFrame:CGRectMake(15, 40, self.width - 30, self.width - 30)];
    self.iv_logo.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_logo.image = NULL;
    [self.contentView addSubview:self.iv_logo];
    self.lb_count = [[UILabel alloc]initWithFrame:CGRectMake(0, self.height - 35, self.width, 35)];
    self.lb_count.font = [UIFont boldSystemFontOfSize:14];
    self.lb_count.textColor = [UIColor whiteColor];
    self.lb_count.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.lb_count];
    
}
@end
@interface FirstInvestAlertTopCell:UICollectionViewCell
@property (strong, nonatomic) UIImageView *iv_background;
@property (strong, nonatomic) UIImageView *iv_hot;
@property (strong, nonatomic) UILabel *lb_title;
@property (strong, nonatomic) NSNumber *state;
@end

@implementation FirstInvestAlertTopCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initialUI];
    }
    return self;
}
- (void)initialUI{
    self.clipsToBounds = NO;
    [self.contentView setClipsToBounds:NO];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.iv_background = [[UIImageView alloc] initWithFrame:self.bounds];
    self.iv_background.contentMode = UIViewContentModeScaleToFill;
    UIImage *imggs =  [ImageBundle imagewithBundleName:@"bg_button_charge"];
    imggs = [imggs resizableImageWithCapInsets:UIEdgeInsetsMake(15, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
    self.iv_background.image = imggs;
    
    [self.contentView addSubview:self.iv_background];
    self.iv_hot = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 8, -8, 16, 16)];
    self.iv_hot.contentMode = UIViewContentModeScaleAspectFit;
    self.iv_hot.image = NULL;
    self.iv_hot.layer.zPosition = 20;
    [self.contentView addSubview:self.iv_hot];
    self.lb_title = [[UILabel alloc]initWithFrame:self.bounds];
    self.lb_title.font = [UIFont systemFontOfSize:14];
    self.lb_title.adjustsFontSizeToFitWidth = YES;
    self.lb_title.minimumScaleFactor = 0.3;
    self.lb_title.textColor = [UIColor orangeColor];
    self.lb_title.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.lb_title];
    
}
- (void)selectUI{
    self.iv_background.image = [self resizeImage:@"bg_button_charge" type:0];
    self.lb_title.textColor = [UIColor whiteColor];
}
- (void)normalUI{
    self.lb_title.textColor = [UIColor orangeColor];
    self.iv_background.image = NULL;
}
- (void)setState:(NSNumber *)state{
    _state = state;
    if ([state boolValue]) {
        [self selectUI];
    }else{
        [self normalUI];
    }
}

- (UIImage*)resizeImage:(NSString*)name type:(int)type {
    UIImage *resizeImage = [ImageBundle imagewithBundleName:name];
    resizeImage = [resizeImage initWithCGImage:resizeImage.CGImage scale:2.0 orientation:UIImageOrientationUp];
    CGFloat top = resizeImage.size.height/2.0;
    CGFloat bottom = resizeImage.size.height/2.0;
    CGFloat left = resizeImage.size.width/2.0;
    CGFloat right = resizeImage.size.width/2.0;

    UIEdgeInsets insets;
    if (type == 1) {
        insets = UIEdgeInsetsMake(resizeImage.size.height/4.0, 0, 0, 0);
    } else {
        insets = UIEdgeInsetsMake(top, left, bottom, right);
    }
    resizeImage = [resizeImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    return resizeImage;
}

@end

@interface FirstInvestAlert()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *col_top;
@property (weak, nonatomic) IBOutlet UILabel *lb_content;
@property (weak, nonatomic) IBOutlet UICollectionView *col_bottom;
@property (weak, nonatomic) IBOutlet UILabel *lb_bottomTip;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_alertCenterY;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout_bottom;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout_top;
@property (weak, nonatomic) IBOutlet UIButton *goToChargebutton;
@property (weak, nonatomic) IBOutlet UIImageView *chargeIverstBgImgView;

@property(nonatomic,strong)NSArray *datas;
@property(nonatomic,assign)NSInteger currentIndex;

@end

@implementation FirstInvestAlert
- (void)awakeFromNib{
    [super awakeFromNib];
    CGFloat alert_width = _window_width - 60;
    CGFloat father_height = (alert_width - 30) * 3.0 / 4.0;//135
    CGFloat col_height_bottom = father_height - 30 - 21 - 20 - 35;//29
    CGFloat col_bottom_width = _window_width - 120;//255
    CGFloat margin = 15;
    self.flowLayout_bottom.itemSize = CGSizeMake((col_bottom_width - 4 * margin)/3.0, col_height_bottom);
    //alert.flowLayout_bottom.itemSize = CGSizeMake((col_bottom_width - (countNum+1) * margin)/(countNum), alert.col_bottom.height);
    self.flowLayout_top.itemSize = CGSizeMake(col_bottom_width/[common getLivePopChargeInfo].count, 35);
    [self.goToChargebutton setImage:[ImageBundle imagewithBundleName:YZMsg(@"FirstInvestAlert_GoCharge_BT")] forState:UIControlStateNormal];
    self.chargeIverstBgImgView.image = [ImageBundle imagewithBundleName:YZMsg(@"FirstInvestAlert_ChargeBgImgV")];
    self.lb_bottomTip.numberOfLines = 2;
    
}
+ (instancetype)instanceNotificationAlertWithMessages{
    FirstInvestAlert *alert = [[[XBundle currentXibBundleWithResourceName:@"FirstInvestAlert"] loadNibNamed:@"FirstInvestAlert" owner:nil options:nil] firstObject];
    alert.col_top.delegate = alert;
    alert.col_top.clipsToBounds = NO;
    alert.col_top.dataSource = alert;
    [alert.col_top registerClass:[FirstInvestAlertTopCell class] forCellWithReuseIdentifier:@"FirstInvestAlertTopCell"];
    alert.col_bottom.delegate = alert;
    alert.col_bottom.dataSource = alert;
    alert.datas = [common getLivePopChargeInfo];
    if (alert.datas.count>0) {
        NSInteger countNum = 0;
        NSDictionary *subDic = alert.datas [0];
        if ([subDic isKindOfClass:[NSDictionary class]]) {
            NSArray *item = subDic[@"item"];
            if (item) {
                countNum = item.count;
            }
            [alert collectionLayoutAdaptBottomToData:item];
        }
        
    }
//
    [alert.col_bottom registerClass:[FirstInvestAlertBottomCell class] forCellWithReuseIdentifier:@"FirstInvestAlertBottomCell"];
    
    return alert;
}
- (void)alertShowAnimationWithSuperView:(UIView *)superView{
    //UIViewController *vc = [FirstInvestAlert currentViewController];
    //UIView *superView = vc.view;
    self.frame = CGRectMake(0, 0, _window_width, _window_height);
    self.layout_alertCenterY.constant = _window_height;
    [superView addSubview:self];
    self.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.25 animations:^{
        self.layout_alertCenterY.constant = 0;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [self layoutIfNeeded];
    }];
    [self.col_bottom reloadData];
    [self.col_top reloadData];
    [self updatetext];

    
}

-(BOOL)isAttrubuteTex:(NSString*)content
{
    if ([content rangeOfString:@"</p>"].location!=NSNotFound||[content rangeOfString:@"<span"].location!=NSNotFound||[content rangeOfString:@"<br"].location!=NSNotFound) {
        return YES;
    }
    return NO;
}

-(void)updatetext{
    if (self.datas.count>0) {
        NSDictionary *subDic = self.datas[self.currentIndex];
        NSString *contentTip = subDic[@"tip_mid"];
        NSString *contentBottomTip = subDic[@"tip_end"];
        if ([PublicObj checkNull:contentTip]||[PublicObj checkNull:contentBottomTip]) {
            return;
        }
        if ([self isAttrubuteTex:contentTip]) {
            NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithData:[contentTip dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            self.lb_content.attributedText = attrStr1;
        }else{
            self.lb_content.text = contentTip;
        }
        if ([self isAttrubuteTex:contentBottomTip]) {
            NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithData:[contentBottomTip dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            self.lb_bottomTip.attributedText = attrStr2;
        }else{
            self.lb_bottomTip.text = contentBottomTip;
        }
    }
    
}

- (IBAction)goInvest:(UIButton *)sender {
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    [[MXBADelegate sharedAppDelegate].navigationViewController pushViewController:payView animated:1];
    [MobClick event:@"live_room_charge_gift_click" attributes:@{@"eventType": @(1)}];
}
- (IBAction)dismissAlert:(UIButton *)sender {
    [self dismissView];
}
-(void)dismissView
{
    //dismiss alert
    [UIView animateWithDuration:0.25 animations:^{
        self.layout_alertCenterY.constant = _window_height;
        self.backgroundColor = [UIColor clearColor];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
+ (UIViewController *)currentViewController
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;;
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)vc;
        if ([tab.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
            return [nav.viewControllers lastObject];
        } else {
            return tab.selectedViewController;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.viewControllers lastObject];
    } else {
        return vc;
    }
    return nil;
}
#pragma mark - UICollectionView -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == self.col_top) {
        return self.datas.count;
    }else{
        NSDictionary *subDic = self.datas[self.currentIndex];
        if ([subDic isKindOfClass:[NSDictionary class]]) {
            NSArray *item = subDic[@"item"];
            if (item) {
                return item.count;
            }
        }
        return 0;
    }
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    if (collectionView == self.col_top) {
        FirstInvestAlertTopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FirstInvestAlertTopCell" forIndexPath:indexPath];
        NSDictionary *subDic = self.datas[indexPath.row];
        cell.clipsToBounds = NO;
        if ([PublicObj checkNull:subDic[@"title"]]) {
            return cell;
        }
        cell.lb_title.text = subDic[@"title"];
        if (self.currentIndex == indexPath.row) {
            cell.state = @1;
        }else{
            cell.state = @0;
        }
        NSString *hotimg = subDic[@"label"];
        if (![PublicObj checkNull:hotimg]) {
            [cell.iv_hot sd_setImageWithURL:[NSURL URLWithString:hotimg]];
        }
        
        return cell;
    }else{
        FirstInvestAlertBottomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FirstInvestAlertBottomCell" forIndexPath:indexPath];
        NSDictionary *subDic = self.datas[self.currentIndex];
        if ([subDic isKindOfClass:[NSDictionary class]]) {
            NSArray *item = subDic[@"item"];
            if (item) {
                NSDictionary *subDic = item[indexPath.row];
                NSString *numberStr = subDic[@"item_num"];
                NSString *item_name = subDic[@"item_name"];
                NSString *item_icon = subDic[@"item_icon"];
                if ([PublicObj checkNull:item_name]) {
                    return cell;
                }
                cell.lb_count.text = numberStr;
                cell.lb_title.text = item_name;
                if (![PublicObj checkNull:item_icon]) {
                    [cell.iv_logo sd_setImageWithURL:[NSURL URLWithString:item_icon]];
                }
            }
        }
        return cell;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.col_top) {
        self.currentIndex = indexPath.row;
        NSDictionary *subDic = self.datas[self.currentIndex];
        if ([subDic isKindOfClass:[NSDictionary class]]) {
            NSArray *item = subDic[@"item"];
            [self collectionLayoutAdaptBottomToData:item];
        }
        [collectionView reloadData];
        [self.col_bottom reloadData];
        [self updatetext];
    }else{
        
    }
}
- (void)collectionLayoutAdaptBottomToData:(NSArray *)item{
    if (item.count < 3) {
        if (item.count == 1) {
            CGFloat alert_width = _window_width - 60;
            CGFloat father_height = (alert_width - 30) * 3.0 / 4.0;//135
            CGFloat col_height_bottom = father_height - 30 - 21 - 20 - 35;//29
            CGFloat col_bottom_width = _window_width - 120;//255
            CGFloat margin = 15;
            CGFloat itemWidth = (col_bottom_width - 4 * margin)/3.0;
            self.flowLayout_bottom.itemSize = CGSizeMake(itemWidth, col_height_bottom);
            CGFloat sectionMargin = (col_bottom_width - itemWidth) / 2.0;
            self.flowLayout_bottom.sectionInset = UIEdgeInsetsMake(14, sectionMargin, 14, sectionMargin);
        }else{
            CGFloat alert_width = _window_width - 60;
            CGFloat father_height = (alert_width - 30) * 3.0 / 4.0;//135
            CGFloat col_height_bottom = father_height - 30 - 21 - 20 - 35;//29
            CGFloat col_bottom_width = _window_width - 120;//255
            CGFloat margin = 15;
            CGFloat itemWidth = (col_bottom_width - 4 * margin)/3.0;
            self.flowLayout_bottom.itemSize = CGSizeMake(itemWidth, col_height_bottom);
            CGFloat sectionMargin = (col_bottom_width - (2 * itemWidth + margin)) / 2.0;
            self.flowLayout_bottom.sectionInset = UIEdgeInsetsMake(14, sectionMargin, 14, sectionMargin);
        }
    }else{
        //大于等于3
        CGFloat alert_width = _window_width - 60;
        CGFloat father_height = (alert_width - 30) * 3.0 / 4.0;//135
        CGFloat col_height_bottom = father_height - 30 - 21 - 20 - 35;//29
        CGFloat col_bottom_width = _window_width - 120;//255
        CGFloat margin = 15;
        self.flowLayout_bottom.itemSize = CGSizeMake((col_bottom_width - 4 * margin)/3.0, col_height_bottom);
    }
}
@end
