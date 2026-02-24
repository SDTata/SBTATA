//
//  DramaFavoriteViewController.h
//  DramaTest
//
//  Created by s5346 on 2024/5/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DramaFavoriteViewControllerType) {
    DramaFavoriteViewControllerForHistory = 0,
    DramaFavoriteViewControllerForFavorite = 3,
};

@interface DramaFavoriteViewController : UIViewController

- (instancetype)initWithType:(DramaFavoriteViewControllerType)type;

@end

NS_ASSUME_NONNULL_END
