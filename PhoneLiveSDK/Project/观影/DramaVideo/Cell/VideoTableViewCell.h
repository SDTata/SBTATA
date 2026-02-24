//
//  VideoTableViewCell.h
//  AAAA
//
//  Created by s5346 on 2024/4/30.
//

#import <UIKit/UIKit.h>
#import "DramaPortraitVideoControlView.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoTableViewCell : UITableViewCell
@property (nonatomic, strong, nullable) DramaPortraitVideoControlView *controlView;
@property (nonatomic, strong) UIImageView *coverImgView;
- (void)update:(DramaVideoInfoModel*)model infoModel:(DramaInfoModel*)infoModel;
@end

NS_ASSUME_NONNULL_END
