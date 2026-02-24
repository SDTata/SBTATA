//
//  PostVideoViewController.h
//  phonelive2
//
//  Created by Co co on 2024/7/17.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define UploadVideoAndInfoFinished @"UploadVideoAndInfoFinished"

@interface RuleSection : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray<NSString *> *rules;

@end

@interface PostVideoViewController : UIViewController
@property (nonatomic, assign) BOOL fromMyCreatVC;
@end

NS_ASSUME_NONNULL_END
