//
//  OBSViewController.m
//  phonelive2
//
//  Created by s5346 on 2023/12/27.
//  Copyright © 2023 toby. All rights reserved.
//

#import "OBSViewController.h"
#import "LiveGifImage.h"
@interface OBSViewController () {
    // OBS server
    UILabel *serverValueLabel;
    // OBS 串流密鑰
    UILabel *streamingValueLabel;
    int selectCopyLabel;
}
@end

@implementation OBSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)dealloc {
    NSLog(@">>>OBSViewController release");
}

#pragma maek - private
- (void)sendPushStream:(NSString*)pushString {
    streamingValueLabel.text = [self getEncryptPullStream:pushString];
}

- (void)setupViews {
    self.view.backgroundColor = [UIColor blackColor];
    WeakSelf;
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.image = [ImageBundle imagewithBundleName:@"sy_bj"];
    [self.view addSubview:backgroundImageView];
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];

    UIButton *backIcon = [[UIButton alloc] init];
    [backIcon setTitle:YZMsg(@"AddWithDrawType_cancel") forState:UIControlStateNormal];
    [backIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backIcon addTarget:self action:@selector(stopOBS) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backIcon];
    [backIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(weakSelf.view).offset(20);
        make.height.equalTo(@44);
        make.width.greaterThanOrEqualTo(@44);
    }];

    NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"xiaohuojiananimation" ofType:@"gif"];
    YYAnimatedImageView *rocketView = [[YYAnimatedImageView alloc]init];
    LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
    [imgAnima setAnimatedImageLoopCount:0];
    rocketView.image = imgAnima;
    rocketView.runloopMode = NSRunLoopCommonModes;
    rocketView.animationRepeatCount = 0;
    [rocketView startAnimating];
    [self.view addSubview:rocketView];

    [rocketView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backIcon.mas_bottom).offset(-20);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@AD(200));
        make.width.equalTo(@AD(200));
    }];

    // "要使用其他应用程序进行直播推流\n请在应用程序中输入下述\n服务器网址和推流密钥"
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.numberOfLines = 3;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = YZMsg(@"Livebroadcast_title_OBS_stream_info");
    [self.view addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rocketView.mas_bottom).offset(AD(-30));
        make.left.right.equalTo(weakSelf.view);
    }];

    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    stackView.layer.cornerRadius = 10;
    stackView.layer.masksToBounds = true;
    [self.view addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipLabel.mas_bottom).offset(20);
        make.left.right.equalTo(weakSelf.view).inset(10);
    }];

    UIView *serverView = [[UILabel alloc] init];
    serverView.userInteractionEnabled = true;
    [stackView addArrangedSubview:serverView];

    UIButton *serverCopyButton = [[UIButton alloc] init];
    [serverCopyButton setImage:[ImageBundle imagewithBundleName:@"img_copy"] forState:UIControlStateNormal];
    [serverCopyButton addTarget:self action:@selector(copyServer) forControlEvents:UIControlEventTouchUpInside];
    [serverView addSubview:serverCopyButton];
    [serverCopyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(22));
        make.height.equalTo(@(23));
        make.right.equalTo(serverView).offset(-20);
        make.bottom.equalTo(serverView).offset(-12);
    }];

    // 伺服器
    UILabel *serverTipLabel = [[UILabel alloc] init];
    serverTipLabel.textColor = [UIColor whiteColor];
    serverTipLabel.text = YZMsg(@"Livebroadcast_title_server");
    [serverView addSubview:serverTipLabel];
    [serverTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(serverView).offset(12);
        make.left.right.equalTo(serverView).inset(12);
    }];

    serverValueLabel = [[UILabel alloc] init];
    serverValueLabel.userInteractionEnabled = true;
    serverValueLabel.numberOfLines = 0;
    serverValueLabel.textColor = RGB_COLOR(@"#77C8D2", 1);
    serverValueLabel.text = @"rtmp://127.0.0.1/liveobs/";
    [serverView addSubview:serverValueLabel];
    [serverValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(serverTipLabel.mas_bottom).offset(8);
        make.left.equalTo(serverTipLabel.mas_left);
        make.right.equalTo(serverCopyButton.mas_left).offset(-8);
    }];

    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    [serverView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(serverValueLabel.mas_bottom).offset(8);
        make.left.right.equalTo(serverView).inset(8);
        make.height.equalTo(@1);
        make.bottom.equalTo(serverView);
    }];

    UIView *streamingView = [[UIView alloc] init];
    [stackView addArrangedSubview:streamingView];

    UIButton *streamingCopyButton = [[UIButton alloc] init];
    [streamingCopyButton setImage:[ImageBundle imagewithBundleName:@"img_copy"] forState:UIControlStateNormal];
    [streamingCopyButton addTarget:self action:@selector(copyStream) forControlEvents:UIControlEventTouchUpInside];
    [streamingView addSubview:streamingCopyButton];
    [streamingCopyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(22));
        make.height.equalTo(@(23));
        make.right.equalTo(streamingView).offset(-20);
        make.bottom.equalTo(streamingView).offset(-12);
    }];

    // 串流金鑰
    UILabel *streamTipView = [[UILabel alloc] init];
    streamTipView.textColor = [UIColor whiteColor];
    streamTipView.text = YZMsg(@"Livebroadcast_title_stream");
    [streamingView addSubview:streamTipView];
    [streamTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(streamingView).offset(12);
        make.left.right.equalTo(streamingView).inset(12);
    }];

    streamingValueLabel = [[UILabel alloc] init];
    streamingValueLabel.userInteractionEnabled = true;
    streamingValueLabel.numberOfLines = 0;
    streamingValueLabel.minimumScaleFactor = 0.5;
    streamingValueLabel.adjustsFontSizeToFitWidth = true;
    streamingValueLabel.textColor = RGB_COLOR(@"#77C8D2", 1);
    streamingValueLabel.text = @"";
    [streamingView addSubview:streamingValueLabel];
    [streamingValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(streamTipView.mas_bottom);
        make.left.equalTo(streamTipView.mas_left);
        make.right.equalTo(serverCopyButton.mas_left).offset(-8);
        make.bottom.equalTo(streamingView).offset(-8);
        make.height.equalTo(@AD(80));
    }];

    [streamingValueLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];

    // 開始直播
    UIButton *startLiveBtn = [UIButton buttonWithType:0];
    startLiveBtn.layer.cornerRadius = 25.0;
    startLiveBtn.layer.masksToBounds = YES;
    [startLiveBtn setBackgroundColor:RGB_COLOR(@"#EE71CE", 1)];
    [startLiveBtn addTarget:self action:@selector(startOBS) forControlEvents:UIControlEventTouchUpInside];
    [startLiveBtn setTitle:YZMsg(@"Livebroadcast_title_start_stream") forState:0];
    startLiveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:startLiveBtn];
    [startLiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view).inset(10);
        make.height.equalTo(@50);
        make.bottom.equalTo(weakSelf.view).offset(-AD(100));
    }];

    // 当您开始推流后，极客点击下方的“开始直播”按钮。
    UILabel *tipOBSLabel = [[UILabel alloc] init];
    tipOBSLabel.textColor = [UIColor whiteColor];
    tipOBSLabel.font = [UIFont systemFontOfSize:14];
    tipOBSLabel.numberOfLines = 0;
    tipOBSLabel.text = YZMsg(@"Livebroadcast_title_start_stream_info");
    tipOBSLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipOBSLabel];
    [tipOBSLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view).inset(10);
        make.bottom.equalTo(startLiveBtn.mas_top).offset(-4);
        make.top.greaterThanOrEqualTo(stackView.mas_bottom).offset(20);
    }];

    UILongPressGestureRecognizer *longPressServer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    [serverValueLabel addGestureRecognizer:longPressServer];
    UILongPressGestureRecognizer *longPressStream = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    [streamingValueLabel addGestureRecognizer:longPressStream];
}

- (void)copyServer {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:serverValueLabel.text];
    [MBProgressHUD showError:YZMsg(@"publictool_copy_success")];
}

- (void)copyStream {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:streamingValueLabel.text];
    [MBProgressHUD showError:YZMsg(@"publictool_copy_success")];
}

- (NSString*)getEncryptPullStream:(NSString*)originalString {
    NSString *zhubID = [Config getOwnID] != nil ? [Config getOwnID] : @"";
    NSString *randomEnCodeStr = [[YBToolClass sharedInstance].dicForKeyPlay objectForKey:minnum(zhubID)];
    if([YBToolClass sharedInstance].dicForKeyPlay== nil ||[PublicObj checkNull:randomEnCodeStr]){
        randomEnCodeStr = [[RandomRule randomWithColumn:4 Line:4 seeds:[zhubID integerValue] others:nil] substringToIndex:16];
        if([YBToolClass sharedInstance].dicForKeyPlay== nil ){
            [YBToolClass sharedInstance].dicForKeyPlay = [NSMutableDictionary dictionary];
        }

        [[YBToolClass sharedInstance].dicForKeyPlay setObject:minnum(zhubID) forKey:randomEnCodeStr];
    }
    originalString =  [originalString stringByAppendingFormat:@"?password=%@",randomEnCodeStr];

    NSData *dataToEncode = [originalString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedString = [dataToEncode base64EncodedStringWithOptions:0];

    base64EncodedString = [base64EncodedString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];

    // Split, reverse and concatenate
    NSUInteger middle = floor( [base64EncodedString length] / 2);
    NSString *firstHalf = [base64EncodedString substringToIndex:middle];
    NSString *secondHalf = [base64EncodedString substringFromIndex:[base64EncodedString length] - middle];
    NSMutableString *reversedString = [NSMutableString stringWithString:[[firstHalf reverseString] stringByAppendingString:[secondHalf reverseString]]];
    return reversedString;
}

- (void)startOBS {
    [self dismissViewControllerAnimated:false completion:nil];
    [self.delegate oBSViewControllerForStart];
}

- (void)stopOBS {
    [self dismissViewControllerAnimated:false completion:nil];
    [self.delegate oBSViewControllerForCancel];
}

- (void)showMenu:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        if (sender.view == serverValueLabel) {
            selectCopyLabel = 1;
        } else if (sender.view == streamingValueLabel) {
            selectCopyLabel = 2;
        }
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:sender.view.bounds inView:sender.view];
        [menu setMenuVisible:true animated:true];
    }
}

#pragma make - UIMenuController
- (BOOL)canBecomeFirstResponder {
    return true;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
        return true;
    }
    return false;
}

- (void)copy:(UIMenuController*)sender {
    switch (selectCopyLabel) {
        case 1:
            [self copyServer];
            break;
        case 2:
            [self copyStream];
            break;
        default:
            break;
    }
}

@end
