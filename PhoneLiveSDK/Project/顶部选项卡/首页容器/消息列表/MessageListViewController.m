//
//  MessageListViewController.m
//  phonelive2
//
//  Created by user on 2024/8/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MessageListViewController.h"
#import "MessageListNetworkUtil.h"
#import "MessageListViewCell.h"
#import "MsgSysVC.h"
#import "SystemMsgModel.h"
#import "InteractiveMessagesCell.h"
#import "ShortVideoListViewController.h"
#import "otherUserMsgVC.h"
#import "VideoCommentsNetworkUtil.h"    
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <UMCommon/UMCommon.h>

@interface MessageListViewController () <InteractiveMessagesCellDelegate, UITableViewDelegate> {
    YBNavi *navi;
    UIButton *clearAllButton;
}
@property (nonatomic, strong) VKBaseTableView *tableView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIView *keyboardMaskView;
@property (nonatomic, strong) UIView *textFieldBg;
@property (nonatomic, strong) InteractionMessagesModel *reply_model;
@property (nonatomic, strong) UIView *noNewsView;
@end

@implementation MessageListViewController
#ifdef DEBUG
static BOOL hasShownSwipe = NO; // 在调试环境每次都提示
#else
// 在发布环境用本地存储
#define kSwipeHintKey @"SwipeHintShown"
#endif

- (instancetype)initWithMessageList:(BOOL)isHomeMessagesList {
    self = [super init];
    if (self) {
        // YES 消息列表
        // NO  消息列表 byType (列表首页下一层的意思)
        self.isHomeMessagesList = isHomeMessagesList;
    }
    return self;
}

- (void)dealloc {
    // 移除键盘通知监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [self.keyboardMaskView removeFromSuperview];
    self.keyboardMaskView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isHomeMessagesList) {
        [self getHomeMessageList];
    } else {
        [self getInteractionMessages];
    }
}

- (void)setupView {
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    UIView *navtion = [[UIView alloc] initWithFrame: CGRectZero];
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(doReturn:) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    titleLabel.userInteractionEnabled = YES;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:18];
    if (self.isHomeMessagesList) {
        titleLabel.text = YZMsg(@"message_list");
    } else {
        titleLabel.text = self.navTitle ? self.navTitle : YZMsg(@"message_list");
        UIButton *clearAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *clearBtnTitle = [self.type isEqualToString:@"system"] ? YZMsg(@"read_all") : YZMsg(@"LobbyBet_ClearAll");
        [clearAllBtn setTitle:clearBtnTitle forState:UIControlStateNormal];
        [clearAllBtn setTitleColor:vkColorRGB(105, 105, 105) forState:UIControlStateNormal];
        [clearAllBtn addTarget:self action:@selector(doClearAll:) forControlEvents:UIControlEventTouchUpInside];
        [navtion addSubview:clearAllBtn];
        [clearAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(navtion).inset(20);
            make.centerY.mas_equalTo(navtion);
            make.height.mas_equalTo(44);
        }];
        [clearAllBtn setHidden:YES];
        clearAllButton = clearAllBtn;
        [self setupKeyboard];
    }
    [navtion addSubview:titleLabel];
    
    [self.view addSubview:navtion];
    self.view.backgroundColor = vkColorRGB(234, 231, 238);
    
    [self.view addSubview:self.tableView];
    [navtion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.mas_equalTo(44);
        make.leading.trailing.mas_equalTo(self.view);
    }];
    
    [returnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(navtion).offset(10);
        make.centerY.mas_equalTo(navtion);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(44);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(44);
        make.center.mas_equalTo(navtion);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(navtion.mas_bottom);
        make.bottom.mas_equalTo(0);
    }];
    //[self.tableView reloadData];
    [self.tableView vk_headerBeginRefreshing];
    
    UIView *noNewsView = [UIView new];
    noNewsView.hidden = YES;
    [self.view addSubview:noNewsView];
    [noNewsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.view.mas_width).multipliedBy(0.4);
        make.centerX.mas_equalTo(self.view);
        make.centerY.mas_equalTo(self.view).multipliedBy(0.7);
    }];
    self.noNewsView = noNewsView;
    
    UIImageView *noNewsImgView = [UIImageView new];
    noNewsImgView.image = [ImageBundle imagewithBundleName:@"messageListView_no_news"];
    UILabel *noNewTitle = [UILabel vk_label:YZMsg(@"message_list_no_messages") font:vkFontBold(14) color:vkColorRGBA(0, 0, 0, 0.7)];
    UILabel *noNewSubTitle = [UILabel vk_label:YZMsg(@"message_list_go_play_game") font:vkFontMedium(12) color:vkColorRGBA(0, 0, 0, 0.5)];
    
    [noNewsView addSubview:noNewsImgView];
    [noNewsView addSubview:noNewTitle];
    [noNewsView addSubview:noNewSubTitle];
    
    [noNewsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.view.mas_width).multipliedBy(0.4);
        make.center.mas_equalTo(noNewsView);
    }];
    [noNewTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
        make.centerX.mas_equalTo(noNewsView);
        make.top.mas_equalTo(noNewsView.mas_bottom).offset(2);
    }];
    [noNewSubTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(14);
        make.centerX.mas_equalTo(noNewsView);
        make.top.mas_equalTo(noNewTitle.mas_bottom).offset(9);
    }];
}

- (void)doReturn:(UIButton *)sender {
    [[MXBADelegate sharedAppDelegate] popViewController:YES];
}

- (void)doClearAll:(UIButton *)sender {
    if ([self.type isEqualToString:@"system"]) {
        self.tableView.pageIndex = 1;
        [MBProgressHUD showMessage:nil];
        WeakSelf
        [MessageListNetworkUtil setMarkMessageAsRead:@"0" type:self.type block:^(NetworkData *networkData) {
            [MBProgressHUD hideHUD];
            STRONGSELF
            if (!strongSelf) return;
            if (![strongSelf.type isEqualToString:@"system"]) {
                [strongSelf.tableView.dataItems removeAllObjects];
            }
            [strongSelf.tableView vk_refreshFinish:strongSelf.tableView.dataItems];
            [strongSelf->clearAllButton setHidden:YES];
        }];
        return;
    }
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [MessageListNetworkUtil deleteInteractionMessages:@"0" type:self.type block:^(NetworkData *networkData) {
        [MBProgressHUD hideHUD];
        STRONGSELF
        if (!strongSelf) return;
        if (![strongSelf.type isEqualToString:@"system"]) {
            [strongSelf.tableView.dataItems removeAllObjects];
        }
        [strongSelf.tableView vk_refreshFinish:strongSelf.tableView.dataItems];
        [strongSelf->clearAllButton setHidden:YES];
    }];
}

- (VKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseTableView new];
        _tableView.viewStyle = VKTableViewStyleSingle;
        if (self.isHomeMessagesList) {
            _tableView.registerCellClass = [MessageListViewCell class];
        } else {
            _tableView.registerCellClass = [InteractiveMessagesCell class];
            _tableView.extraDelegate = self;
        }
        _tableView.automaticDimension = YES;
        _tableView.estimatedRowHeight = 92.0;
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
        
        [_tableView vk_headerRefreshSet];
        [_tableView vk_footerRefreshSet];
        
        WeakSelf
        _tableView.loadDataBlock = ^{
            STRONGSELF
            if (strongSelf.isHomeMessagesList) {
                [strongSelf getHomeMessageList];
            } else {
                [strongSelf getInteractionMessages];
            }
        };
        
        _tableView.registerCellClassBlock = ^Class(NSIndexPath *indexPath, id item) {
            STRONGSELF
            if (strongSelf.isHomeMessagesList) {
                return [MessageListViewCell class];
            } else {
                return [InteractiveMessagesCell class];
            }
        };
        
        _tableView.commitEditingBlock = ^(UITableView *tableView, NSIndexPath *indexPath) {
            STRONGSELF
            // 自定義刪除邏輯
            InteractionMessagesModel *model = strongSelf.tableView.dataItems[indexPath.row];
            [strongSelf.tableView.dataItems removeObjectAtIndex: indexPath.row];
            [strongSelf.tableView vk_refreshFinish:strongSelf.tableView.dataItems];
            [MBProgressHUD showMessage:nil];
            [MessageListNetworkUtil deleteInteractionMessages:model.identifier type:strongSelf.type block:^(NetworkData *networkData) {
                [MBProgressHUD hideHUD];
            }];
        };

        
        _tableView.deleteTitleBlock = ^NSString *(UITableView *tableView, NSIndexPath *indexPath) {
            // 自定義刪除按鈕的標題，根據行返回不同的標題
            return YZMsg(@"BetCell_remove");
        };

        _tableView.canEditRowBlock = ^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
            STRONGSELF
            if (strongSelf == nil) {
                return NO;
            }
            return !strongSelf.isHomeMessagesList && [strongSelf.type isEqualToString:@"interaction"];
        };

        _tableView.configureCellBlock = ^(UITableViewCell *cell, id item, NSIndexPath *indexPath) {
            STRONGSELF
            InteractionMessagesModel *model = item;
            if (!strongSelf.isHomeMessagesList && [cell isKindOfClass:[InteractiveMessagesCell class]] && [model.messageType isEqualToString:@"system"]) {
                if ([model.from_user_name isEqualToString:@""]) {
                    model.from_user_name = strongSelf.navTitle;
                }
            }
            ((InteractiveMessagesCell *)cell).itemModel = item;
            [((InteractiveMessagesCell *)cell) updateData];
            ((InteractiveMessagesCell *)cell).delegate = strongSelf;
        };
        
        // 使用自动尺寸计算单元格高度
        _tableView.automaticDimension = YES;
        _tableView.estimatedRowHeight = 92.0; // 设置一个预估高度，提高性能
        
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, id item) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            
            if (strongSelf.isHomeMessagesList) {
                MessageListViewController *vc = [[MessageListViewController alloc] initWithMessageList:NO];
                vc.type = ((NewMessageListModel *)item).type;
                vc.navTitle = ((NewMessageListModel *)item).title;
                [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
                NSDictionary *dict = @{ @"eventType": @(0),
                                        @"message_title":  vc.navTitle};
                [MobClick event:@"system_messagetype_click" attributes:dict];
            } else {
                InteractionMessagesModel *model = item;
                if ([model.messageType isEqualToString:@"interaction"]) { // 互动消息
                    [ShortVideoListViewController requestVideo:model.video_id autoDeduct:YES refresh_url:YES completion:^(ShortVideoModel * _Nonnull newModel, BOOL success, NSString *errorMsg) {
                        if (strongSelf == nil || !success) {
                            if (errorMsg.length > 0) {
                                [MBProgressHUD showError:errorMsg];
                            }
                            return;
                        }
                        [MBProgressHUD hideHUD];
                        ShortVideoListViewController *vc = [[ShortVideoListViewController alloc] initWithHost:@""];
                        [vc showVideoCommentWithID:model.comment_id messageId:model.identifier];
                        [vc updateData:@[(ShortVideoModel*)newModel] selectIndex:0 fetchMore:NO];
                        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
                    }];
                } else if ([model.messageType isEqualToString:@"system"]) {  // 系统消息
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:model.content preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *confirm = [UIAlertAction actionWithTitle:YZMsg(@"publictool_copy") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [UIPasteboard generalPasteboard].string = model.content;
                    }];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [alertC dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [alertC addAction:confirm];
                    [alertC addAction:cancel];
                    [strongSelf presentViewController:alertC animated:YES completion:nil];
                }else{
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:model.content preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *confirm = [UIAlertAction actionWithTitle:YZMsg(@"publictool_copy") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [UIPasteboard generalPasteboard].string = model.content;
                    }];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [alertC dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [alertC addAction:confirm];
                    [alertC addAction:cancel];
                    [strongSelf presentViewController:alertC animated:YES completion:nil];
                }
            }
        };
        _tableView.willDisplayCellBlock = ^(UITableView *tableView, UITableViewCell *cell, NSIndexPath *indexPath) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (!strongSelf.isHomeMessagesList) {
                if ([strongSelf.tableView.dataItems[indexPath.row] isKindOfClass:[InteractionMessagesModel class]]) {
                    InteractionMessagesModel *model = strongSelf.tableView.dataItems[indexPath.row];
                    if (![model.is_read boolValue]) {
                        [MessageListNetworkUtil setMarkMessageAsRead:model.identifier type:strongSelf.type block:^(NetworkData *networkData) {
                            // 更新數據源中的模型狀態
                            InteractionMessagesModel *sourceModel = [strongSelf.tableView.dataItems objectAtIndex:indexPath.row];
                            sourceModel.is_read = @"1";

                            // 延遲一秒更新 UI
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [strongSelf.tableView reloadData];
                            });
                        }];
                    }
                }
            }
        };
    }
    return _tableView;
}

- (void)getInteractionMessages {
    WeakSelf
    [MessageListNetworkUtil getMessageListByType: self.type page: self.tableView.pageIndex block:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        STRONGSELF
        if (!strongSelf) return;
        
        [MBProgressHUD hideHUD];
        
        // 安全地获取数据
        NSArray *datas = nil;
        if (networkData.info && [networkData.info isKindOfClass:[NSDictionary class]]) {
            id messages = networkData.info[@"messages"];
            if (messages) {
                datas = [InteractionMessagesModel arrayFromJson:messages];
            }
        }
        if (!datas) datas = @[];
        
        // 更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!strongSelf) return;
            
            [strongSelf.tableView vk_refreshFinish:datas];
            if (strongSelf->clearAllButton) {
                [strongSelf->clearAllButton setHidden:datas.count == 0];
            }
            if (strongSelf.noNewsView) {
                strongSelf.noNewsView.hidden = datas.count > 0;
            }
            
            // 检查是否需要显示滑动提示
            if (strongSelf.tableView.dataItems.count > 0 && 
                strongSelf.type && 
                ![strongSelf.type isEqualToString:@"system"] && [strongSelf.type isEqualToString:@"interaction"]) {
                [strongSelf performSelector:@selector(showSwipeHintForCell)
                                withObject:nil 
                                afterDelay:0.5];
            }
        });
    }];
}

- (void)getHomeMessageList {
    WeakSelf
    [MessageListNetworkUtil getMessageHome:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        STRONGSELF
        [MBProgressHUD hideHUD];
        NSArray<NewMessageListModel *> *datas = [NewMessageListModel arrayFromJson:networkData.info];
        strongSelf.noNewsView.hidden = datas.count > 0;
        [strongSelf.tableView vk_refreshFinish:datas];
    }];
}

// 模拟左滑删除并展示按钮
- (void)simulateSwipeToDeleteForRow:(NSIndexPath *)indexPath {
    InteractiveMessagesCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if (!cell) {
        return; // 确保 cell 存在
    }
    cell.deleteButton.hidden = NO;
    // 向左滑动以展示删除按钮
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = cell.frame;
        frame.origin.x -= 75; // 向左滑动的距离
        cell.frame = frame;
    } completion:^(BOOL finished) {
        // 在1.5秒后收回
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = cell.frame;
                frame.origin.x += 75; // 收回到原来的位置
                cell.frame = frame;
                cell.deleteButton.hidden = YES;
            }];
        });
    }];
}

// 第一次進來提示刪除功能
- (void)showSwipeHintForCell {
    // 获取是否需要显示滑动提示
#ifdef DEBUG
    if (!hasShownSwipe) {
        hasShownSwipe = YES;
#else
    BOOL hasShownSwipe = [[NSUserDefaults standardUserDefaults] boolForKey:kSwipeHintKey];
    if (!hasShownSwipe) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSwipeHintKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
#endif
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self simulateSwipeToDeleteForRow:indexPath];
    }
}
    
- (void)setupKeyboard {
    UIView *textFieldBg = [UIView new];
    textFieldBg.backgroundColor = vkColorRGBA(216, 215, 218, 0.8);
    [self.view addSubview:textFieldBg];
    [textFieldBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(self.view.bottom).offset(50);
    }];
    self.textFieldBg = textFieldBg;
    
    UITextField *commentTextField = [UITextField new];
    commentTextField.font = vkFont(14);
    commentTextField.textColor = UIColor.blackColor;
    commentTextField.layer.cornerRadius = 20;
    commentTextField.backgroundColor = [UIColor whiteColor];
    commentTextField.leftViewMode = UITextFieldViewModeAlways;
    commentTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    commentTextField.placeholder = YZMsg(@"short_video_comment_kindWordsBringGood");
    [textFieldBg addSubview:commentTextField];

    [commentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(textFieldBg).offset(14);
        make.height.mas_equalTo(40);
        make.centerY.mas_equalTo(textFieldBg);
    }];
    self.commentTextField = commentTextField;
    
    UIButton *sendButton = [UIButton new];
    sendButton.layer.cornerRadius = 20;
    sendButton.titleLabel.font = [UIFont systemFontOfSize:13];
    sendButton.backgroundColor = vkColorRGB(50.0f, 4.0f, 56.0f);
    [sendButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setTitle:YZMsg(@"short_video_comment_send") forState: UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendAciton:) forControlEvents:UIControlEventTouchUpInside];
    [textFieldBg addSubview:sendButton];
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(commentTextField.mas_trailing).offset(10);
        make.trailing.mas_equalTo(textFieldBg).inset(14);
        make.centerY.mas_equalTo(commentTextField.mas_centerY);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(60);
    }];
    self.sendButton = sendButton;
    
    // 添加键盘通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIView *keyboardMaskView = [UIView new];
    keyboardMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    keyboardMaskView.userInteractionEnabled = YES;
    [keyboardMaskView setHidden:YES];
    [self.view addSubview:keyboardMaskView];
    [keyboardMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(textFieldBg.mas_top);
    }];
    self.keyboardMaskView = keyboardMaskView;
    self.keyboardMaskView.layer.zPosition = 1000;
    self.textFieldBg.layer.zPosition = 1001;
}

- (void)sendAciton:(UIButton *)sender {
    NSString *commentString = self.commentTextField.text;
    if (commentString.length > 0) {
        WeakSelf
        [VideoCommentsNetworkUtil addShortVideoComment: self.reply_model.video_id comment_pid: self.reply_model.comment_id comment: commentString block:^(NetworkData *networkData) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (!networkData.status) {
                [MBProgressHUD showError:networkData.msg];
                strongSelf.reply_model = nil;
                strongSelf.commentTextField.placeholder = YZMsg(@"short_video_comment_kindWordsBringGood");
                return;
            }
            strongSelf.commentTextField.text = @"";
        }];
    }
    [self.commentTextField resignFirstResponder];
}
    
- (void)keyboardWillShow:(NSNotification *)notification {
    self.tableView.userInteractionEnabled = NO;
    [self.keyboardMaskView setHidden:NO];
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self.textFieldBg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).inset(keyboardHeight);
    }];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    self.tableView.userInteractionEnabled = YES;
    [self.keyboardMaskView setHidden:YES];
    if ([self.commentTextField.text isEqualToString:@""]) {
        self.reply_model = nil;
        self.commentTextField.placeholder = YZMsg(@"short_video_comment_kindWordsBringGood");
    }
    NSDictionary *userInfo = notification.userInfo;
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self.textFieldBg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(50); // 恢复到屏幕底部
    }];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - <InteractiveMessagesCellDelegate>
- (void)tapAvatarImageView:(NSString *)uid {
    if (self.type!= nil && [self.type isEqualToString:@"interaction"]) {
        otherUserMsgVC *person = [otherUserMsgVC new];
        person.userID = uid;
        [[MXBADelegate sharedAppDelegate] pushViewController:person animated:YES];
    }
}
    
 - (void)reply:(InteractionMessagesModel *)model indexPath:(NSIndexPath *)indexPath {
     self.reply_model = model;
     self.commentTextField.placeholder = [NSString stringWithFormat:@"%@ %@",YZMsg(@"short_video_comment_reply"), model.from_user_name];
     [self.commentTextField becomeFirstResponder];
 }
    
- (void)likeComment:(nonnull NSString *)comment_id isLike:(BOOL)isLike indexPath:(NSIndexPath *)indexPath {
    WeakSelf
    [VideoCommentsNetworkUtil getLikeComment:comment_id isLike:isLike block:^(NetworkData *networkData) {
        STRONGSELF
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        } else {
            InteractionMessagesModel* item = strongSelf.tableView.dataItems[indexPath.row];
            item.is_like = !item.is_like;
            [strongSelf.tableView reloadData];
        }
    }];
}
@end
