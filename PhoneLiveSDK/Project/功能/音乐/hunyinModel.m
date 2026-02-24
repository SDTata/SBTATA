
#import "hunyinModel.h"

@implementation hunyinModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    
    
    self = [super init];
    
    if (self) {
        _artistname = minstr([dic valueForKey:@"artist_name"]);
        _songname = minstr([dic valueForKey:@"audio_name"]);
        _songid = minstr([dic valueForKey:@"audio_id"]);
        
    }
    return self;
}


+(instancetype)modelWithDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithDic:dic];
}
@end
