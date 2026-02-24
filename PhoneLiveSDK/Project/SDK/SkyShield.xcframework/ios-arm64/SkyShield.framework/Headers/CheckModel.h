//
//  CheckModel.h
//  SkyShieldDemo
//
//  Created by Co co on 2024/11/26.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface SkyRequestModel : NSObject

/** 请求的路径URL */
@property (nonatomic, strong) NSString *pathUrl;
/** 请求头字典 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *headers;

/** 请求参数字典 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *params;

@end


/**
 * 域名验证回调block类型定义
 * @param dataResponse API请求成功后返回的数据
 * @param response 请求的响应对象
 * @return BOOL 验证结果，YES表示验证通过，NO表示验证失败
 */
typedef BOOL (^DomainVerifyCallback)(NSData *dataResponse,NSURLResponse *response);


typedef SkyRequestModel* _Nullable (^RequestCallback)(void);


/**
 * 辅助域名自定义API接口检测的模型类
 * 用于防止域名被劫持，通过自定义API接口进行域名安全性验证
 */
@interface CheckModel : NSObject



/** 请求方法，YES表示POST，NO表示GET */
@property (nonatomic, assign) BOOL method_post;



/** 验证回调block，用于检测请求结果 */
@property (nonatomic, copy) DomainVerifyCallback verifyCallback;

/** 验证回调block，用于检测请求结果 */
@property (nonatomic, copy) RequestCallback requestCallback;


/**
 * 初始化CheckModel实例
 * @param methodPost 请求方法，YES表示POST，NO表示GET
 * @param requestCallback 请求头
 * @param callback 验证回调block
 * @return CheckModel实例
 */
- (instancetype)initWithMethodPost:(BOOL)methodPost 
                   requestCallback:(RequestCallback)requestCallback
                verifyCallback:(DomainVerifyCallback)callback;

@end





NS_ASSUME_NONNULL_END
