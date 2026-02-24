//
//  VideoViewController.m
//  phonelive
//
//  Created by 400 on 2020/8/4.
//  Copyright © 2020 toby. All rights reserved.
//

#import "VideoViewController.h"
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoCutter.h"
@interface VideoViewController ()

@property (nonatomic,strong) AVPlayerViewController * moviePlayer ; //播放控制器本体啦
@property (nonatomic,assign) CGFloat moviePlayerSoundLevel ;  //控制音量的（有点冗余）

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.frame =CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) ;
    //NSString * videoPath = [[NSBundle mainBundle] pathForResource:@"login_guide" ofType:@"mp4"] ;
    //视频地址
    //NSURL * videoUrl = [[NSURL alloc] initFileURLWithPath:videoPath] ;
    self.alwaysRepeat = true ; //是否一致循环
    self.sound = false ; //是否有音效
    self.startTime = 2.0 ; //开始时间
    self.alpha = 0.8 ; //透明度
    //self.contentURL = videoUrl ; //把地址给到播放器，顺带也设置了
    
    //self.moviePlayer = [[AVPlayerViewController alloc]init] ; //这个刚开始没写 一直没有视图，但是不一定放在这里是最好的。
    //self.moviePlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //self.moviePlayer.showsPlaybackControls = false ;
    //self.moviePlayer.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) ;
   
    //[self.view addSubview:self.moviePlayer.view] ;
    //[self setFKCMoviePlayer:self.contentURL] ; //在填写视频地址时，完成播放器的设置。
    
    //[self.view sendSubviewToBack:self.moviePlayer.view] ;
    // Do any additional setup after loading the view.
}
-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.view.backgroundColor = backgroundColor ;
}

-(void)setSound:(BOOL)sound
{
    if (sound) {
        self.moviePlayerSoundLevel = 1.0 ;
    }
    else
    {
        self.moviePlayerSoundLevel = 0.0 ;
    }
}

-(void)setAlpha:(CGFloat)alpha
{
    self.moviePlayer.view.alpha = alpha ;
}

-(void)setAlwaysRepeat:(BOOL)alwaysRepeat
{
    if (alwaysRepeat) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil] ;
    }
}


//对应 setAlwaysRepeat 的监听
-(void)playerItemDidReachEnd
{
    [self.moviePlayer.player seekToTime:kCMTimeZero] ;
    [self.moviePlayer.player play] ;
}

-(void)setFKCMoviePlayer:(NSURL *)url
{
//    VideoCutter * videoCutter = [VideoCutter new] ; //这是一个对视频进行一次处理的类，等下上代码
//    WeakSelf
//    [videoCutter cropVideoWithUrl:url andStartTime:self.startTime andDuration:self.duration andCompletion:^(NSURL *videoPath, NSError *error) {
//        STRONGSELF
//        if (strongSelf == nil) {
//            return;
//        }
//        if ([videoPath isKindOfClass: [NSURL class]]) {
//
//            dispatch_queue_t globalDispatchQueueDefault = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//
//            dispatch_async(globalDispatchQueueDefault, ^{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (strongSelf == nil) {
//                        return;
//                    }
                    
                    self.moviePlayer.player = [[AVPlayer alloc] initWithURL:url] ;
                    [self.moviePlayer.player play] ;
                    self.moviePlayer.player.volume = self.moviePlayerSoundLevel ;
//                });
//            }) ;
//        }
//    }] ;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated] ;
    [self.view sendSubviewToBack:self.moviePlayer.view];
    [self.moviePlayer.player play];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view sendSubviewToBack:self.moviePlayer.view];
    [self.moviePlayer.player play];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.moviePlayer.player pause];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)dealloc{

}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
