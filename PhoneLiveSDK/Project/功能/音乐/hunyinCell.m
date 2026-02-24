
#import "hunyinCell.h"
#import "hunyinModel.h"
#import <FFAES/FFAES.h>
#import "Config.h"
#import <SkyShield/SkyShield.h>
static NSString *musicPath;
@interface hunyinCell ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

{
    NSMutableData *musicData;
    long long allLength;
    float currentLength;
    
}

@end

@implementation hunyinCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    [self.down setTitle:YZMsg(@"musicView_donwload") forState:UIControlStateNormal];
}

-(void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx,1);
    CGContextSetStrokeColorWithColor(ctx,[UIColor groupTableViewBackgroundColor].CGColor);
    CGContextMoveToPoint(ctx,0,self.frame.size.height);
    CGContextAddLineToPoint(ctx,(self.frame.size.width),self.frame.size.height);
    CGContextStrokePath(ctx);
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.nameL = [[UILabel alloc]initWithFrame:CGRectMake(15,15, _window_width - 80,20)];
        
        self.nameL.textAlignment = NSTextAlignmentLeft;
        self.nameL.textColor = normalColors;
        self.nameL.font = fontMT(15);
        [self.contentView addSubview:self.nameL];
        
        self.songL = [[UILabel alloc]initWithFrame:CGRectMake(15,35, _window_width - 80,30)];
        self.songL.font = fontMT(13);
        self.songL.textAlignment = NSTextAlignmentLeft;
        self.songL.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.songL];
        self.downBTN = [UIButton buttonWithType:UIButtonTypeSystem];
        self.downBTN.frame = CGRectMake(_window_width - 70,15,40,40);
        self.downBTN.layer.masksToBounds = YES;
        self.downBTN.layer.cornerRadius = 20;
        self.downBTN.layer.borderColor = normalColors.CGColor;
        self.downBTN.layer.borderWidth = 1;
        [self.downBTN setTitleColor:normalColors forState:UIControlStateNormal];
        [self.downBTN setTitle:YZMsg(@"musicView_donwload") forState:UIControlStateNormal];
        [self.downBTN addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
        self.downBTN.enabled = NO;
        [self.contentView addSubview:self.downBTN];
        self.downL = [[UILabel alloc]initWithFrame:CGRectMake(_window_width - 70,15,40,40)];
        self.downL.textAlignment = NSTextAlignmentCenter;
        self.downL.layer.masksToBounds = YES;
        self.downL.layer.cornerRadius = 20;
        self.downL.layer.borderColor = normalColors.CGColor;
        self.downL.layer.borderWidth = 1;
        self.downL.font =  fontMT(13);
        self.downL.textColor = normalColors;
        self.downL.hidden = YES;
        [self.contentView addSubview:self.downL];
    }
    return self;
}


-(void)setModel:(hunyinModel *)model{
    _model = model;
    _songID = _model.songid;
    _nameL.text = _model.songname;
    _songL.text = _model.artistname;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *loadPath = [docDir stringByAppendingFormat:@"/%@*%@*%@.mp3",_model.songid,_model.songname,_model.artistname];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:loadPath]) {
        NSURL *url = [NSURL URLWithString:self.path];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection connectionWithRequest:request delegate:self];
        [self.downBTN setTitle:YZMsg(@"musicView_choise") forState:UIControlStateNormal];
        self.downBTN.hidden = NO;
        self.downL.hidden = YES;
    }
    else {
        if (!_isDown) {
            [self.downBTN setTitle:YZMsg(@"musicView_donwload") forState:UIControlStateNormal];
        }
    }
}
+(hunyinCell *)cellWithTableView:(UITableView *)tableView{
    
    hunyinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"music"];
    
    if(!cell){
        
      cell = [[hunyinCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"music"];
    }
    
    return cell;
    
}

- (void)prepareForReuse

{
    
    [super prepareForReuse];
    
}



- (IBAction)download:(id)sender {

}

-(void)musicDownLoad{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *loadPath = [docDir stringByAppendingFormat:@"/%@*%@*%@.mp3",_model.songid,_model.songname,_model.artistname];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:loadPath]) {
        NSURL *url = [NSURL URLWithString:self.path];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // 配置请求属性
        [request setTimeoutInterval:30]; // 设置超时时间
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData]; // 忽略本地缓存
        
        NSString *originalHost = request.URL.host;
        if (originalHost == nil) {
            NSString *fixedUrlString = request.URL.absoluteString ;
            fixedUrlString= [fixedUrlString stringByReplacingOccurrencesOfString:@"http:///" withString:@"http://"];
            fixedUrlString= [fixedUrlString stringByReplacingOccurrencesOfString:@"https:///" withString:@"https://"];
            
            if (([fixedUrlString hasPrefix:@"http:/"] && ![fixedUrlString hasPrefix:@"http://"])||([fixedUrlString hasPrefix:@"https:/"] && ![fixedUrlString hasPrefix:@"https://"])) {
                fixedUrlString = [fixedUrlString stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
                fixedUrlString = [fixedUrlString stringByReplacingOccurrencesOfString:@"https:/" withString:@"https://"];
                NSURL *fixedUrl = [NSURL URLWithString:fixedUrlString];
                originalHost = fixedUrl.host;
            }
        }
        
        // 自定义解析IP并替换原域名，同时添加Host头
        if (originalHost && ![request.URL.host containsString:@"127.0.0"]) {
            if ([SkyShield shareInstance].dohLists && [SkyShield shareInstance].dohLists.count > 0) {
                // 添加原始域名作为Host头
                [request addValue:request.URL.host forHTTPHeaderField:@"Host"];
                
                // 替换URL中的域名为解析后的IP
                NSString *requestUrlS = request.URL.absoluteString;
                if (requestUrlS) {
                    NSString *replaceHostUrl = [[SkyShield shareInstance] replaceUrlHostToDNS:requestUrlS];
                    NSURL *domainURL1 = [NSURL URLWithString:replaceHostUrl];
                    if (domainURL1) {
                        request.URL = domainURL1;
                    }
                }
            }
        }
        
        [NSURLConnection connectionWithRequest:request delegate:self];
        self.downBTN.hidden = YES;
        self.downL.hidden = NO;
        return;
    }
        else{
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[loadPath,_model.songid] forKeys:@[@"music",@"lrc"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"wangminxindemusicplay" object:nil userInfo:dic];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancle" object:nil];
     }
}
// 处理SSL证书验证
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // 对于自定义解析的IP地址，信任所有证书
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        
        // 创建SSL策略，并设置为信任所有证书
        SecPolicyRef policy = SecPolicyCreateSSL(true, (__bridge CFStringRef)challenge.protectionSpace.host);
        SecTrustSetPolicies(serverTrust, policy);
        CFRelease(policy);
        
        // 评估证书信任
        SecTrustResultType trustResult;
        OSStatus status = SecTrustEvaluate(serverTrust, &trustResult);
        
        // 无条件信任证书
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    } else {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

//接收到服务器响应的时候开始调用这个方法
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    musicData = [NSMutableData data];
    allLength = [response expectedContentLength];//返回服务器链接数据的有效大小
}
//开始进行数据传输的时候执行这个方法
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [musicData appendData:data];
    currentLength += data.length;
//    NSString *string = [[NSString stringWithFormat:@"%f",(currentLength/allLength)] substringToIndex:3];
    NSString *string = [NSString stringWithFormat:@"%d",(int)(currentLength*100/allLength)];

    NSString *string2 = [string stringByAppendingPathComponent:@"%"];
    
//    NSString *downloadString = connection.currentRequest.URL.absoluteString;
    
    self.downL.text = string2;
}
 //数据传输完成的时候执行这个方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"已经完成数据的接收-------------");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    musicPath = [docDir stringByAppendingFormat:@"/%@*%@*%@.mp3",_model.songid,_model.songname,_model.artistname];
   
    if ([connection.originalRequest.URL.absoluteString.lastPathComponent containsString:@".aes"]) {
        if([[FFAES decryptData:musicData key:KAESKEY] writeToFile:musicPath atomically:YES]){
            NSLog(@"%@", YZMsg(@"保存成功"));
        }else{
            NSLog(@"保存失败");
        }
    }else{
        if([musicData writeToFile:musicPath atomically:YES]){
            NSLog(@"%@", YZMsg(@"保存成功"));
        }else{
            NSLog(@"保存失败");
        }
    }
    
   
    
    /*
    NSLog(@"%@*******************",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/audio.mp3"]);
     */
     [self.downBTN setTitle:YZMsg(@"musicView_choise") forState:UIControlStateNormal];
     self.downBTN.hidden = NO;
     self.downL.hidden = YES;
     self.isDown = NO;
}

//数据传输错误的时候执行这个方法
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"请求错误的时候  %@",[error localizedDescription]);
    
}
-(void)dealloc{
//    [[NSNotificationCenter defaultCenter]removeObserver:@"wangminxindemusicplay"];
//    [[NSNotificationCenter defaultCenter]removeObserver:@"cancle"];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"wangminxindemusicplay" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"cancle" object:nil];


}
@end
