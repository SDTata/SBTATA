#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface CachePostVideo : NSObject 

/*<NSCoding>*/

+ (instancetype)sharedManager;

@property (nonatomic,strong)NSString *video_title;
@property (nonatomic,assign)BOOL is_vip;
@property (nonatomic,strong)NSString *ticket_cost;
@property (nonatomic,strong)NSString *coin_cost;
@property (nonatomic,strong)NSString *coin_last;

//缓存其他金额
@property(nonatomic,strong)NSString *otherPrice;


@property (nonatomic,strong)NSMutableArray *selectedOtherTags;

@property (nonatomic,strong)NSMutableArray *selectedCurrentTags;

@property (nonatomic,strong)NSString *cover_aid;
@property (nonatomic,strong)NSString *cover_url;


//视频
@property(nonatomic,strong)UIImage *videoImage;
@property(nonatomic,strong)NSString *videoToken;
@property(nonatomic,strong)NSString *video_aid;

@property(nonatomic,strong)NSString *videoKey;
//上传成功后清除
@property(nonatomic,strong)PHAsset *asset;

@property(nonatomic,assign)BOOL videoisUploading;
@property(nonatomic,assign)BOOL coverisUploading;

-(NSArray*)getAllOthertagids;
-(NSArray*)getAllCurrentTags;

-(void)saveCachePostVideo;

@end

//NS_ASSUME_NONNULL_END
