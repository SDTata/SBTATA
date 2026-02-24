//
//  LivePlayCell.m
//  phonelive
//
//  Created by 400 on 2020/9/3.
//  Copyright © 2020 toby. All rights reserved.
//

#import "LivePlayCell.h"
#import "hotModel.h"
#import "UIImageView+WebCache.h"
@interface LivePlayCell()
@property(nonatomic,strong)hotModel *model;
@end

@implementation LivePlayCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH ,SCREEN_HEIGHT)];
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        self.imgView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imgView];
        
        
        
    }
    return self;
}

-(void)loadImageView:(hotModel*)model
{
    _model = model;
   if (_model.zhuboImage) {
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:_model.zhuboImage]];
    }else{
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:_model.avatar_thumb]];
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc{
    self.imgView.image = nil;
//    [self.moviePlayView releaseall];
//    [self.moviePlayView.view removeFromSuperview];
//    [self.moviePlayView removeFromParentViewController];
//    self.moviePlayView = nil;
}
- (void)prepareForReuse {
    [super prepareForReuse];
//    self.imgView.image = nil;
//    [self.moviePlayView releaseall];
//    [self.moviePlayView.view removeFromSuperview];
//    [self.moviePlayView removeFromParentViewController];
//    self.moviePlayView = nil;
}

@end
