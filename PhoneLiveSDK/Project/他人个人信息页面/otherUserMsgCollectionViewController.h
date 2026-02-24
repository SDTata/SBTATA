//
//  otherUserMsgCollectionViewController.h
//  phonelive2
//
//  Created by s5346 on 2024/8/14.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, otherUserMsgCollectionViewControllerType) {
    otherUserMsgCollectionViewControllerVideo,//作品
    otherUserMsgCollectionViewControllerTypeLike,//喜歡
    otherUserMsgCollectionViewControllerTypeLive,//直播
};

@protocol otherUserMsgCollectionViewControllerDelegate <NSObject>

- (void)otherUserMsgCollectionViewControllerForEndRefresh;
- (void)otherUserMsgCollectionViewControllerForScrollToTop;
- (CGFloat)otherUserMsgCollectionViewControllerForGetEmptyHeight;

@end

@interface otherUserMsgCollectionViewController : UIViewController

@property(nonatomic,strong)NSString *chatname;
@property(nonatomic,strong)NSString *icon;
@property(nonatomic,strong)NSString *level_anchor;
@property(nonatomic, assign) id<otherUserMsgCollectionViewControllerDelegate> delegate;

- (instancetype)initWithType:(otherUserMsgCollectionViewControllerType)type userID:(NSString*)userID;
- (void)refresh;
- (void)scroll:(BOOL)isScroll;
- (void)updateEmptyLabelHeight:(CGFloat)height;
@end

NS_ASSUME_NONNULL_END
