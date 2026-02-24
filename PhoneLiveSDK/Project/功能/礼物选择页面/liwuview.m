#import "liwuview.h"
#import "Config.h"
#import "liwucell.h"
#define celll @"cell"
#import "MBProgressHUD.h"
#import "LWLCollectionViewHorizontalLayout.h"
#import "giftCell.h"
#import <UMCommon/UMCommon.h>

@interface CollectionCellWhite : UICollectionViewCell
@end

@implementation CollectionCellWhite

- (instancetype)initWithFrame:(CGRect)frame andPlayDic:(NSDictionary *)zhuboDic{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end

@interface liwuview ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSTimer *timer;
    int a;
    NSMutableArray *selectedArray;
    CGFloat moveCount;
    BOOL isRight;
    NSInteger _pageCount;
    UIImageView *btnBgImgView;
    UIButton *giftCountBtn;
    NSArray *countArray;
    UIButton *haohuaBtn;
    
}
@property(nonatomic,strong)CABasicAnimation *animation;

@end
@implementation liwuview
-(NSArray *)models{
    NSMutableArray *muatb = [NSMutableArray array];
    for (int i=0;i<self.allArray.count;i++) {
        liwuModel *model = [liwuModel modelWithDic:self.allArray[i]];
        [muatb addObject:model];
    }
    _models = muatb;
    return _models;
}
-(void)reloadColl{
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.getGiftList" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            strongSelf.allArray = [[info firstObject]valueForKey:@"giftlist"];
            for (int i=0; i<strongSelf.allArray.count; i++) {
                [strongSelf->selectedArray addObject:@"0"];
            }
            strongSelf->_pageCount = strongSelf.allArray.count;
            while (strongSelf->_pageCount % 8 != 0) {
                ++strongSelf->_pageCount;
                NSLog(@"%zd", strongSelf->_pageCount);
            }
            for (int i=0; i<strongSelf.allArray.count; i++) {
                [strongSelf->selectedArray addObject:@"0"];
            }
            [strongSelf.collectionView reloadData];
            NSString *coin = [[info firstObject] valueForKey:@"coin"];
            coin = [coin stringByReplacingOccurrencesOfString:@"," withString:@""];
            double coinDo = [coin doubleValue]*10;
            LiveUser *liveUser = [Config myProfile];
            liveUser.coin  =  [NSString stringWithFormat:@"%.2f",coinDo];
            [Config updateProfile:liveUser];
            
            [strongSelf chongzhiV:coin];
            if (strongSelf.allArray.count > 0) {
                if ((int)strongSelf.allArray.count % 8 == 0) {
                    strongSelf.pageControl.numberOfPages = strongSelf.allArray.count/8;
                }else{
                    strongSelf.pageControl.numberOfPages = strongSelf.allArray.count/8 + 1;
                }
            }

        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
}
-(void)jumpRechargess{
    [self.giftDelegate pushCoinV];
}
- (void)closeBtnClick{
    [self.giftDelegate zhezhaoBTNdelegate];
}
- (void)giftCountBtnClick:(UIButton *)sender{
    if (!_giftCountView) {
        _giftCountView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _giftCountView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideGiftCountView)];
        [_giftCountView addGestureRecognizer:tap];
        [self addSubview:_giftCountView];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width-140, _giftCountView.height-30*countArray.count-10-40-ShowDiff, 65, 30*countArray.count+10)];
        imgView.image = [ImageBundle imagewithBundleName:@"gift_nums"];
        imgView.userInteractionEnabled = YES;
        [_giftCountView addSubview:imgView];
        for (int i = 0; i < countArray.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:0];
            btn.frame = CGRectMake(0, i*30, 65, 30);
            [btn setTitle:countArray[i] forState:0];
            [btn setTitleColor:normalColors forState:0];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn addTarget:self action:@selector(selectGiftNum:) forControlEvents:UIControlEventTouchUpInside];
            [imgView addSubview:btn];
        }
    }else{
        _giftCountView.hidden = NO;
    }
    [giftCountBtn setImage:[ImageBundle imagewithBundleName:@"gift_top"] forState:0];

}
- (void)selectGiftNum:(UIButton *)sender{
    _giftCountView.hidden = YES;
    [giftCountBtn setTitle:sender.titleLabel.text forState:0];
    [giftCountBtn setImage:[ImageBundle imagewithBundleName:@"gift_down"] forState:0];
}
- (void)hideGiftCountView{
    _giftCountView.hidden = YES;
    [giftCountBtn setImage:[ImageBundle imagewithBundleName:@"gift_down"] forState:0];

}
-(instancetype)initWithModel:(hotModel *)playModel andMyDic:(NSMutableArray *)myDic{
    self = [super init];
    if (self) {
        moveCount = 0;
        selectedArray = [NSMutableArray array];
        self.models = [NSArray array];
        self.allArray = [NSArray array];
        self.playModel = playModel;
        countArray = @[@"1314",@"520",@"100",@"88",@"66",@"10",@"1"];
        self.backgroundColor = RGB_COLOR(@"#000000", 0.96);
//        UIButton *closeBtn = [UIButton buttonWithType:0];
//        closeBtn.frame = CGRectMake(0, 0, _window_width, 40);
//        [closeBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"gift_header"] forState:0];
//        [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
//        [closeBtn setTitle:@"发送礼物" forState:0];
////        [closeBtn setImage:[ImageBundle imagewithBundleName:@"profit_down"] forState:0];
////        closeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -67.5, 0, 24);
////        closeBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 67.5, 8, 10);
//        [closeBtn setBackgroundColor:RGB_COLOR(@"#000000", 0.96)];
//        closeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//        [self addSubview:closeBtn];
        UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _window_width, 40)];
        titleL.textColor = [UIColor whiteColor];
        titleL.font = [UIFont systemFontOfSize:15];
        titleL.text = [NSString stringWithFormat:@"    %@",YZMsg(@"Give the streamer a small gift")];
        [self addSubview:titleL];
//        [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 30, _window_width, 10) andColor:RGB_COLOR(@"#323232", 0.9) andView:self];
//        UIImageView *colBgImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 40, _window_width, _window_width/2)];
//        colBgImgView.image = [ImageBundle imagewithBundleName:@"gift_col_back"];
//        [self addSubview:colBgImgView];
        LWLCollectionViewHorizontalLayout *Flowlayout =[[LWLCollectionViewHorizontalLayout alloc]init];
        Flowlayout.itemCountPerRow = 4;
        Flowlayout.rowCount = 2;
        Flowlayout.minimumLineSpacing = 0;
        Flowlayout.minimumInteritemSpacing = 0;
        Flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,40,_window_width, _window_width/2) collectionViewLayout:Flowlayout];
//        Flowlayout.itemSize = CGSizeMake((_window_width-20)/4-1, (_window_width-20)/4-1);
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.pagingEnabled = YES;
        //注册cell
        self.collectionView.backgroundColor = [UIColor clearColor];
//        [self.collectionView registerClass:[liwucell class] forCellWithReuseIdentifier:celll];
        [self.collectionView registerNib:[UINib nibWithNibName:@"giftCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellWithReuseIdentifier:celll];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.multipleTouchEnabled = NO;
        [self.collectionView registerClass:[CollectionCellWhite class]
                forCellWithReuseIdentifier:@"CellWhite"];
        [self addSubview:self.collectionView];
        
        //page
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.frame = CGRectMake(0,_collectionView.bottom,_window_width,20);
        pageControl.center = CGPointMake(0,_collectionView.bottom+10);
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
//        pageControl.backgroundColor = RGB_COLOR(@"#323232", 0.9);
        pageControl.enabled = NO;
        _pageControl=pageControl;
        [self addSubview:pageControl];
        
        //底部条
        _buttomView = [[UIView alloc]initWithFrame:CGRectMake(0,pageControl.bottom, _window_width,40+ShowDiff)];
//        _buttomView.backgroundColor = RGB_COLOR(@"#323232", 0.9);
        [self addSubview:_buttomView];
        
        btnBgImgView = [[UIImageView alloc]init];
        btnBgImgView.frame = CGRectMake(_window_width-140, 2, 130, 36);
        btnBgImgView.userInteractionEnabled = YES;
        btnBgImgView.image = [ImageBundle imagewithBundleName:@"gift_send"];
        [_buttomView addSubview:btnBgImgView];
        
        haohuaBtn = [UIButton buttonWithType:0];
        [haohuaBtn setTitle:YZMsg(@"liwuview_SendButton") forState:UIControlStateNormal];
        [haohuaBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [haohuaBtn setTitleColor:RGB_COLOR(@"#949596", 1) forState:UIControlStateNormal];
        [haohuaBtn setBackgroundImage:[PublicObj getImgWithColor:normalColors] forState:UIControlStateSelected];
        [haohuaBtn setBackgroundImage:[PublicObj getImgWithColor:RGB_COLOR(@"#282518", 1)] forState:UIControlStateNormal];
        haohuaBtn.selected = NO;
        [haohuaBtn addTarget:self action:@selector(doLiWu:) forControlEvents:UIControlEventTouchUpInside];
        haohuaBtn.frame = CGRectMake(btnBgImgView.left+47,2,65+18,36);
        haohuaBtn.layer.cornerRadius = 18.0;
        haohuaBtn.layer.masksToBounds = YES;
        haohuaBtn.hidden = NO;
        haohuaBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        haohuaBtn.titleLabel.minimumScaleFactor = 0.5;
        [_buttomView addSubview:haohuaBtn];

        //选择数量按钮
        giftCountBtn = [UIButton buttonWithType:0];
        giftCountBtn.frame = CGRectMake(0, 0, 65, 36);
        [giftCountBtn setTitle:@"1" forState:0];
        [giftCountBtn setImage:[ImageBundle imagewithBundleName:@"gift_down"] forState:0];
        [giftCountBtn addTarget:self action:@selector(giftCountBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        giftCountBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [giftCountBtn setTitleColor:normalColors forState:0];
        giftCountBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -17, 0, 17);
        giftCountBtn.imageEdgeInsets = UIEdgeInsetsMake(13, 48, 13, 5);
        [btnBgImgView addSubview:giftCountBtn];
        btnBgImgView.hidden = YES;
        //发送按钮
        _push = [UIButton buttonWithType:UIButtonTypeSystem];
        [_push setTitle:YZMsg(@"liwuview_SendButton") forState:UIControlStateNormal];
        [_push setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_push addTarget:self action:@selector(doLiWu:) forControlEvents:UIControlEventTouchUpInside];
        _push.enabled = NO;
        _push.tag = 6789;
        _push.frame = CGRectMake(65,0,65,36);
        _push.titleLabel.adjustsFontSizeToFitWidth = YES;
        _push.titleLabel.minimumScaleFactor = 0.5;
        [btnBgImgView addSubview:_push];
        
        //充值lable
        _chongzhi = [[UILabel alloc] init];
        LiveUser *user = [Config myProfile];
        _chongzhi.textColor = normalColors;
        _chongzhi.font = [UIFont boldSystemFontOfSize:14];
        _chongzhi.frame = CGRectMake(10,10,_window_width-150-40,20);
        [_buttomView addSubview:_chongzhi];
        [_chongzhi mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_buttomView.mas_top).offset(10);
            make.left.equalTo(_buttomView.mas_left).offset(10);
            make.height.mas_equalTo(20);
        }];

        UILabel *chongzhiTitle = [[UILabel alloc] init];
        chongzhiTitle.text = [NSString stringWithFormat:@"%@ >", YZMsg(@"Bet_Charge_Title")];
        chongzhiTitle.textColor = RGB_COLOR(@"#9A5B57", 1);
        chongzhiTitle.font = [UIFont boldSystemFontOfSize:15];
        [_buttomView addSubview:chongzhiTitle];
        [chongzhiTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_chongzhi.mas_right).offset(5);
            make.centerY.equalTo(_chongzhi.mas_centerY);
            make.height.mas_equalTo(20);
        }];

        //充值上透明按钮
        _jumpRecharge = [[UIButton alloc] initWithFrame:CGRectMake(0,0,_window_width-150,40)];
        _jumpRecharge.titleLabel.text = @"";
        [_jumpRecharge setBackgroundColor:[UIColor clearColor]];
        [_jumpRecharge addTarget:self action:@selector(jumpRechargess) forControlEvents:UIControlEventTouchUpInside];
        [_buttomView addSubview:_jumpRecharge];
        [self addSubview:_buttomView];
        [_jumpRecharge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(_buttomView);
            make.right.equalTo(chongzhiTitle);
        }];

        CGFloat w = 80;
        _continuBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        _continuBTN.frame = CGRectMake(_window_width - 85,_buttomView.top-40,w,w);
        [_continuBTN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_continuBTN addTarget:self action:@selector(doLiWu:) forControlEvents:UIControlEventTouchDown];
        _continuBTN.tag = 5678;
        _continuBTN.titleLabel.numberOfLines = 2;
        [_continuBTN setBackgroundImage:[ImageBundle imagewithBundleName:@"gift_continus"] forState:UIControlStateNormal];
        _continuBTN.hidden = YES;
        [self addSubview:_continuBTN];
        NSString *coinst = [NSString stringWithFormat:@"%.2f", [user.coin floatValue] / 10];
        [self chongzhiV:coinst];
        [self.collectionView reloadData];
        [self reloadColl];

    }
    return self;
}
-(void)setBottomAdd{

    
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    //水平滑动时 判断是右滑还是左滑
    if(velocity.x>0){
        //右滑
        NSLog(@"右滑");
        isRight = YES;
    }else{
        //左滑
        NSLog(@"左滑");
        isRight = NO;
    }
    NSLog(@"scrollViewWillEndDragging");
    if (isRight) {
        self.pageControl.currentPage+=1;
    }
    else{
        self.pageControl.currentPage-=1;
    }
}
//发送礼物
-(void)doLiWu:(UIButton *)sender
{
    if(!_selectModel){
        return;
    }
    if (![_guradType isEqual:@"2"] && [_selectModel.mark isEqual:@"2"]) {
        [MBProgressHUD showError:YZMsg(@"liwuview_YearGift")];
        return;
    }
    
    
    NSString *lianfa = @"y";
    _push.enabled = NO;
//    _push.backgroundColor = [UIColor lightGrayColor];
    NSLog(@"发送了%@",_selectModel.giftname);
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"gift_name": _selectModel.giftname};
    [MobClick event:@"live_room_gift_name_click" attributes:dict];

    //判断连发
    if ([_selectModel.type isEqual:@"1"]) {
        lianfa = @"n";
        _continuBTN.hidden = YES;
        _push.enabled = YES;
//        _push.backgroundColor = normalColors;
    }
    else{
        btnBgImgView.hidden = YES;
        _continuBTN.hidden = NO;
        a = 5;
        if(timer == nil)
        {
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(jishiqi) userInfo:nil repeats:YES];
        }
        if(sender == _push)
        {
            [timer setFireDate:[NSDate date]];
        }
    }
    /*******发送礼物开始 **********/
    NSDictionary *giftDic = @{
        @"liveuid":self.playModel.zhuboID,
        @"stream":self.playModel.stream,
                              @"giftid":_selectModel.ID,
                              @"giftcount":minstr(giftCountBtn.titleLabel.text)
                              };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.sendGift"  withBaseDomian:YES andParameter:giftDic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            [MBProgressHUD showError:YZMsg(@"liwuview_sendSuccess")];
            [strongSelf.giftDelegate sendGift:strongSelf.mydic andPlayModel:strongSelf.playModel andData:info andLianFa:lianfa];
            NSArray *info2 = [info firstObject];
            NSString *coin = [info2 valueForKey:@"coin"];
            double coinDo = [coin doubleValue]*10;
            LiveUser *liveUser = [Config myProfile];
            liveUser.coin  =  [NSString stringWithFormat:@"%.2f",coinDo];
            [Config updateProfile:liveUser];
            [strongSelf chongzhiV:coin];
        }else{
            strongSelf.continuBTN.hidden = YES;
            strongSelf->btnBgImgView.hidden = NO;
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->btnBgImgView.hidden = NO;
        strongSelf.continuBTN.hidden = YES;
    }];
}
/*********************发送礼物结束 ************************/

//连发倒计时
-(void)jishiqi{
    a-=1;
    [_continuBTN setTitle:[NSString stringWithFormat:@"%@\n  %ds",YZMsg(@"liwuview_Bursts"),a] forState:UIControlStateNormal];
    if (a == 0) {
        [timer setFireDate:[NSDate distantFuture]];
//        _push.backgroundColor = normalColors;
        _push.enabled = YES;
        _continuBTN.hidden = YES;
        btnBgImgView.hidden = NO;

    }
}
-(void)chongzhiV:(NSString *)coins{
    if (_chongzhi && ![PublicObj checkNull:coins]) {
        NSString *currencyCoin = [YBToolClass getRateCurrency:coins showUnit:YES];
        _chongzhi.text = currencyCoin;
    }
}
//展示cell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _pageCount;
}
//定义section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.item >= self.models.count) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellWhite"
                                                                               forIndexPath:indexPath];
        return cell;
    } else {
        giftCell *cell = (giftCell *)[collectionView dequeueReusableCellWithReuseIdentifier:celll forIndexPath:indexPath];

        cell.layer.borderColor = RGB_COLOR(@"#383838", 0.25).CGColor;
        cell.layer.borderWidth = 1;
        liwuModel *model = self.models[indexPath.item];
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        cell.model = model;
        NSString *duihao = [NSString stringWithFormat:@"%@",selectedArray[indexPath.item]];
        
        if ([duihao isEqual:@"1"]) {
            cell.selectImgView.hidden = NO;
            WeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [cell.giftIcon.layer addAnimation:strongSelf.animation forKey:nil];
            });
        }
        else{
            cell.selectImgView.hidden = YES;
            [cell.giftIcon.layer removeAllAnimations];
        }
        return cell;
    }
    
}
- (void)addAnimation:(NSIndexPath *)indexpath{
    for (giftCell *cell in _collectionView.visibleCells) {
        if ([[_collectionView indexPathForCell:cell] isEqual:indexpath]) {
            [cell.giftIcon.layer addAnimation:self.animation forKey:nil];
        }else{
            [cell.giftIcon.layer removeAllAnimations];
        }
    }

}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;{
    [_collectionView reloadData];
//    [self addAnimation];
}
-(CABasicAnimation *)animation{
    if (!_animation) {
        _animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        //速度控制函数，控制动画运行的节奏
        _animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _animation.duration = 0.88;       //执行时间
        _animation.repeatCount = 9999999;      //执行次数
        _animation.autoreverses = YES;    //完成动画后会回到执行动画之前的状态
        _animation.fromValue = [NSNumber numberWithFloat:1];   //初始伸缩倍数
        _animation.toValue = [NSNumber numberWithFloat:0.8];     //结束伸缩倍数
    }
    return _animation;
}
-(void)reloadPushState{
    for (NSString *type in selectedArray) {
        if ([type isEqual:@"1"]) {
//            _push.backgroundColor = normalColors;
            _push.enabled = YES;
            break;
        }
    }
}
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item>=self.models.count) {
        return;
    }
    haohuaBtn.selected = YES;
    selectedArray = nil;
    selectedArray = [NSMutableArray array];
    for (int i=0; i<self.allArray.count; i++) {
        [selectedArray addObject:@"0"];
    }
    [selectedArray replaceObjectAtIndex:indexPath.item withObject:@"1"];
    _selectModel = self.models[indexPath.item];
    _push.enabled = YES;
    if (timer) {
//        [timer setFireDate:[NSDate distantFuture]];
        [timer invalidate];
        timer = nil;
    }
    _continuBTN.hidden = YES;

    if ([_selectModel.type isEqual:@"1"]) {
        haohuaBtn.hidden = NO;
        btnBgImgView.hidden = YES;
    }else{
        haohuaBtn.hidden = YES;
        btnBgImgView.hidden = NO;
    }
//    [self.collectionView reloadData];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.collectionView reloadData];
    });
//    [self addAnimation:indexPath];

}
//每个cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(_window_width/4-0.01, _window_width/4-0.01);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
        return UIEdgeInsetsMake(0,0,0,0);
}
//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
//cell的最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
@end
