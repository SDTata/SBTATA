#import "hotModel.h"

@implementation hotModel

+(NSDictionary*)mj_replacedKeyFromPropertyName
{
    return @{@"zhuboName":@"user_nicename",
             @"zhuboPlace":@"city",
             @"onlineCount":@"nums",
             @"avatar_thumb":@"avatar_thumb",
             @"zhuboImage":@"thumb",
             @"zhuboIcon":@"avatar",
             @"zhuboID":@"uid",
             @"ID":@"id"
    };
}



-(void)setCommentFrame{
    //头像
    _IconR = CGRectMake(15,10,40,40);
    //大图
    _imageR = CGRectMake(0,60, _window_width,_window_width);
    //名字
    _nameR = CGRectMake(70,10,200, 20);
    //位置
    _placeR = CGRectMake(70,33,200,14);
    //在线人数
    _CountR = CGRectMake(_window_width - 170,10,150,20);
    //直播状态
    _statusR = CGRectMake(_window_width - 95,15,80,45);
}

@end
