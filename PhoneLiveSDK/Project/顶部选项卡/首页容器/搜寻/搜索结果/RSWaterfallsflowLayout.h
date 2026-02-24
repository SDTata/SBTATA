//
//  RSWaterfallsflowLayout.h
//  RSWaterfallsDemo
//
//  Created by WhatsXie on 2017/8/17.
//  Copyright © 2017年 StevenXie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSWaterfallsflowLayout;

@protocol RSWaterfallsflowLayoutDelegate <NSObject>

@required
- (CGFloat)waterflowLayout:(RSWaterfallsflowLayout *)waterflowLayout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth;
- (CGFloat)waterflowLayout:(RSWaterfallsflowLayout *)waterflowLayout heightForShortVideoItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth;
@optional
- (CGFloat)columnCountInWaterflowLayout:(RSWaterfallsflowLayout *)waterflowLayout;
- (CGFloat)columnMarginInWaterflowLayout:(RSWaterfallsflowLayout *)waterflowLayout;
- (CGFloat)rowMarginInWaterflowLayout:(RSWaterfallsflowLayout *)waterflowLayout;
- (UIEdgeInsets)edgeInsetsInWaterflowLayout:(RSWaterfallsflowLayout *)waterflowLayout;
@end

@interface RSWaterfallsflowLayout : UICollectionViewLayout
@property (nonatomic, weak) id<RSWaterfallsflowLayoutDelegate> delegate;
@end



