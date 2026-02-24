//
//  HomeMoreSectionHeaderView.h
//  NewDrama
//
//  Created by s5346 on 2024/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeMoreSectionHeaderView : UICollectionReusableView

- (void)updateForIcon:(NSString*)icon title:(NSString*)title placeholder:(NSString *)placeholder block:(void (^)(void))buttonActionBlock;

@end

NS_ASSUME_NONNULL_END
