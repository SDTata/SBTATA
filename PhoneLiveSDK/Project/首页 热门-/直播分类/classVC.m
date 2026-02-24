//
//  classVC.m
//  yunbaolive
//
//  Created by Boom on 2018/9/22.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "classVC.h"
#import "hotModel.h"
#import "LivePlay.h"
#import <CommonCrypto/CommonCrypto.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "HotCollectionViewCell.h"

@interface classVC ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    hotModel *selectedModel;
    NSString *type_val;//
    NSString *livetype;//
    int page;
    UIView *collectionHeaderView;
    UIAlertController *md5AlertController;
    UIView *nothingView;
    YBNoWordView *noNetwork;
}
@property(nonatomic,strong)NSMutableArray *zhuboModel;//主播模型
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSString *MD5;//加密密码

@end

@implementation classVC
-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor =navigationBGColor;
    UILabel *label = [[UILabel alloc]init];
    label.text = _titleStr;
    [label setFont:navtionTitleFont];
    label.textColor = navtionTitleColor;
    label.frame = CGRectMake(0, statusbarHeight,_window_width,84);
    label.textAlignment = NSTextAlignmentCenter;
    [navtion addSubview:label];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _zhuboModel = [NSMutableArray array];
    page = 1;
    [self navtion];
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake(_window_width/2-4.5, (_window_width/2-4.5) * 1.5);
    flow.minimumLineSpacing = 3;
    flow.minimumInteritemSpacing = 3;
    flow.sectionInset = UIEdgeInsetsMake(3, 3,3, 3);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,64+statusbarHeight, _window_width, _window_height-64-statusbarHeight) collectionViewLayout:flow];
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HotCollectionViewCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellWithReuseIdentifier:@"HotCollectionViewCELL"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hotHeaderV"];
    
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    WeakSelf
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->page = 1;
        [strongSelf pullInternet];
    }];
    header.stateLabel.textColor = [UIColor whiteColor];
    header.arrowView.tintColor = [UIColor whiteColor];
    header.activityIndicatorViewStyle = UIScrollViewIndicatorStyleWhite;
    
    _collectionView.mj_header = header;
    _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->page ++;
        [strongSelf pullInternet];
    }];
    
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    [self pullInternet];
    
    nothingView = [[UIView alloc]initWithFrame:CGRectMake(0, 200, _window_width, 40)];
    nothingView.hidden = YES;
    nothingView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:nothingView];
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _window_width, 20)];
    label1.font = [UIFont systemFontOfSize:14];
    label1.text = YZMsg(@"classVC_noAnchorLive");
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = RGB_COLOR(@"#333333", 1);
    [nothingView addSubview:label1];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, _window_width, 20)];
    label2.font = [UIFont systemFontOfSize:13];
    label2.text = YZMsg(@"classVC_goToOthersAnchorLive");
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = RGB_COLOR(@"#969696", 1);
    [nothingView addSubview:label2];
    
    noNetwork = [[YBNoWordView alloc]initWithImageName:NULL andTitle:NULL withBlock:^(id  _Nullable msg) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf pullInternet];
    } AddTo:self.view];
}
- (void)pullInternet{
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Home.getClassLive" withBaseDomian:YES andParameter:@{@"p":@(page),@"liveclassid":_classID} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf.collectionView.mj_header endRefreshing];
        [strongSelf.collectionView.mj_footer endRefreshing];
        strongSelf->noNetwork.hidden = YES;
        
        if (code == 0) {
            if (strongSelf->page == 1) {
                [strongSelf.zhuboModel removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                hotModel *model = [hotModel mj_objectWithKeyValues:dic];
                [strongSelf.zhuboModel addObject:model];
            }
            [strongSelf.collectionView reloadData];
            if ([info count] <= 0) {
                [strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        if (strongSelf.zhuboModel.count == 0) {
            strongSelf->nothingView.hidden = NO;
        }else{
            strongSelf->nothingView.hidden = YES;
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf.collectionView.mj_header endRefreshing];
        [strongSelf.collectionView.mj_footer endRefreshing];
        strongSelf->nothingView.hidden = YES;
        if (strongSelf.zhuboModel.count == 0) {
            strongSelf->noNetwork.hidden = NO;
        }
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@1088",YZMsg(@"public_networkError")]];
    }];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _zhuboModel.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    selectedModel = _zhuboModel[indexPath.row];
    [self checklive:selectedModel.stream andliveuid:selectedModel.zhuboID];
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HotCollectionViewCell *cell = (HotCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HotCollectionViewCELL" forIndexPath:indexPath];
    cell.model = _zhuboModel[indexPath.row];
    
    return cell;
}
-(void)checklive:(NSString *)stream andliveuid:(NSString *)liveuid{
    
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=Live.checkLive"];
    NSDictionary *param = @{@"liveuid":liveuid,@"stream":stream};
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud hideAnimated:YES afterDelay:15];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:NO andParameter:param data:nil success:^(int code, NSArray *infos, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        
        if(code == 0)
        {
            
            NSDictionary *info = [infos firstObject];
            NSString *type = [NSString stringWithFormat:@"%@",[info valueForKey:@"type"]];
            
            strongSelf->type_val =  [NSString stringWithFormat:@"%@",[info valueForKey:@"type_val"]];
            strongSelf->livetype =  [NSString stringWithFormat:@"%@",[info valueForKey:@"type"]];
            
            
            if ([type isEqual:@"0"]) {
                [strongSelf pushMovieVC];
            }
            else if ([type isEqual:@"1"]){
                NSString *_MD5 = [NSString stringWithFormat:@"%@",[info valueForKey:@"type_msg"]];
                //密码
                strongSelf->md5AlertController = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"EnterLivePlay_pwdRoomWarning") preferredStyle:UIAlertControllerStyleAlert];
                //添加一个取消按钮
                [strongSelf->md5AlertController addAction:[UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [strongSelf.navigationController popViewControllerAnimated:YES];
                    [strongSelf dismissViewControllerAnimated:NO completion:nil];
                }]];
                
                //在AlertView中添加一个输入框
                [strongSelf->md5AlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    
                    textField.placeholder = YZMsg(@"EnterLivePlay_input_pwd");
                }];
                
                //添加一个确定按钮 并获取AlertView中的第一个输入框 将其文本赋值给BUTTON的title
                WeakSelf
                [strongSelf->md5AlertController addAction:[UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    STRONGSELF
                    UITextField *alertTextField = strongSelf->md5AlertController.textFields.firstObject;
                    //                        [self checkMD5WithText:envirnmentNameTextField.text andMD5:_MD5];
                    //输出 检查是否正确无误
                    NSLog(@"你输入的文本%@",alertTextField.text);
                    if ([_MD5 isEqualToString:[strongSelf stringToMD5:alertTextField.text]]) {
                        [strongSelf pushMovieVC];
                    }else{
                        alertTextField.text = @"";
                        [MBProgressHUD showError:YZMsg(@"EnterLivePlay_pwd_error")];
                        if (strongSelf.presentedViewController == nil) {
                            [strongSelf presentViewController:(strongSelf->md5AlertController) animated:true completion:nil];
                        }
                        return ;
                    }
                    
                }]];
                
                if (strongSelf.presentedViewController == nil) {
                    [strongSelf presentViewController:(strongSelf->md5AlertController) animated:true completion:nil];
                }
                //present出AlertView
                
            }
            else if ([type isEqual:@"2"] || [type isEqual:@"3"]){
                UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:minstr([info valueForKey:@"type_msg"]) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [strongSelf.navigationController popViewControllerAnimated:YES];
                    [strongSelf dismissViewControllerAnimated:NO completion:nil];
                    
                }];
                [alertContro addAction:cancleAction];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [strongSelf doCoast];
                }];
                [alertContro addAction:sureAction];
                if (strongSelf.presentedViewController == nil) {
                    [strongSelf presentViewController:alertContro animated:YES completion:nil];
                }
                
            }
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError *error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    }];
}
-(void)pushMovieVC{
    
    moviePlay *player = [[moviePlay alloc]init];
//    player.scrollarray = _infoArray;
    player.scrollindex = 0;
    player.playDocModel = selectedModel;
    player.type_val = type_val;
    player.livetype = livetype;
    [[MXBADelegate sharedAppDelegate] pushViewController:player animated:YES];
}
- (NSString *)stringToMD5:(NSString *)str
{
    
    //1.首先将字符串转换成UTF-8编码, 因为MD5加密是基于C语言的,所以要先把字符串转化成C语言的字符串
    const char *fooData = [str UTF8String];
    
    //2.然后创建一个字符串数组,接收MD5的值
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    //3.计算MD5的值, 这是官方封装好的加密方法:把我们输入的字符串转换成16进制的32位数,然后存储到result中
    CC_MD5(fooData, (CC_LONG)strlen(fooData), result);
    /**
     第一个参数:要加密的字符串
     第二个参数: 获取要加密字符串的长度
     第三个参数: 接收结果的数组
     */
    
    //4.创建一个字符串保存加密结果
    NSMutableString *saveResult = [NSMutableString string];
    
    //5.从result 数组中获取加密结果并放到 saveResult中
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [saveResult appendFormat:@"%02x", result[i]];
    }
    /*
     x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
     NSLog("%02X", 0x888);  //888
     NSLog("%02X", 0x4); //04
     */
    return saveResult;
}
//执行扣费
-(void)doCoast{
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.roomCharge" withBaseDomian:YES andParameter:@{@"liveuid":minstr(selectedModel.zhuboID),@"stream":minstr(selectedModel.stream)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0)
        {
            [strongSelf pushMovieVC];
            //计时扣费
        }else if(code == 1008){
            
            PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            payView.titleStr = YZMsg(@"Bet_Charge_Title");
            [payView setHomeMode:false];
            [strongSelf.navigationController pushViewController:payView animated:YES];
        }
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.collectionView.mj_header endRefreshing];
    }];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
