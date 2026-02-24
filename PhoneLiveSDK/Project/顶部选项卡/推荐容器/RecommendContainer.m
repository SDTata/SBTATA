//
//  RecommendContainer.m
//  phonelive2
//
//  Created by user on 2024/9/30.
//  Copyright © 2024 toby. All rights reserved.
//

#import "RecommendContainer.h"
#import "RecommendMainVC.h"
#import "h5game.h"
#import "webH5.h"

@interface RecommendContainer () {
    RecommendMainVC *_recommendMainVC;
    h5game *_h5gameVC;
    webH5 *_webH5VC;
    NSString *gameURLPath;
    NSString *lastOperate; //纪录最后一次是转出或是转入状态
}
@end

@implementation RecommendContainer

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(convertCoinOut:) name:@"KNoticeConvertCoinOut" object:nil];
}


- (void)setupViews {
    self.view.backgroundColor = [UIColor clearColor];
    NSMutableArray *arrayTitles = [NSMutableArray array];
    if (self.tags.count > 0) {
        for (int i = 0; i< self.tags.count; i++) {
            [arrayTitles addObject:self.tags[i][@"tag_name"]];
        }
    } else {
        [arrayTitles addObject:@"推薦"];
    }
    self.categoryView.segmentStyle = SegmentStyleRound;
    self.categoryView.titles = arrayTitles;
    self.categoryView.hidden = arrayTitles.count == 1;
    [self.view addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(24);
    }];
    
    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(arrayTitles.count == 1 ? self.view.mas_top : self.categoryView.mas_bottom).offset(10);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)handleRecommendRefresh {
    [_recommendMainVC handleRefresh];
}

- (void)handleRedirectToRecommend {
    [self.categoryView selectItemAtIndex:0];
}

- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    [self convertCoinOut:nil];
    if (index == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KNoticeHidenWobble" object:@{@"hidenWobble":@0}]; //显示宝箱
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KNoticeHidenWobble" object:@{@"hidenWobble":@1}]; //隐藏宝箱
    }
    [self needShowTicket:index];
}
-(void)pageViewDidClickItemAtIndex:(NSInteger)index {
    [self needShowTicket:index];
}

- (void)needShowTicket:(NSInteger)index {
    if (self.tags.count > 0) {
        self.listContainerView.scrollView.scrollEnabled = YES;
        NSString *type = self.tags[index][@"tag_type"];
        if ([type isEqualToString:@"recommend_recommend"]) { // 推荐
            [VideoTicketFloatView showTicketButton];
        } else if ([type isEqualToString:@"game"]) { // 链游
            [VideoTicketFloatView hideTicketButton];
            self.listContainerView.scrollView.scrollEnabled = NO;
        } else if ([type isEqualToString:@"web"]) { // 活动
            [VideoTicketFloatView hideTicketButton];
        }
    }
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
    if (self.tags.count > 0) {
        NSString *type = self.tags[index][@"tag_type"];
        if ([type isEqualToString:@"recommend_recommend"]) { // 推荐
            if (_recommendMainVC == nil) {
                _recommendMainVC = [RecommendMainVC new];
            }
            return (id)_recommendMainVC;
        } else if ([type isEqualToString:@"game"]) { // 链游
            gameURLPath = self.tags[index][@"tag_url"];
            if (_h5gameVC == nil) {
                _h5gameVC = [h5game new];
            }
            _h5gameVC.isFromHomeUrls = gameURLPath;
            _h5gameVC.titles = @"";
            _h5gameVC.bHiddenReturnBtn = true;
            if (index == 0) {
                [self performSelector:@selector(handleRedirectToRecommend) withObject:nil afterDelay:0.5];
            }
            return _h5gameVC;
        } else if ([type isEqualToString:@"web"]) { // 活动
            NSString *urlString = self.tags[index][@"tag_url"];;
            NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
            NSError *error = nil;
            NSAttributedString *decodedAttributedString = [[NSAttributedString alloc] initWithData:data
                                                                                           options:options
                                                                                documentAttributes:nil
                                                                                             error:&error];
            if (error) {
                NSLog(@"Error parsing HTML: %@", error.localizedDescription);
                return [VKPagerChildVC new];
            }
            NSString *url = decodedAttributedString.string;
            
            if (url.length > 9) {
                if (_webH5VC == nil) {
                    _webH5VC = [webH5 new];
                }
                _webH5VC.isFromHome = YES;
                _webH5VC.titles = @"";
                url = [YBToolClass decodeReplaceUrl:url];
                _webH5VC.urls = url;
                return _webH5VC;
            } else {
                return [VKPagerChildVC new];
            }
        } else {
            return [VKPagerChildVC new];
        }
    } else {
        // 推荐
        if (_recommendMainVC == nil) {
            _recommendMainVC = [RecommendMainVC new];
        }
        return (id)_recommendMainVC;
    }
}

- (void)requestData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *getBalanceNewUrl = [NSString stringWithFormat:@"User.getPlatGameBalance&uid=%@&token=%@&game_plat=user",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getBalanceNewUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        //当旋转结束时隐藏
        [MBProgressHUD hideHUD];
        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = info;
            LiveUser *user = [Config myProfile];
            user.coin = minstr([infoDic valueForKey:@"coin"]);
            [Config updateProfile:user];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        
        [MBProgressHUD hideHUD];
    }];
}
- (void)convertCoinOut:(nullable NSNotification*)notification {
    NSString *subplat = @"";
    NSString *kindid = @"";
    NSDictionary *params = [YBToolClass getUrlParamWithUrl:gameURLPath];
    if (params) {
        NSString *game = params[@"game"];
        NSString *plat = params[@"plat"];
        kindid = params[@"kindid"];
        subplat = plat ? plat : game; //这里切换到游戏的时候，转入转出的api  User.convertCoin的参数subplat，优先从这里新加的协议 plat取值，如果没有就取game。
    }
    NSString *operate = (self.currentVC == _h5gameVC) ? @"in" : @"out";
    if (notification && notification.object[@"operate"]) {
        operate = notification.object[@"operate"];
    }
    NSInteger operateValue = -1;
    if ([common getAutoExchange] && ![subplat isEqualToString:@""] && ![lastOperate isEqualToString:operate]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *convertCoinUrl = [NSString stringWithFormat:@"User.convertCoin&uid=%@&token=%@&subplat=%@&operate=%@&value=%ld",[Config getOwnID],[Config getOwnToken],subplat,operate,operateValue];
            if (![PublicObj checkNull:kindid]) {
                convertCoinUrl = [convertCoinUrl stringByAppendingFormat:@"&kind_id=%@",kindid];
            }
            WeakSelf
            [[YBNetworking sharedManager] postNetworkWithUrl:convertCoinUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf->lastOperate = operate; //纪录 in 或是 out, 避免切换画面一直重复转出或转入
                [MBProgressHUD hideHUD];
                if (code == 0 && info && ![info isEqual:[NSNull null]]) {
                    [strongSelf requestData];
                } else {
//                    [MBProgressHUD showError:msg];
                }
            } fail:^(NSError * _Nonnull error) {
                [MBProgressHUD hideHUD];
            }];
        });
    }
}
- (void)resetOperate {
    lastOperate = @"";
}
@end
