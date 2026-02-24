//
//  GamesHeader.m
//  phonelive2
//
//  Created by test on 4/13/21.
//  Copyright © 2021 toby. All rights reserved.
//

#import "GamesHeader.h"
#import "common.h"
@implementation GamesHeader

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self createSubView];
    }
    return self;
}
- (void)createSubView{
    NSArray* ad_list = [common ad_list];
    int gameCount = 0;
    //    ad_list = [[NSArray alloc] init];;
    if(![ad_list isEqual:[NSNull null]] && ad_list.count > 0){
        for (NSDictionary *_ad in ad_list) {
            if([[_ad valueForKey:@"type"] isEqual:@"game"]){
                gameCount++;
            }
        }
    }
    
    int numPreLine = 4;
    float avgW = 0;
    float imgBtnW = _window_width;//inviteImageBtn.width;
    if(gameCount > 0){
        avgW = (imgBtnW-5) / MIN(numPreLine, (gameCount + 1));
        if(avgW > 80){
            avgW = 80;
        }
    }else{
        avgW = -79;
    }
    
    float avgH = ceil(1.0*gameCount/numPreLine) * (avgW *5/4 + 10) + 10;
    UIView *gameView = [[UIView alloc]initWithFrame:CGRectMake(AD(0), AD(0), _window_width, avgH + AD(15) + AD(35))];
    gameView.backgroundColor = [UIColor clearColor];
    [self addSubview:gameView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(AD(13), AD(10), gameView.width - AD(26), AD(15))];
    [label setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
    [label setTextColor:RGB(51, 51, 51)];
    [label setText:YZMsg(@"GamesHeader_Game_Recommend")];
    [gameView addSubview:label];
    [label sizeToFit];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(label.right - 29, label.bottom +AD(3),30 , AD(3))];
    line.backgroundColor = RGB(184, 92, 238);
    line.layer.masksToBounds = YES;
    line.layer.cornerRadius = 1.5;
    [gameView addSubview:line];
    
    UIView *gameContent = [[UIView alloc]initWithFrame:CGRectMake(AD(0), AD(19) + AD(15), _window_width, avgH + AD(15))];
    gameContent.backgroundColor = [UIColor clearColor];
    [gameView addSubview:gameContent];
    [self createGameContentWithSuper:gameContent withHeight:avgH andItemWidth:avgW andAdlist:ad_list];
    
    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(AD(0),avgH + AD(15) + AD(35), _window_width, AD(40))];
    downView.backgroundColor = [UIColor clearColor];
    [self addSubview:downView];
    
    UILabel *liveTitle = [[UILabel alloc]initWithFrame:CGRectMake(AD(13), AD(10), gameView.width - AD(26), AD(15))];
    [liveTitle setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
    [liveTitle setTextColor:RGB(51, 51, 51)];
    [liveTitle setText:YZMsg(@"AttentionHeader_Popular_Hot")];
    [downView addSubview:liveTitle];
    [liveTitle sizeToFit];
    
    UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(liveTitle.right - 29, liveTitle.bottom +AD(3), 30 , AD(3))];
    line2.backgroundColor = RGB(184, 92, 238);
    line2.layer.masksToBounds = YES;
    line2.layer.cornerRadius = 1.5;
    [downView addSubview:line2];
    
//    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    moreBtn.frame = CGRectMake(downView.right - AD(180),AD(10),AD(170),AD(15));
//    moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    //[moreBtn setImage:[ImageBundle imagewithBundleName:@"arrows_43"] forState:UIControlStateNormal];
//    [moreBtn setTitle:YZMsg(@"Hotpage_AddMoreCountry") forState:UIControlStateNormal];
//    [moreBtn setTitleColor:RGB(153, 153, 153) forState:0];
//    [moreBtn setImage:[ImageBundle imagewithBundleName:@"zjm_jt2"]forState:UIControlStateNormal];
//    moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, AD(20));
//    [moreBtn setImageEdgeInsets:UIEdgeInsetsMake(AD(15), AD(155), AD(15), 0)];
//    moreBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    moreBtn.titleLabel.font = SYS_Font(14);
//    moreBtn.titleLabel.textAlignment = NSTextAlignmentRight;
//    [moreBtn addTarget:self action:@selector(filterVC) forControlEvents:UIControlEventTouchUpInside];
//    [downView addSubview:moreBtn];
    
//    self.anchorfiltrCountryView = [[[XBundle currentXibBundleWithResourceName:@"FilterAnchorCounrtyView"] loadNibNamed:@"FilterAnchorCounrtyView" owner:nil options:nil] firstObject];
//    [downView addSubview:self.anchorfiltrCountryView];
    
}

-(void)filterVC{
    if (self.delegate) {
        [self.delegate filterVC];
    }
}

- (void)createGameContentWithSuper:(UIView *)superView withHeight:(CGFloat)avgH andItemWidth:(CGFloat)avgW andAdlist:(NSArray *)ad_list{
    
    UIView *games = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, avgH)];
    games.backgroundColor = [UIColor clearColor];
    games.layer.cornerRadius = 5.0;
    games.layer.masksToBounds = YES;
    games.userInteractionEnabled = YES;
    
    [superView addSubview:games];
    
    // Set up constants
    int numPerRow = 4; // Items per row
    CGFloat gap = (_window_width - (avgW * numPerRow)) / (numPerRow + 1); // Calculate the gap between items
    CGFloat itemH = avgW * 5 / 4; // Item height
    CGFloat startY = 10; // Initial y position
    CGFloat sidePadding = gap; // Side padding is the same as the gap for uniform spacing
    
    // Only proceed if ad_list is not null or empty
    if (![ad_list isEqual:[NSNull null]] && ad_list.count > 0) {
        int idx = 0; // Index for each game item
        for (NSDictionary *_ad in ad_list) {
            if ([[_ad valueForKey:@"type"] isEqual:@"game"]) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
                // Calculate the position for each button
                int row = idx / numPerRow; // Calculate current row
                int col = idx % numPerRow; // Calculate current column
                CGFloat x = sidePadding + col * (avgW + gap);
                CGFloat y = startY + row * (itemH + startY);
                
                btn.frame = CGRectMake(x, y, avgW, itemH);
                btn.tag = idx;
                btn.userInteractionEnabled = YES;
                [btn addTarget:self action:@selector(jumpGame:) forControlEvents:UIControlEventTouchUpInside];

                [btn sd_setImageWithURL:[NSURL URLWithString:[_ad valueForKey:@"src"]] forState:UIControlStateNormal placeholderImage:GamePlaceholdImageVertical completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    if (image) {
                        [btn setImage:image forState:UIControlStateNormal];
                        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    }
                }];

                [games addSubview:btn];
                idx++;
            }
        }
        
        // Update the height of the games view based on the number of rows
        int totalRows = ceil((double)idx / numPerRow);
        CGRect gamesFrame = games.frame;
        gamesFrame.size.height = startY + (itemH + startY) * totalRows;
        games.frame = gamesFrame;
    }
}

- (void)jumpGame:(UIButton *)sender{
    NSArray* ad_list = [common ad_list];
    int idx = 0;
    if(![ad_list isEqual:[NSNull null]] && ad_list.count > 0){
        for (NSDictionary *_ad in ad_list) {
            if([[_ad valueForKey:@"type"] isEqual:@"game"]){
                if(sender.tag == idx){
                    if (self.delegate) {
                        [self.delegate jumpToGameType:_ad];
                    }
                    break;
                    return;
                }
                idx++;
            }
        }
    }
}
@end
