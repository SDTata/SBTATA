//
//  VideoCommentsView.m
//  phonelive2
//
//  Created by user on 2024/7/18.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoCommentsView.h"
#import "VideoCommentsNetworkUtil.h"
#import "VideoCommentsModel.h"
#import "VideoCommentsTableViewCell.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <LEEAlert/LEEAlert.h>
#import <UMCommon/UMCommon.h>

@interface VideoCommentsView ()<UITableViewDataSource, UITableViewDelegate, VideoCommentsCellDelegate>
@property (nonatomic, strong) UILabel *commentCountLabel;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) UILabel *noDataSubLabel;
@property (nonatomic, strong) NSMutableArray<VideoCommentsModel *> *datas;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSIndexPath *reply_indexPath;
@property (nonatomic, strong) id reply_model;
@property (nonatomic, strong) UIView *keyboardMaskView;
@property (nonatomic, copy) NSString *previousVideo_id; // 前一则video_id，比对是否切换视频了
@property(nonatomic, assign) BOOL hasMore;
// 在類中添加一個屬性用於存儲唯一標識集合
@property (nonatomic, strong) NSMutableSet<NSString *> *processedCommentIds;
@end

@implementation VideoCommentsView

- (void)dealloc {
    // 移除键盘通知监听
    self.focus_comment_indexPath = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.pid = @"0";
        self.page = 1;
        self.datas = [NSMutableArray new];
        self.processedCommentIds = [NSMutableSet set];
        [self setupViews];
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
    super.hidden = hidden;
    [IQKeyboardManager sharedManager].enable = hidden;
    [IQKeyboardManager sharedManager].enableAutoToolbar = hidden;
    [self endEditing: hidden];
    [self.commentTextField resignFirstResponder];
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = vkColorHex(0xEAE7EE);
    self.layer.cornerRadius = 20;
    self.layer.masksToBounds = YES;
    self.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    
    
    UIImageView *topIndicator = [UIImageView new];
    topIndicator.image = [ImageBundle imagewithBundleName:@"home_search_indicator"];
    [self addSubview:topIndicator];
    [topIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(14);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(4);
    }];
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 20;
    bgView.layer.masksToBounds = YES;
    
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topIndicator.mas_top).offset(14);
        make.leading.trailing.mas_equalTo(self).inset(14);
    }];
    
    UILabel *commentCountLabel = [UILabel new];
    commentCountLabel.textColor = [UIColor blackColor];
    commentCountLabel.font =  [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    commentCountLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:commentCountLabel];
    [commentCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView.mas_top).offset(14);
        make.leading.trailing.mas_equalTo(self).inset(14);
        make.height.mas_lessThanOrEqualTo(40);
    }];
    self.commentCountLabel = commentCountLabel;
    
    UILabel *noDataLabel = [UILabel new];
    noDataLabel.textColor = [UIColor blackColor];
    noDataLabel.font =  [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    noDataLabel.hidden = YES;
    noDataLabel.text = YZMsg(@"short_video_comment_lookingForwardYourComments");
    [bgView addSubview:noDataLabel];
    [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView);
        make.centerY.mas_equalTo(bgView).inset(20);
    }];
    self.noDataLabel = noDataLabel;
    
    UILabel *noDataSubLabel = [UILabel new];
    noDataSubLabel.textColor = [UIColor lightGrayColor];
    noDataSubLabel.font =  [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    noDataSubLabel.textAlignment = NSTextAlignmentCenter;
    noDataSubLabel.hidden = YES;
    noDataSubLabel.text = YZMsg(@"short_video_comment_leaveCommentExpressYourThoughts");
    [bgView addSubview:noDataSubLabel];
    [noDataSubLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView);
        make.top.mas_equalTo(noDataLabel.mas_bottom);
    }];
    self.noDataSubLabel = noDataSubLabel;
    
    _tableView = [[VKBaseTableView alloc]initWithFrame: CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 110.0f;
    _tableView.sectionHeaderHeight = 30.0f;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.registerCellClass = [VideoCommentsTableViewCell class];
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    _tableView.mj_footer = footer;
    [footer setTitle:YZMsg(@"public_loadMore_loading") forState:MJRefreshStateRefreshing];
    [footer setTitle:YZMsg(@"short_video_comment_noMoreComments") forState:MJRefreshStateIdle];
    [footer setTitle:YZMsg(@"short_video_comment_noMoreComments") forState:MJRefreshStateNoMoreData];
    footer.stateLabel.font = [UIFont systemFontOfSize:15.0f];
    [bgView addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(commentCountLabel.mas_bottom).offset(10);
        make.leading.trailing.mas_equalTo(self).inset(14);
        make.bottom.mas_equalTo(bgView).inset(16);
    }];
    
    
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        
    }
    
    UITextField *commentTextField = [UITextField new];
    commentTextField.font = vkFont(14);
    commentTextField.textColor = UIColor.blackColor;
    commentTextField.layer.cornerRadius = 20;
    commentTextField.backgroundColor = [UIColor whiteColor];
    commentTextField.leftViewMode = UITextFieldViewModeAlways;
    commentTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    commentTextField.placeholder = YZMsg(@"short_video_comment_kindWordsBringGood");
    [self addSubview:commentTextField];
    CGFloat bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    bottom = bottom == 0 ? 10 : bottom;
    [commentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).offset(14);
        make.top.mas_equalTo(bgView.mas_bottom).offset(10);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self).inset(bottom);
    }];
    self.commentTextField = commentTextField;
    
    UIButton *sendButton = [UIButton new];
    sendButton.layer.cornerRadius = 20;
    sendButton.titleLabel.font = [UIFont systemFontOfSize:13];
    sendButton.backgroundColor = vkColorRGB(50.0f, 4.0f, 56.0f);
    [sendButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setTitle:YZMsg(@"short_video_comment_send") forState: UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendAciton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton];
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(commentTextField.mas_trailing).offset(10);
        make.trailing.mas_equalTo(self).inset(14);
        make.centerY.mas_equalTo(commentTextField.mas_centerY);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(60);
    }];
    self.sendButton = sendButton;
    
    // 添加键盘通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIView *keyboardMaskView = [UIView new];
    keyboardMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [keyboardMaskView setHidden:YES];
    [self addSubview:keyboardMaskView];
    [keyboardMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(commentTextField.mas_top).inset(10);
    }];
    self.keyboardMaskView = keyboardMaskView;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self.keyboardMaskView setHidden:NO];
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 更新 commentTextField 的约束并进行动画调整
    [self.commentTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).inset(keyboardHeight + 10); // 距离键盘上方10
    }];
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
    }];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    if ([self.commentTextField.text isEqualToString:@""]) {
        self.pid = @"0";
        self.reply_model = nil;
        self.commentTextField.placeholder = YZMsg(@"short_video_comment_kindWordsBringGood");
    }
    [self.keyboardMaskView setHidden:YES];
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    NSDictionary *userInfo = notification.userInfo;
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    bottom = bottom == 0 ? 10 : bottom;
    [self.commentTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).inset(bottom); // 恢复到屏幕底部
    }];
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)sendAciton:(UIButton *)sender {
    NSString *commentString = self.commentTextField.text;
    if (commentString.length > 0) {
        [self.noDataLabel setHidden:YES];
        [self.noDataSubLabel setHidden:YES];
        int totalCount = [self.comments_count intValue];
        totalCount += 1;
        self.comments_count = [NSString stringWithFormat: @"%i", totalCount];
        self.commentCountLabel.text = [NSString stringWithFormat: @"%@%@", self.comments_count, YZMsg(@"short_video_comment_howManyComments")];
        WeakSelf
        [VideoCommentsNetworkUtil addShortVideoComment: self.video_id comment_pid: self.pid comment: commentString block:^(NetworkData *networkData) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (!networkData.status) {
                [MBProgressHUD showError:networkData.msg];
                strongSelf.pid = @"0";
                strongSelf.reply_model = nil;
                strongSelf.commentTextField.text = @"";
                strongSelf.commentTextField.placeholder = YZMsg(@"short_video_comment_kindWordsBringGood");
                return;
            }
            if (strongSelf.reply_model == nil) {
                NSDictionary *newComment = networkData.info[@"new_comment"];
                NSMutableDictionary *newReply = [[NSMutableDictionary alloc] init];
                newReply[@"id"] = newComment[@"id"];
                newReply[@"is_like"] = @NO;
                newReply[@"like_count"] = @"0";
                newReply[@"video_id"] = newComment[@"video_id"];
                newReply[@"replies"] = @[];
                newReply[@"parent_id"] = newComment[@"parent_id"];
                newReply[@"top_parent_id"] = newComment[@"top_parent_id"];
                newReply[@"uid"] = newComment[@"uid"];
                newReply[@"username"] = [Config getOwnNicename];
                newReply[@"avatar"] = [Config getavatar];
                newReply[@"comment"] = newComment[@"comment"];
                newReply[@"create_time"] = newComment[@"create_time"];
                
                VideoCommentsModel *model = [VideoCommentsModel modelFromJSON:newReply];
                [strongSelf.datas insertObject: model atIndex:0];
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                // 在插入行之前确保 tableView 的 section 数量是正确的
                if ([strongSelf.tableView numberOfSections] != [strongSelf.datas count]) {
                    [strongSelf.tableView reloadData];  // 重新加载数据以避免崩溃
                } else {
                    [strongSelf.tableView beginUpdates];
                    [strongSelf.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [strongSelf.tableView endUpdates];
                }
                // 滚动到新行的位置
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                });
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadComment" object:@{@"commentCount": minnum(strongSelf.datas.count)}];
            }
            strongSelf.pid = @"0";
            strongSelf.reply_model = nil;
        }];
        [self.commentTextField resignFirstResponder];
        self.commentTextField.text = @"";
        self.commentTextField.placeholder = YZMsg(@"short_video_comment_kindWordsBringGood");
        self.page = 1;
        
        NSIndexPath *indexPath = self.reply_indexPath;
        if (indexPath && self.reply_model) {
            NSString *commentID;
            NSString *to_user_avatar;
            NSString *to_user_uid;
            NSString *to_user_username;
            if ([self.reply_model isKindOfClass:[VideoCommentsModel class]]) {
                commentID = ((VideoCommentsModel *)self.reply_model).identifier;
                to_user_avatar = ((VideoCommentsModel *)self.reply_model).avatar;
                to_user_uid = ((VideoCommentsModel *)self.reply_model).uid;
                to_user_username = ((VideoCommentsModel *)self.reply_model).username;
            } else {
                commentID = ((VideoCommentsReply *)self.reply_model).identifier;
                to_user_avatar = ((VideoCommentsReply *)self.reply_model).avatar;
                to_user_uid = ((VideoCommentsReply *)self.reply_model).uid;
                to_user_username = ((VideoCommentsReply *)self.reply_model).username;
            }
            // 获取当前时间并格式化为所需的日期格式
            NSDate *now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *currentDateString = [dateFormatter stringFromDate:now];
            // 创建新回复对象
            NSMutableDictionary *newReply = [[NSMutableDictionary alloc] init];
            newReply[@"id"] = commentID;
            newReply[@"is_like"] = false;
            newReply[@"like_count"] = @"0";
            newReply[@"video_id"] = @"";
            newReply[@"parent_id"] = commentID;
            newReply[@"uid"] = [Config getOwnID];  // 设置新回复的唯一标识符
            newReply[@"username"] = [Config getOwnNicename];   // 设置新回复的用户名
            newReply[@"avatar"] = [Config getavatar];
            newReply[@"comment"] = commentString; // 设置新回复的内容
            newReply[@"create_time"] = currentDateString; // 当前时间
            newReply[@"to_user"] = @{@"avatar": to_user_avatar,
                                     @"uid":to_user_uid,
                                     @"username": to_user_username};
            // 获取当前的评论对象
            VideoCommentsModel *comment = self.datas[indexPath.section];
            if (!comment.isExpanded) {
                comment.isExpanded = YES;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            // 在数据源中插入新回复
            NSMutableArray *replies = [comment.replies mutableCopy];
            [replies addObject:[newReply copy]];
            comment.replies = [replies copy];
            
            // 确定新行的位置
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:comment.replies.count inSection:indexPath.section];
            
            // 更新数据源并插入新行
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
            // 滚动到新行的位置
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:comment.replies.count - 1 inSection:indexPath.section];
                // 前一笔的收起要刷新才会隐藏
                [self.tableView reloadRowsAtIndexPaths: @[previousIndexPath] withRowAnimation: UITableViewRowAnimationNone];
            });
            [MobClick event:@"shortvideo_comment_replay_click" attributes:@{ @"eventType": @(1)}];
        } else {
            [MobClick event:@"shortvideo_comment_video_click" attributes:@{ @"eventType": @(1)}];
        }
    }
}

- (void)resetTemp {
    self.pid = @"0";
    self.reply_model = nil;
    self.commentTextField.placeholder = YZMsg(@"short_video_comment_kindWordsBringGood");
    [self.datas removeAllObjects];
    [self.tableView reloadData];
    [self.tableView.mj_footer setHidden:YES];
    [self.processedCommentIds removeAllObjects];
    self.hasMore = YES;
}

- (void)loadlistData {
    self.commentCountLabel.text = [NSString stringWithFormat: @"%@%@", self.comments_count, YZMsg(@"short_video_comment_howManyComments")];
    if (self.video_id) {
        if (self.page == 1 || ![self.previousVideo_id isEqualToString:self.video_id]) {
            // 重新打开评论或是已经切换视频
            [self resetTemp];
        }
        if (!self.hasMore) {
            [self.tableView.mj_footer endRefreshing];
            return;
        }
        WeakSelf
        [VideoCommentsNetworkUtil getShortVideoComment:self.video_id
                                             messageId:self.message_id
                                                  page:self.page
                                                 block:^(NetworkData *networkData) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf.tableView.mj_footer endRefreshing];
            if (!networkData.status) {
                [MBProgressHUD showError:networkData.msg];
                return;
            }
            
            NSArray<VideoCommentsModel *> *fetchedData = [VideoCommentsModel arrayFromJson:networkData.info];
            if (fetchedData.count > 0) {
                NSMutableArray<VideoCommentsModel *> *filteredData = [NSMutableArray array];
                
                // 過濾已存在的評論數據
                for (VideoCommentsModel *comment in fetchedData) {
                    if (![strongSelf.processedCommentIds containsObject:comment.identifier]) {
                        [filteredData addObject:comment];
                        [strongSelf.processedCommentIds addObject:comment.identifier];
                    }
                }
                
                if (filteredData.count > 0) {
                    strongSelf.page += 1;
                    strongSelf.hasMore = filteredData.count >= 10;
                    [strongSelf.datas addObjectsFromArray:filteredData];
                    [strongSelf.tableView.mj_footer setHidden:NO];
                    [strongSelf.noDataLabel setHidden:YES];
                    [strongSelf.noDataSubLabel setHidden:YES];
                }
            }
            
            if (fetchedData.count == 0 && strongSelf.datas.count == 0) {
                strongSelf.hasMore = NO;
                [strongSelf.tableView.mj_footer setHidden:YES];
                [strongSelf.noDataLabel setHidden:NO];
                [strongSelf.noDataSubLabel setHidden:NO];
            } else if (fetchedData.count == 0) {
                strongSelf.hasMore = NO;
                [strongSelf.tableView.mj_footer setHidden:NO];
            }
            
            [strongSelf.tableView vk_refreshFinish:strongSelf.datas];
            strongSelf.previousVideo_id = strongSelf.video_id;
        }];
    }
}

-(void)refreshFooter {
    [self loadlistData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    VideoCommentsModel *comment = self.datas[section];
    if (self.focus_comment_id) {
        for (NSUInteger i = 0; i < comment.replies.count; i++) {
            VideoCommentsReply *other = [VideoCommentsReply modelFromJSON:comment.replies[i]];
            if ([other.identifier isEqualToString:self.focus_comment_id]) {
                comment.isExpanded = YES; // 互动消息回覆的子评论在该评论底下则直接打开
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+1 inSection:section];
                self.focus_comment_indexPath = indexPath;
            }
        }
    }
    return comment.isExpanded ? comment.replies.count + 1 : 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VideoCommentsModel *comment = self.datas[indexPath.section];
    if (indexPath.row == 0) {
        VideoCommentsTableViewCell *cell = [[VideoCommentsTableViewCell alloc] initWithData:comment style:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%ldIndexcell",(long)indexPath.section]];
        cell.delegate = self;
        cell.indexPath = indexPath;
        [cell updateData];
        return cell;
    } else {
        VideoCommentsReply *subComment = [VideoCommentsReply modelFromJSON: comment.replies[indexPath.row - 1]];
        NSString *parentID = subComment.parent_id;
        if ([parentID isEqualToString:comment.identifier]) { // 直接回覆评论
            subComment.to_user.username = @"";
        } else {
            for (NSDictionary *dic in comment.replies) { // 在评论里回复别人的评论
                VideoCommentsReply *other = [VideoCommentsReply modelFromJSON: dic];
                if ([other.identifier isEqualToString:parentID]) {
                    subComment.to_user.uid = other.to_user.uid;
                    subComment.to_user.avatar = other.to_user.avatar;
                    subComment.to_user.username = [NSString stringWithFormat:@" ▶ %@", other.to_user.username];
                }
            }
        }
        subComment.isExpandedLast = comment.replies.count == indexPath.row;
        VideoCommentsTableViewCell *cell = [[VideoCommentsTableViewCell alloc] initWithData:subComment style:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%ldIndexcell",(long)indexPath.row - 1]];
        cell.delegate = self;
        cell.indexPath = indexPath;
        [cell updateData];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSSet *visibleSections = [NSSet setWithArray:[[tableView indexPathsForVisibleRows] valueForKey:@"section"]];
    if (visibleSections) {
        if (self.focus_comment_id && self.message_id) {
            WeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                if (strongSelf.tableView.numberOfSections > 0) {
                    [strongSelf.tableView scrollToRowAtIndexPath:strongSelf.focus_comment_indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    self.focus_comment_id = nil;
                }
            });
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [MobClick event:@"shortvideo_comment_detail_click" attributes:@{ @"eventType": @(1)}];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0) {
        self.tableView.contentOffset = CGPointMake(0, 0);
    }
}

#pragma mark - UITableViewDelegate
// 左滑删除操作的权限控制
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoCommentsModel *model = self.datas[indexPath.section];
    // 如果是根评论，直接检查评论者的uid
    if (indexPath.row == 0) {
        return self.isVideoOwner || ([model.uid isEqualToString:[Config getOwnID]] && ![model.deleted boolValue]);
    } else {
        // 如果是子评论，检查回复者的uid
        VideoCommentsReply *reply = [VideoCommentsReply modelFromJSON: model.replies[indexPath.row - 1]];// model.replies[indexPath.row - 1];
        return self.isVideoOwner || ([reply.uid isEqualToString:[Config getOwnID]] && ![model.deleted boolValue]);
    }
}

// 左滑删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    WeakSelf
    VideoCommentsModel *model = self.datas[indexPath.section];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [LEEAlert actionsheet].config
            .LeeTitle(YZMsg(@"BetCell_remove"))
            .LeeContent(model.comment)
            .LeeDestructiveAction(YZMsg(@"publictool_sure"), ^{
                STRONGSELF
                if (!strongSelf) return;
                if (indexPath.row == 0) { // 根评论
                    [VideoCommentsNetworkUtil deleteComment:model.identifier block:^(NetworkData *networkData) {
                        if (!networkData.status) {
                            [MBProgressHUD showError:networkData.msg];
                            return;
                        }
                    }];
                    [strongSelf.datas removeObjectAtIndex:indexPath.section];
                    [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadComment" object:@{@"commentCount": minnum(strongSelf.datas.count)}];
                } else { // 子评论
                    if (model.replies.count >= indexPath.row - 1) {
                        NSString *commentId = nil;
                        if ([model.replies[indexPath.row - 1] isKindOfClass:[NSDictionary class]]) {
                            VideoCommentsReply *item = [VideoCommentsReply modelFromJSON: model.replies[indexPath.row - 1]];
                            commentId = item.identifier;
                        } else {
                            commentId = model.replies[indexPath.row - 1].identifier;
                        }
                        [VideoCommentsNetworkUtil deleteComment:commentId block:^(NetworkData *networkData) {
                            if (!networkData.status) {
                                [MBProgressHUD showError:networkData.msg];
                                return;
                            }
                        }];
                        [model.replies removeObjectAtIndex:indexPath.row - 1];
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }
                [MobClick event:@"shortvideo_comment_delete_click" attributes:@{ @"eventType": @(1)}];
            })
            .LeeAddAction(^(LEEAction *action) {
                action.type = LEEActionTypeCancel;
                action.title = YZMsg(@"public_cancel");
                action.titleColor = [UIColor blackColor];
                action.font = [UIFont systemFontOfSize:18.0f];
            })
            .LeeActionSheetCancelActionSpaceColor([UIColor colorWithWhite:0.92 alpha:1.0f])
            .LeeActionSheetBottomMargin(0.0f)
            .LeeCornerRadii(CornerRadiiMake(10, 10, 0, 0))
            .LeeActionSheetHeaderCornerRadii(CornerRadiiZero())
            .LeeActionSheetCancelActionCornerRadii(CornerRadiiZero())
            .LeeConfigMaxWidth(^CGFloat(LEEScreenOrientationType type, CGSize size) {
                return size.width;
            })
            .LeeActionSheetBackgroundColor([UIColor whiteColor])
#ifdef __IPHONE_13_0
            .LeeUserInterfaceStyle(UIUserInterfaceStyleLight)
#endif
            .LeeShow();
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YZMsg(@"BetCell_remove");
}

#pragma mark - VideoCommentsCellDelegate
// 评论回复
- (void)reply:(id)model indexPath:(nonnull NSIndexPath *)indexPath {
    self.reply_model = model;
    if ([model isKindOfClass:[VideoCommentsModel class]]) {
        self.pid = ((VideoCommentsModel *)model).identifier;
        self.commentTextField.placeholder = [NSString stringWithFormat:@"%@ %@",YZMsg(@"short_video_comment_reply"), ((VideoCommentsModel *)model).username];
    } else {
        self.pid = ((VideoCommentsReply *)model).identifier;
        self.commentTextField.placeholder = [NSString stringWithFormat:@"%@ %@",YZMsg(@"short_video_comment_reply"), ((VideoCommentsReply *)model).username];
    }
    
    [self.commentTextField becomeFirstResponder];
    
    if (indexPath) {
        self.reply_indexPath = indexPath;
        // 这里使用dispatch_after确保在键盘弹出后进行滚动操作
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    }
}

// 评论点赞
- (void)likeComment:(NSString *)videoId isLike:(BOOL)isLike {
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"like": isLike ? @(1) : @(0)};
    [MobClick event:@"shortvideo_comment_detail_click" attributes:dict];
    [VideoCommentsNetworkUtil getLikeComment:videoId isLike:isLike block:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
    }];
}
// 评论展开收合
- (void)commentCellDidTapExpandMore:(VideoCommentsTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        VideoCommentsModel *comment = self.datas[indexPath.section];
        comment.isExpanded = !comment.isExpanded;
        
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}
// 点击头像
- (void)tapAvatarImageView:(NSString *)uid {
    [self.delelgate tapAvatarImageView:uid];
}
// 点击用户名称
- (void)tapUserName:(NSString *)uid {
    [self.delelgate tapUserName:uid];
}
@end
