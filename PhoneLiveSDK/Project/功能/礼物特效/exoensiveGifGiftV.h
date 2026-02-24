//
//  exoensiveGifGiftV.h
//  yunbaolive
//
//  Created by Boom on 2018/10/16.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVGAPlayer/SVGA.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ExopenGifPlayerDelegate <NSObject>

@optional
- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player;
- (void)svgaPlayerDidAnimatedToFrame:(NSInteger)frame;
- (void)svgaPlayerDidAnimatedToPercentage:(CGFloat)percentage;

@end

@interface exoensiveGifGiftV : UIView<SVGAPlayerDelegate>

@property (nonatomic, weak) id<ExopenGifPlayerDelegate> delegate;

-(instancetype)initWithGiftData:(NSDictionary *)giftData andVideoitem:(SVGAVideoEntity * _Nullable)videoitem;

@end

NS_ASSUME_NONNULL_END
