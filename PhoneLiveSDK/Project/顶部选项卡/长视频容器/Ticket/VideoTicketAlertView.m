//
//  VideoTicketAlertView.m
//  phonelive2
//
//  Created by vick on 2024/7/4.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoTicketAlertView.h"
#import "VideoTicketCardView.h"
#import <WebKit/WebKit.h>

@interface VideoTicketAlertView ()

@property (nonatomic, strong) VideoTicketCardView *leftTicketView;
@property (nonatomic, strong) VideoTicketCardView *rightTicketView;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation VideoTicketAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self loadListData];
    }
    return self;
}

- (VideoTicketCardView *)leftTicketView {
    if (!_leftTicketView) {
        _leftTicketView = [VideoTicketCardView new];
        _leftTicketView.backImgView.image = [ImageBundle imagewithBundleName:@"video_ticket_card1"];
        _leftTicketView.detailLabel.text = YZMsg(@"movie_time_expire");
        _leftTicketView.titleLabel.textColor = vkColorHex(0xFFFFFF);
        _leftTicketView.detailLabel.textColor = vkColorHex(0x713192);
        _leftTicketView.detailLabel.backgroundColor = vkColorHex(0xEBDAFA);
        _leftTicketView.priceLabel.textColor = vkColorHex(0x713192);
    }
    return _leftTicketView;
}

- (VideoTicketCardView *)rightTicketView {
    if (!_rightTicketView) {
        _rightTicketView = [VideoTicketCardView new];
        _rightTicketView.backImgView.image = [ImageBundle imagewithBundleName:@"video_ticket_card2"];
        _rightTicketView.detailLabel.text = YZMsg(@"movie_time_valid");
        _rightTicketView.titleLabel.textColor = vkColorHex(0x664208);
        _rightTicketView.detailLabel.textColor = vkColorHex(0xFFFFFF);
        _rightTicketView.detailLabel.backgroundColor = vkColorHex(0xBB925C);
        _rightTicketView.priceLabel.textColor = vkColorHex(0x664208);
    }
    return _rightTicketView;
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.backgroundColor = UIColor.whiteColor;
        [_webView vk_border:nil cornerRadius:10];
        
        // 設置默認的內邊距和樣式
        NSString *padding = @"document.body.style.padding='30px';";
        NSString *margin = @"document.body.style.margin='0px';";
        NSString *fontSize = @"document.body.style.fontSize='37px';";
        NSString *color = @"document.body.style.color='#4D4D4D';";
        NSString *lineHeight = @"document.body.style.lineHeight='1.3';";
        NSString *js = [NSString stringWithFormat:@"%@%@%@%@%@", padding, margin, fontSize, color, lineHeight];
        WKUserScript *script = [[WKUserScript alloc] initWithSource:js
                                                    injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                 forMainFrameOnly:YES];
        [_webView.configuration.userContentController addUserScript:script];
    }
    return _webView;
}

- (void)setupView {
    self.backgroundColor = vkColorHex(0xEAE7EE);
    self.layer.cornerRadius = 10;
    self.layer.maskedCorners = kCALayerMinXMinYCorner|kCALayerMaxXMinYCorner;
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VK_SCREEN_W);
        make.height.mas_equalTo(VK_BOTTOM_H+VKPX(400));
    }];
    
    [self addSubview:self.leftTicketView];
    [self.leftTicketView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(10);
        make.height.mas_equalTo(VKPX(80));
    }];
    
    [self addSubview:self.rightTicketView];
    [self.rightTicketView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.width.height.mas_equalTo(self.leftTicketView);
        make.left.mas_equalTo(self.leftTicketView.mas_right).offset(0);
        make.right.mas_equalTo(-10);
    }];
    
    [self addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(self.leftTicketView.mas_bottom).offset(10);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)loadListData {
    WeakSelf
    [LotteryNetworkUtil getVideoTicketsBlock:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (networkData.status) {
            NSArray *tickets = networkData.data[@"ticket"];
            NSNumber *total = [tickets valueForKeyPath:@"@sum.ticket_count"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTicket_count" object:total];
            NSString *desc = networkData.data[@"desc"];
            [Config setVideoTickets:tickets];
            LiveUser *user = [Config myProfile];
            user.coin = minstr(networkData.data[@"coin"]);
            [Config updateProfile:user];
            
            NSArray *limits = [tickets filterBlock:^BOOL(id object) {
                return [object[@"expire_time"] integerValue] > 0;
            }];
            NSNumber *limitValue = [limits valueForKeyPath:@"@sum.ticket_count"];
            NSMutableAttributedString *limitText = [NSMutableAttributedString new];
            [limitText vk_appendString:limitValue.stringValue color:vkColorHex(0x713192) font:vkFont(28)];
            [limitText vk_appendString:YZMsg(@"movie_ticket_unit") color:vkColorHex(0x713192) font:vkFont(10)];
            strongSelf.leftTicketView.priceLabel.attributedText = limitText;
            
            NSArray *forevers = [tickets filterBlock:^BOOL(id object) {
                return [object[@"expire_time"] integerValue] <= 0;
            }];
            NSNumber *foreverValue = [forevers valueForKeyPath:@"@sum.ticket_count"];
            NSMutableAttributedString *foreverText = [NSMutableAttributedString new];
            [foreverText vk_appendString:foreverValue.stringValue color:vkColorHex(0x664208) font:vkFont(28)];
            [foreverText vk_appendString:YZMsg(@"movie_ticket_unit") color:vkColorHex(0x664208) font:vkFont(10)];
            strongSelf.rightTicketView.priceLabel.attributedText = foreverText;
            
            // 包裝 HTML 內容
            NSString *htmlContent = [NSString stringWithFormat:@"<html><body>%@</body></html>", desc];
            [strongSelf.webView loadHTMLString:htmlContent baseURL:nil];
        }
    }];
}

@end
