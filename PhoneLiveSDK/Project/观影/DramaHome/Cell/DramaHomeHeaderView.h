//
//  DramaHomeHeaderView.h
//  DramaTest
//
//  Created by s5346 on 2024/5/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DramaHomeHeaderViewSelectType) {
    DramaHomeHeaderViewSelectTypeForLatest = 0,
    DramaHomeHeaderViewSelectTypeForHot,
};

@protocol DramaHomeHeaderViewDelegate <NSObject>

- (void)DramaHomeHeaderViewDelegateForSelectType:(DramaHomeHeaderViewSelectType)type;

@end

@interface DramaHomeHeaderView : UICollectionReusableView
@property(nonatomic, assign) id<DramaHomeHeaderViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
