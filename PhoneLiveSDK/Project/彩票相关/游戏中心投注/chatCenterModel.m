#import "chatCenterModel.h"
#import "NSString+StringSize.h"
#import <DTCoreText/DTCoreText.h>
@implementation chatCenterModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.titleColor  = minstr([dic valueForKey:@"titleColor"]);
        self.userName = minstr([dic valueForKey:@"userName"]);
        self.contentChat = minstr([dic valueForKey:@"contentChat"]);
        self.levelI = minstr([dic valueForKey:@"levelI"]);
        self.userID = minstr([dic valueForKey:@"id"]);
        self.vip_type = minstr([dic valueForKey:@"vip_type"]);
        self.liangname = minstr([dic valueForKey:@"liangname"]);
        self.guardType = minstr([dic valueForKey:@"guard_type"]);
        self.gamePlat = minstr([dic valueForKey:@"gamePlat"]);
        self.gameKindID = minstr([dic valueForKey:@"gameKindID"]);
        self.king_icon = minstr([dic valueForKey:@"king_icon"]);
        if([dic valueForKey:@"lotteryType"]){
            self.lotteryType = minstr([dic valueForKey:@"lotteryType"]);
            self.way = [dic valueForKey:@"way"];
            self.ways = [dic objectForKey:@"ways"];
            self.money = [dic valueForKey:@"money"];
            self.issue = [dic valueForKey:@"issue"];
            self.optionName1 = [dic valueForKey:@"optionName"];
            self.optionNameSt = [dic valueForKey:@"optionNameSt"];
            
        }
        if([dic valueForKey:@"lotteryDividend"]){
            self.userID = [dic valueForKey:@"from_uid"];
        }
//        是否用户发言
        if([dic valueForKey:@"isUserMsg"]){
            self.isUserMsg = [dic valueForKey:@"isUserMsg"];
        }
//        是否系统公告
        if([dic valueForKey:@"isSeverMsg"]){
            self.isUserMsg = [dic valueForKey:@"isSeverMsg"];
        }
        
        //        self.bRichtext = [dic valueForKey:@"bRichtext"];
        
        //        self.bRichtext = true;
        //        self.titleColor = @"kygame";
        //        self.contentChat = @"<font color=\"#aeb7ce\">恭喜玩家</font><font color=\"#fff292\">****ong</font><font color=\"#aeb7ce\">在</font><font color=\"#fff292\">炸金花高级房</font><font color=\"#aeb7ce\">中沉着冷静、有勇有谋，一举赢得</font><font color=\"#fff292\">1,187.5</font><font color=\"#aeb7ce\">！</font>";
        //        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[notice dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        
        if ([minstr([dic valueForKey:@"usertype"]) isEqual:@"40"]) {
            self.isadmin = @"1";
        }else{
            self.isadmin = @"0";
        }
        self.isAnchor = minstr([dic valueForKey:@"isAnchor"]);
        if([dic valueForKey:@"lang"]){
            self.lang = [dic valueForKey:@"lang"];
            NSString * currentLanguageServer = [RookieTools currentLanguageServer];
            NSArray * sayArr = [common getQuickSay];
            if (![self.lang isEqualToString:currentLanguageServer] && ![sayArr containsObject:self.lang]) {
                self.isTranslate = YES;
            }
        }
        
    }
    return self;
}
-(void)setChatFrame{
    UIFont *font1 = [UIFont systemFontOfSize:12];//Arial-ItalicMT
    NSString *string = [_userName stringByAppendingPathComponent:_contentChat];
    //VIP类型，0表示无VIP，1表示普通VIP，2表示至尊VIP
    //0表示无靓号
    if ([self.vip_type isEqual:@"0"] ||self.vip_type == nil || self.vip_type == NULL || [self.vip_type isEqual:@"(null)"])
    {
        _vipR = CGRectMake(2, 0, 0, 0);
    }
    else
    {
        _vipR = CGRectMake(2,0,25,25);
    }
    
    if (![PublicObj checkNull:self.king_icon]) {
        _kingR = CGRectMake(2, 0, 30, 25);
    }else{
        _kingR = CGRectMake(2, 0, 0, 0);
    }
    
    if ([self.liangname isEqual:@"0"])
    {
        _liangR = CGRectMake(2,0,0,0);
    }
    else
    {
        _liangR = CGRectMake(_vipR.size.width + 2,5,16,16);
    }
    //    CGFloat ww ;
    //    if (IS_IPHONE_5) {
    //        ww = _window_width*0.45 + 70;
    //    }else{
    //        ww = _window_width*0.55 + 70;
    //    }
    //    CGSize size = [string boundingRectWithSize:CGSizeMake(ww, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font1} context:nil].size;
    _levelR = CGRectMake(_kingR.size.width +_liangR.size.width + _vipR.size.width + 6,7,16,16);
    //    double suanheight = ceil(size.height);
    CGFloat widthhh = [YBToolClass sharedInstance].liveTableWidth - (_liangR.size.width+_liangR.size.width + _vipR.size.width + 6+16)-2;
    double suanheight = [[YBToolClass sharedInstance] heightOfString:string andFont:font1 andWidth:widthhh];
    _nameR  = CGRectMake(_levelR.origin.x + _levelR.size.width + 6,3,widthhh,suanheight);//+30
    _NAMER = CGRectMake(2,3, [YBToolClass sharedInstance].liveTableWidth-4, suanheight);
    _rowHH = MAX(0, CGRectGetMaxY(_nameR));
    [self resetString];
}
+(instancetype)modelWithDic:(NSDictionary *)dic{
    chatCenterModel *model = [[chatCenterModel alloc]initWithDic:dic];
    return model;
}

-(void)resetString{
    if ([self.titleColor isEqual:@"userLogin"]) {
        _textString = [NSString stringWithFormat:@"%@ %@",self.userName,self.contentChat];
    }else if ([self.titleColor isEqual:@"redbag"]){
        _textString = [NSString stringWithFormat:@"%@%@",self.userName,self.contentChat];
    }else if ([self.titleColor isEqual:@"kygame"]){
        _textString = [NSString stringWithFormat:@"%@",self.contentChat];
    }else if ([self.titleColor isEqual:@"platgame"]){
        _textString = [NSString stringWithFormat:@"%@",self.contentChat];
    }else if ([self.titleColor isEqual:@"lotteryProfit"]){
        _textString = [NSString stringWithFormat:@"%@",self.contentChat];
    }else if ([self.titleColor isEqual:@"lotteryDividend"]){
        _textString = [NSString stringWithFormat:@"%@",self.contentChat];
    }else{
        _textString = [NSString stringWithFormat:@"%@:%@",self.userName,self.contentChat];
    }
    if ([PublicObj checkNull:_textString]) {
        _textString = @"";
    }
    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:_textString attributes:nil];
    [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, noteStr.length)];
    [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, noteStr.length)];
    if (![PublicObj checkNull:_titleColor] && [_titleColor isEqualToString:@"firstlogin"]) {
        
    }else if (![PublicObj checkNull:_titleColor] && [_titleColor isEqualToString:@"redbag"]){
        [noteStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, noteStr.length)];
        [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, noteStr.length)];
    }else{
        if ([_titleColor isEqual:@"userLogin"]){
            [noteStr addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#c7c9c7", 1) range:NSMakeRange(0, noteStr.length)];
        }else{
            [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, noteStr.length)];
        }
        if (_titleColor && [_titleColor isEqualToString:@"2"])//礼物
        {
            [noteStr addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#f5cb2f", 1) range:NSMakeRange(0, noteStr.length)];
        }
    }
    //入场消息 开播警告
    if (![PublicObj checkNull:self.titleColor] && [self.titleColor isEqualToString:@"firstlogin"]) {
        if (![PublicObj checkNull:self.contentChat]) {
            noteStr = [[NSMutableAttributedString alloc] initWithString:self.contentChat attributes:nil];
            [noteStr addAttribute:NSForegroundColorAttributeName value:normalColors range:NSMakeRange(0, noteStr.length)];
            [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, noteStr.length)];
        }
    }else if(![PublicObj checkNull:self.titleColor] && ([self.titleColor isEqualToString:@"kygame"]||[self.titleColor isEqualToString:@"platgame"])){
        
        // 标签
        NSTextAttachment *winAttchment = [[NSTextAttachment alloc]init];
        winAttchment.bounds = CGRectMake(0, -2, 27, 15);//设置frame
        winAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_win")];//设置图片
        noteStr = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:winAttchment]];
        [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, noteStr.length)];
        
        // 空格
        NSAttributedString *speaceString = [[NSAttributedString  alloc]initWithString:@" "];
        [noteStr insertAttributedString:speaceString atIndex:1];
        if (![PublicObj checkNull:self.contentChat]) {
            // 内容
            // 内容
            NSDictionary *options;
            
            if (@available(iOS 13.0, *)) {
                options = @{DTDefaultTextColor: [UIColor labelColor], DTUseiOS6Attributes: @(YES)};
            } else {
                options = @{DTDefaultTextColor: [UIColor blackColor], DTUseiOS6Attributes: @(YES)};
            }
            
            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithHTMLData:[self.contentChat dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:NULL]];
            
            [contentString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, contentString.length)];
            [contentString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, contentString.length)];
            
            if (contentString.length>0 && noteStr.length>=2) {
                [noteStr insertAttributedString:contentString atIndex:2];
            }
            
        }
        // 按钮
        NSTextAttachment *gameBtnAttchment = [[NSTextAttachment alloc]init];
        gameBtnAttchment.bounds = CGRectMake(0, -5, 45, 20);//设置frame
        gameBtnAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_follow_game")];//设置图片
        NSAttributedString *gameBtnString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(gameBtnAttchment)];
        if (gameBtnString.length>0) {
            [noteStr insertAttributedString:gameBtnString atIndex:noteStr.length];//插入到第几个下标
        }
    }else if(![PublicObj checkNull:self.titleColor] && [self.titleColor isEqualToString:@"lotteryBet"]){
        // 标签
        NSTextAttachment *winAttchment = [[NSTextAttachment alloc]init];
        winAttchment.bounds = CGRectMake(0, -2, 27, 15);//设置frame
        winAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_system")];//设置图片
        noteStr = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:winAttchment]];
        // 空格
        NSAttributedString *speaceString = [[NSAttributedString  alloc]initWithString:@" "];
        [noteStr insertAttributedString:speaceString atIndex:1];
        if (![PublicObj checkNull:self.contentChat]) {
            // 内容
            // 内容
            NSDictionary *options;
            
            if (@available(iOS 13.0, *)) {
                options = @{DTDefaultTextColor: [UIColor labelColor], DTUseiOS6Attributes: @(YES)};
            } else {
                options = @{DTDefaultTextColor: [UIColor blackColor], DTUseiOS6Attributes: @(YES)};
            }
            
            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithHTMLData:[self.contentChat dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:NULL]];
            [contentString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, contentString.length)];
            [contentString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, contentString.length)];
            
            if (contentString!=nil && noteStr!=nil) {
                [noteStr insertAttributedString:contentString atIndex:2];
                
            }
        }
        // 按钮
        NSTextAttachment *gameBtnAttchment = [[NSTextAttachment alloc]init];
        gameBtnAttchment.bounds = CGRectMake(0, -5, 45, 20);//设置frame
        gameBtnAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_follow_bet")];//设置图片
        NSAttributedString *gameBtnString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(gameBtnAttchment)];
        [noteStr insertAttributedString:gameBtnString atIndex:noteStr.length];//插入到第几个下标
    }else if(![PublicObj checkNull:self.titleColor] && [self.titleColor isEqualToString:@"lotteryProfit"]){
        // 标签
        NSTextAttachment *winAttchment = [[NSTextAttachment alloc]init];
        winAttchment.bounds = CGRectMake(0, -3, 27, 15);//设置frame
        winAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_win")];//设置图片
        noteStr = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:winAttchment]];
        // 空格
        NSAttributedString *speaceString = [[NSAttributedString  alloc]initWithString:@" "];
        [noteStr insertAttributedString:speaceString atIndex:1];
        if (![PublicObj checkNull:self.contentChat]) {
            // 内容
            // 内容
            NSDictionary *options;
            
            if (@available(iOS 13.0, *)) {
                options = @{DTDefaultTextColor: [UIColor labelColor], DTUseiOS6Attributes: @(YES)};
            } else {
                options = @{DTDefaultTextColor: [UIColor blackColor], DTUseiOS6Attributes: @(YES)};
            }
            
            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithHTMLData:[self.contentChat dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:NULL]];
            [contentString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, contentString.length)];
            [contentString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, contentString.length)];
            
            [noteStr insertAttributedString:contentString atIndex:2];
        }
    }else if(![PublicObj checkNull:self.titleColor] && [self.titleColor isEqualToString:@"lotteryDividend"]){
        
        // 标签
        NSTextAttachment *winAttchment = [[NSTextAttachment alloc]init];
        winAttchment.bounds = CGRectMake(0, -2, 27, 15);//设置frame
        winAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_dividend")];//设置图片
        noteStr = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:winAttchment]];
        // 空格
        NSAttributedString *speaceString = [[NSAttributedString  alloc]initWithString:@" "];
        [noteStr insertAttributedString:speaceString atIndex:1];
        if (![PublicObj checkNull:self.contentChat]) {
            // 内容
            // 内容
            NSDictionary *options;
            
            if (@available(iOS 13.0, *)) {
                options = @{DTDefaultTextColor: [UIColor labelColor], DTUseiOS6Attributes: @(YES)};
            } else {
                options = @{DTDefaultTextColor: [UIColor blackColor], DTUseiOS6Attributes: @(YES)};
            }
            
            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithHTMLData:[self.contentChat dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:NULL]];
            [contentString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, contentString.length)];
            [contentString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, contentString.length)];
            
            [noteStr insertAttributedString:contentString atIndex:2];
        }
        
    }else{
        NSDictionary *levelDic = [common getUserLevelMessage:self.levelI];
        NSAttributedString *speaceString = [[NSAttributedString  alloc]initWithString:@" "];
        
        NSTextAttachment *adminAttchment = [[NSTextAttachment alloc]init];
        adminAttchment.bounds = CGRectMake(0, -2, 15, 15);//设置frame
        adminAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_admin")];//设置图片
        NSAttributedString *adminString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(adminAttchment)];
        
        NSTextAttachment *shouAttchment = [[NSTextAttachment alloc]init];
        shouAttchment.bounds = CGRectMake(0, -2, 15, 15);//设置frame
        shouAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_shou")];//设置图片
        NSAttributedString *shouString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(shouAttchment)];
        
        NSTextAttachment *yearAttchment = [[NSTextAttachment alloc]init];
        yearAttchment.bounds = CGRectMake(0, -2, 15, 15);//设置frame
        yearAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_shou_year")];//设置图片
        NSAttributedString *yearString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(yearAttchment)];
        
        
        NSTextAttachment *vipAttchment = [[NSTextAttachment alloc]init];
        vipAttchment.bounds = CGRectMake(0, -2, 30, 15);//设置frame
        vipAttchment.image = [ImageBundle imagewithBundleName:@"chat_vip"];//设置图片
        NSAttributedString *vipString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(vipAttchment)];
        
        NSTextAttachment *levelAttchment = [[NSTextAttachment alloc]init];
        levelAttchment.bounds = CGRectMake(0, -2, 30, 15);//设置frame
        WeakSelf
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager loadImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]
                          options:SDWebImageHighPriority
                         progress:nil
                        completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            STRONGSELF
            if (strongSelf==nil) {
                return;
            }
            if (image) {
                levelAttchment.image = image;
            }
        }];
        
        
        
        NSAttributedString *levelString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(levelAttchment)];
        
        
        
        
        NSTextAttachment *liangAttchment = [[NSTextAttachment alloc]init];
        liangAttchment.bounds = CGRectMake(0, -2, 15, 15);//设置frame
        liangAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_liang")];//设置图片
        NSAttributedString *liangString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(liangAttchment)];
        
        /*
         0 青蛙
         1 猴子
         2 小红花
         3 小黄花
         4 心
         */
        NSRange redRange = NSMakeRange(0, self.userName.length+1);
        if ([self.isAnchor isEqual:@"1"]) {
            [noteStr addAttribute:NSForegroundColorAttributeName value:normalColors range:redRange];
        }else{
            [noteStr addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(minstr([levelDic valueForKey:@"colour"]), 1) range:redRange];
        }
        if (self.titleColor && [self.titleColor isEqualToString:@"2"])//礼物
        {
            // 添加表情
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            // 表情图片
            attch.image = [ImageBundle imagewithBundleName:@"plane_heart_cyan.png"];
            // 设置图片大小
            attch.bounds = CGRectMake(0,-4,17,17);
            NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
            
            [noteStr appendAttributedString:string];
            //                [noteStr appendAttributedString:[[NSAttributedString alloc]initWithString:self.chatLabel.text]];
        }else if (self.titleColor && [self.titleColor isEqualToString:@"light0"])//青蛙
        {
            // 添加表情
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            // 表情图片
            attch.image = [ImageBundle imagewithBundleName:@"plane_heart_cyan.png"];
            // 设置图片大小
            attch.bounds = CGRectMake(0,-4,17,17);
            NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
            [noteStr appendAttributedString:string];
        }else if (self.titleColor && [self.titleColor isEqualToString:@"light1"])//猴子
        {
            // 添加表情
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            // 表情图片
            attch.image = [ImageBundle imagewithBundleName:@"plane_heart_pink.png"];
            // 设置图片大小
            attch.bounds = CGRectMake(0,-4,17,17);
            NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
            [noteStr appendAttributedString:string];
        }else if (self.titleColor && [self.titleColor isEqualToString:@"light2"])//小红花
        {
            // 添加表情
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            // 表情图片
            attch.image = [ImageBundle imagewithBundleName:@"plane_heart_red.png"];
            // 设置图片大小
            attch.bounds = CGRectMake(0,-4,17,17);
            NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
            [noteStr appendAttributedString:string];
        }
        else if (self.titleColor && [self.titleColor isEqualToString:@"light3"])//小黄花
        {
            // 添加表情
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            // 表情图片
            attch.image = [ImageBundle imagewithBundleName:@"plane_heart_yellow.png"];
            // 设置图片大小
            attch.bounds = CGRectMake(0,-4, 17, 17);
            NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
            [noteStr appendAttributedString:string];
        }else if (self.titleColor && [self.titleColor isEqualToString:@"light4"])//心
        {
            // 添加表情
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            // 表情图片
            attch.image = [ImageBundle imagewithBundleName:@"plane_heart_heart"];
            // 设置图片大小
            attch.bounds = CGRectMake(0,-4, 17, 17);
            NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
            [noteStr appendAttributedString:string];
        }
        
//        是否显示翻译按钮
        if (self.isTranslate) {
            // 按钮
            NSTextAttachment *translateAttchment = [[NSTextAttachment alloc]init];
            translateAttchment.bounds = CGRectMake(0, -5, 60, 20);//设置frame
            translateAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_translate")];//设置图片
            NSMutableAttributedString *translateString = [NSMutableAttributedString attributedStringWithAttachment:(NSTextAttachment *)(translateAttchment)];
            [translateString addAttribute:NSLinkAttributeName
                                     value:@"fanyi://"
                                     range:NSMakeRange(0, translateString.length)];
            if (translateString.length>0) {
                [noteStr addAttribute:NSLinkAttributeName
                                         value:@"msg://"
                                         range:NSMakeRange(redRange.length, noteStr.length)];
                [noteStr insertAttributedString:translateString atIndex:noteStr.length];//插入到第几个下标
            }
        }
        //插入靓号图标
        if (![PublicObj checkNull:self.liangname] && ![self.liangname isEqualToString:@"0"]) {
            [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
            [noteStr insertAttributedString:liangString atIndex:0];//插入到第几个下标
        }
        //插入守护图标
        if (![PublicObj checkNull:self.guardType] && [self.guardType isEqualToString:@"1"]) {
            [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
            [noteStr insertAttributedString:shouString atIndex:0];//插入到第几个下标
        }
        if (![PublicObj checkNull:self.guardType] && [self.guardType isEqualToString:@"2"]) {
            [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
            [noteStr insertAttributedString:yearString atIndex:0];//插入到第几个下标
        }
        //插入管理图标
        if (![PublicObj checkNull:self.isadmin] && [self.isadmin isEqualToString:@"1"]) {
            [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
            [noteStr insertAttributedString:adminString atIndex:0];//插入到第几个下标
        }
        //插入VIP图标
        if (![PublicObj checkNull:self.vip_type] && [self.vip_type isEqualToString:@"1"]) {
            [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
            [noteStr insertAttributedString:vipString atIndex:0];//插入到第几个下标
        }
        
        [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
        [noteStr insertAttributedString:levelString atIndex:0];//插入到第几个下标
        
        NSString *king_icon = self.king_icon;
        if (![PublicObj checkNull:king_icon]) {
            NSTextAttachment *kingAttchment = [[NSTextAttachment alloc]init];
            kingAttchment.bounds = CGRectMake(0, -2, 35, 15);//设置frame
            NSAttributedString *kingString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(kingAttchment)];
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:king_icon] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if (image) {
                    kingAttchment.image = image;
                }

            }];
            [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
            [noteStr insertAttributedString:kingString atIndex:0];//插入到第几个下标
        }
        
    }
    _textAttribute = noteStr;
}

@end
