//
//  myInfoEdit.m
//  yunbaolive
//
//  Created by cat on 16/3/13.
//  Copyright © 2016年 cat. All rights reserved.
//

#import "myInfoEdit.h"
#import "InfoEdit1TableViewCell.h"
#import "InfoEdit2TableViewCell.h"
#import "EditNiceName.h"
#import "EditSignature.h"
#import "EditContactInfo.h"
#import "BindPhoneNumberViewController.h"
#import "sexCell.h"
#import "sexChange.h"
#import "SDImageCache.h"
#import "impressVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
@interface myInfoEdit ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    int setvisinfo;
    UIDatePicker *datapicker;
    NSString *datestring;//保存时间
    UIAlertController *alert;
    UIActivityIndicatorView *testActivityIndicator;//菊花
    NSArray *itemArray;
    SDAnimatedImage *fileImage;

}

@end

@implementation myInfoEdit


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = RGB_COLOR(@"#E3E3E3", 1);
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.view.backgroundColor = RGB(244, 245, 246);
    self.tableView.backgroundColor = RGB(244, 245, 246);

    itemArray = @[@[YZMsg(@"InfoEdit1TableViewCell_Avatar"),YZMsg(@"myInfoEdit_nickName"),YZMsg(@"myInfoEdit_phoneNum"),YZMsg(@"myInfoEdit_email"),YZMsg(@"myInfoEdit_signature"),YZMsg(@"myInfoEdit_MyCard")],@[YZMsg(@"myInfoEdit_BirthDay"),YZMsg(@"myInfoEdit_Sex"),YZMsg(@"myInfoEdit_My_Impressed")]];

    self.view.backgroundColor = [UIColor whiteColor];
    datapicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0,0, _window_width-16, _window_height*0.3)];
    

    NSDate *currentDate = [NSDate date];
    [datapicker setMaximumDate:currentDate];
    
    NSDateFormatter  * formatter = [[ NSDateFormatter   alloc ] init ];
    
    [formatter  setDateFormat : @"yyyy-MM-dd" ];
    
    NSString  * mindateStr =  @"1950-01-01" ;
    
    NSDate  * mindate = [formatter  dateFromString :mindateStr];
    
    datapicker . minimumDate = mindate;
    
    datapicker.maximumDate=[NSDate date];
    
    [datapicker addTarget:self action:@selector(oneDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged ];
    
    datapicker.datePickerMode = UIDatePickerModeDate;

    NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:CurrentLanguage]];
    
    [datapicker setLocale:locale];
    datapicker.calendar = [locale objectForKey:NSLocaleCalendar];
    NSString *alertTitle;
    if (_window_height <= 667.0) {
        alertTitle = @"\n\n\n\n\n\n\n\n\n";
    }else{
        alertTitle = @"\n\n\n\n\n\n\n\n\n\n\n\n";
    }
    
    alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert.view addSubview:datapicker];
    WeakSelf
    UIAlertAction *ok = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf getbirthday];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        
        
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    
    
}
//生日
-(void)getbirthday{
    
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    testActivityIndicator.center = self.view.center;
    [self.view addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor blackColor];
    [testActivityIndicator startAnimating]; // 开始旋转
    
    
    if (datestring == nil) {
        
        NSDate *currentDate = [NSDate date];//获取当前时间，日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        datestring = [dateFormatter stringFromDate:currentDate];
        
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[datestring] forKeys:@[@"birthday"]];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *url = [NSString stringWithFormat:@"User.updateFields&uid=%@&token=%@&fields=%@",[Config getOwnID],[Config getOwnToken],jsonStr];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:YES andParameter:nil data:nil success:^(int code, NSArray * _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0)
        {
            LiveUser *user = [Config myProfile];
            user.birthday = strongSelf->datestring;
            [Config updateProfile:user];
            [strongSelf.tableView reloadData];
            
        }
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        
    }];
    
    
}
- (void)oneDatePickerValueChanged:(UIDatePicker *) sender {
    
    
    NSDate *select = [sender date]; // 获取被选中的时间
    NSDateFormatter *selectDateFormatter = [[NSDateFormatter alloc] init];
    [selectDateFormatter setDateFormat:@"YYYY-MM-dd"];
    datestring = [selectDateFormatter stringFromDate:select]; // 把date类型转为设置好格式的string类型
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    setvisinfo = 1;
    [self.tableView reloadData];
    [self navtion];
    [self.tableView reloadData];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    setvisinfo = 0;
}
-(void)navtion{
    if ([self.view viewWithTag:100022]!=nil) {
        return;
    }
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.tag = 100022;
    navtion.backgroundColor = navigationBGColor;
    UILabel *label = [[UILabel alloc]init];
    label.text = YZMsg(@"myInfoEdit_EditInfo");
    [label setFont:navtionTitleFont];
    
    label.textColor = navtionTitleColor;
    label.frame = CGRectMake(0, statusbarHeight,_window_width,84);
    // label.center = navtion.center;
    label.textAlignment = NSTextAlignmentCenter;
    [navtion addSubview:label];
    
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
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
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.mas_equalTo(navtion.bottom);
    }];
    
}
-(void)money{
    
    
}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //判断返回cell
    LiveUser *users = [Config myProfile];
    if (indexPath.section == 0) {
        if (indexPath.row==0) {
            InfoEdit1TableViewCell *cell = [InfoEdit1TableViewCell cellWithTableView:tableView];
            cell.imgRight.layer.masksToBounds = YES;
            cell.imgRight.layer.cornerRadius = 22;
            
            if (fileImage) {
                cell.imgRight.image = fileImage;
            }else{
                LiveUser *user = [[LiveUser alloc] init];
                user =  [Config myProfile];
                NSURL *url = [NSURL URLWithString:user.avatar];
                [cell.imgRight sd_setImageWithURL:url placeholderImage:[ImageBundle imagewithBundleName:@"profile_accountImg"]];
            }
            return cell;
        }else{
            InfoEdit2TableViewCell *cell = [InfoEdit2TableViewCell cellWithTableView:tableView];
            cell.labContrName.text = itemArray[indexPath.section][indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.line.hidden = YES;
            if(@available(iOS 13.0, *)){
                UIImageView *accessoryView =[[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:@"arrows_43"]] ;
                cell.accessoryView= accessoryView;
            }else{
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            }
            if (indexPath.row == 1) {
                cell.labDetail.text = [Config getOwnNicename];
            }else if (indexPath.row == 2){
                if ([Config getIsBindMobile]) {
                    cell.labDetail.textColor = RGB_COLOR(@"#999999", 1);
                    NSString *mobileString = [Config getMobile];
                    if (![mobileString containsString:@"@"]) {
                        cell.labDetail.text = mobileString;
                    }
                    if(@available(iOS 13.0, *)){
                        UIImageView *accessoryView =[[UIImageView alloc] initWithImage:[UIImage new]] ;
                        cell.accessoryView= accessoryView;
                    }else{
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        
                    }
                }else{
                    cell.labDetail.textColor = RGB_COLOR(@"#999999", 1);
                    cell.labDetail.text = YZMsg(@"YBUserInfoVC_BindPhone");
                    if(@available(iOS 13.0, *)){
                        UIImageView *accessoryView =[[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:@"arrows_43"]] ;
                        cell.accessoryView= accessoryView;
                    }else{
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                }
            } else if(indexPath.row == 3) {
                if ([Config getUser_email].length > 0) {
                    cell.labDetail.textColor = RGB_COLOR(@"#999999", 1);
                    cell.labDetail.text = [Config getUser_email];
                    if(@available(iOS 13.0, *)){
                        UIImageView *accessoryView =[[UIImageView alloc] initWithImage:[UIImage new]] ;
                        cell.accessoryView= accessoryView;
                    }else{
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                } else {
                    cell.labDetail.textColor = RGB_COLOR(@"#999999", 1);
                    cell.labDetail.text = YZMsg(@"YBUserInfoVC_BindEmail");
                    if(@available(iOS 13.0, *)){
                        UIImageView *accessoryView =[[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:@"arrows_43"]] ;
                        cell.accessoryView= accessoryView;
                    }else{
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                }
            }
            else if(indexPath.row == 4)
            {
                cell.labDetail.textColor = RGB_COLOR(@"#999999", 1);
                cell.labDetail.text = [Config getOwnSignature];
            }
            else if(indexPath.row == 5)
            {
                /*
                cell.labDetail.textColor = RGB_COLOR(@"#999999", 1);
                NSString *contact_info = [Config getOwnContactInfo];
                if(!contact_info || contact_info.length == 0){
                    cell.labDetail.text = YZMsg(@"EditContactInfo_Empty");
                }else{
                    cell.labDetail.text = contact_info;
                }
                 */
            }
            return cell;
        }
    }
    else
    {
        InfoEdit2TableViewCell *cell = [InfoEdit2TableViewCell cellWithTableView:tableView];
        cell.labContrName.text = itemArray[indexPath.section][indexPath.row];
        cell.line.hidden = YES;
        
       if (indexPath.row == 0){
            cell.labDetail.text = users.birthday;
        }
        else if (indexPath.row == 1){
            if ([users.sex isEqual:@"1"]) {
                cell.labDetail.text = YZMsg(@"myInfoEdit_Man");
            }else{
                cell.labDetail.text = YZMsg(@"myInfoEdit_Woman");
            }
        }else{
            cell.labDetail.text = @"";
        }
        if(@available(iOS 13.0, *)){
            UIImageView *accessoryView =[[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:@"arrows_43"]] ;
            cell.accessoryView= accessoryView;
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        return cell;
        
        
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0&&indexPath.row==0) {
        return 60;
    }
    else{
        return 50;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //判断当前分区返回分区行数
    return [itemArray[section] count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //返回分区数
    return itemArray.count;
}
- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section
{
    return 0.01;
    
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 10)];
    view.backgroundColor = RGB(244, 245, 246);
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger) section
{
    return 10;
}
//点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //判断返回cell
    if (indexPath.section == 0) {
        if (indexPath.row==0) {
            WeakSelf
            UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *picAction = [UIAlertAction actionWithTitle:YZMsg(@"Livebroadcast_Alumb") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf selectThumbWithType:UIImagePickerControllerSourceTypePhotoLibrary];
            }];
            [alertContro addAction:picAction];
            UIAlertAction *photoAction = [UIAlertAction actionWithTitle:YZMsg(@"Livebroadcast_Camera") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf selectThumbWithType:UIImagePickerControllerSourceTypeCamera];
            }];
            [alertContro addAction:photoAction];
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertContro addAction:cancleAction];
            if (self.presentedViewController == nil) {
                [self presentViewController:alertContro animated:YES completion:nil];
            }
        }else if (indexPath.row==1){
            EditNiceName *EditNameView = [[EditNiceName alloc] init];
            [[MXBADelegate sharedAppDelegate] pushViewController:EditNameView animated:YES];
        }else if (indexPath.row == 2){
            if (![Config getIsBindMobile]) {
                BindPhoneNumberViewController *vc = [[BindPhoneNumberViewController alloc]initWithNibName:@"BindPhoneNumberViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
            }
        }else if (indexPath.row == 3){
            if ([Config getUser_email].length <= 0) {
                BindPhoneNumberViewController *vc = [[BindPhoneNumberViewController alloc]initWithNibName:@"BindPhoneNumberViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                vc.bindingType = BindingTypeForEmail;
                [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
            }
        }else if (indexPath.row==4){
            EditSignature *EditSignatureView = [[EditSignature alloc] init];
            [[MXBADelegate sharedAppDelegate] pushViewController:EditSignatureView animated:YES];
        }else if (indexPath.row==5){
            EditContactInfo *EditContactInfoView = [[EditContactInfo alloc] init];
            [[MXBADelegate sharedAppDelegate] pushViewController:EditContactInfoView animated:YES];
        }
    }else if(indexPath.section == 1){
        if(indexPath.row == 0){
            if (self.presentedViewController == nil) {
                [self presentViewController:alert animated:YES completion:nil];
            }
        }else if (indexPath.row==1){
            sexChange *sex = [[sexChange alloc]initWithNibName:@"sexChange" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            [[MXBADelegate sharedAppDelegate] pushViewController:sex animated:YES];
        }else {
            impressVC *vc = [[impressVC alloc]init];
            vc.isAdd = NO;
            vc.touid = @"0";
            [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        }
    }
    
}
- (void)selectThumbWithType:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = type;
//    imagePickerController.allowsEditing = YES;
    // 添加所有图片类型，包括 GIF 和实况照片
    NSMutableArray *mediaTypes = [NSMutableArray array];
    [mediaTypes addObject:(NSString *)kUTTypeImage];          // 静态图片
    [mediaTypes addObject:(NSString *)kUTTypeGIF];            // 动态GIF图片

    // 检查是否支持实况照片
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeLivePhoto]) {
            [mediaTypes addObject:(NSString *)kUTTypeLivePhoto]; // 实况照片
        }
    }

    imagePickerController.mediaTypes = mediaTypes;
    if (type == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = YES;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    if (self.presentedViewController == nil) {
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [MBProgressHUD showMessage:YZMsg(@"myInfoEdit_Uploading")];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([type isEqualToString:(NSString *)kUTTypeImage]) {
        // 获取选中的图片
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!image) {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        NSURL *imgUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        fileImage = [SDAnimatedImage imageWithCGImage:image.CGImage];
        // 根据图片类型设置 filename 和 mimeType
        NSString *fileName;
        NSString *mimeType;
        NSData *data;
        
        // 获取图片数据和类型
        if ([type isEqualToString:(NSString *)kUTTypeGIF]||(imgUrl!= nil &&[imgUrl.absoluteString containsString:@"ext=GIF"])) {
            // Handle GIF image
            NSURL *dataUrl = [info objectForKey:UIImagePickerControllerImageURL];
            if (dataUrl) {
                data = [NSData dataWithContentsOfURL:dataUrl];
            }
            fileImage = [SDAnimatedImage imageWithData:data];
            fileName = @"image.gif";
            mimeType = @"image/gif";
        } else if ([type isEqualToString:(NSString *)kUTTypeLivePhoto]) {
            // Handle Live Photo
//            PHLivePhoto *livePhoto = [info objectForKey:UIImagePickerControllerLivePhoto];
            // You can extract the movie component of the Live Photo here if needed
            fileName = @"image.jpeg";
            mimeType = @"image/jpeg";
            data = UIImageJPEGRepresentation(image, 0.5);
        } else if ([type isEqualToString:(NSString *)kUTTypePNG]) {
            data = UIImagePNGRepresentation(image);
            fileName = @"image.png";
            mimeType = @"image/png";
        } else {
            // 默认使用 JPEG 格式
            data = UIImageJPEGRepresentation(image, 0.5);
            fileName = @"image.jpg";
            mimeType = @"image/jpeg";
        }
        
        [self.tableView reloadData];
        DataForUpload *dataUpload = [[DataForUpload alloc] init];
        dataUpload.datas = data;
        dataUpload.name = @"file";
        dataUpload.filename = fileName;
        dataUpload.mimeType = mimeType;
        
        NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=User.updateAvatar&uid=%@&token=%@", [Config getOwnID], [Config getOwnToken]];
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:NO andParameter:nil data:dataUpload success:^(int code, NSArray *infos, NSString *msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [MBProgressHUD hideHUD];
            if (code == 0) {
                SDImageCache *sdImgCache = [[SDImageCache alloc] initWithNamespace:@"default"];
                [sdImgCache clearMemory]; // 可有可无
                NSString *info = [infos firstObject];
                NSString *avatar = [info valueForKey:@"avatar"];
                NSString *avatar_thumb = [info valueForKey:@"avatar_thumb"];
                LiveUser *user = [Config myProfile];
                user.avatar = avatar;
                user.avatar_thumb = avatar_thumb;
                
                [Config updateProfile:user];
                [strongSelf.tableView reloadData];
                [MBProgressHUD showError:msg];
            } else {
                [MBProgressHUD showError:msg];
            }
        } fail:^(NSError *error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:YZMsg(@"myInfoEdit_Upload_Error")];
        }];
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11) {
        return;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")]) {
        [viewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.frame.size.width < 42) {
                [viewController.view sendSubviewToBack:obj];
                *stop = YES;
            }
        }];
    }
}

@end
