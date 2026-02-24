//
//  MoreAlertView.h
//  phonelive2
//
//  Created by Co co on 2024/2/28.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef void (^FinishBlocks)(void);

@interface MoreAlertView : UIView



@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy)FinishBlocks blockFinished;

+ (instancetype)instanceNotificationAlertWithMessages:(NSString *)messages type:(NSString*)type jumpurl:(NSString*)jumpurl jumptype:(NSString*)jumptype;


- (void)alertShowAnimationWithfishi:(FinishBlocks)block;


@end

NS_ASSUME_NONNULL_END
