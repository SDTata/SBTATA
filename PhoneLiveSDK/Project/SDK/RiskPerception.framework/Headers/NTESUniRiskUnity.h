//
//  NTESUniRiskUnity.h
//  RiskPerception
//
//  Created by Netease on 2022/10/8.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NTESRiskUniPerception.h"
#pragma mark - Interfaces for Unity

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*initCallbackC)(int code, const char *msg, const char *content);

typedef void (*tokenBlockC)(const char *token, NSInteger code, const char *codeStr, const char *businessId);

// 初始化
extern void ___initWithProductId(const char *productId, initCallbackC callback);

// 获取token
extern int ___getToken(const char * bussinessId, int timeout, unsigned char **out, int *outLen, unsigned char **codeStr, int *codeStrOutLen);

// 异步获取token
extern void ___getTokenAsync(const char * bussinessId, int timeout, tokenBlockC callback);

// 设置账号角色信息
extern int ___setRoleInfo(const char *businessId, const char *roleId, const char *roleName, const char *roleAccount, const char *roleServer, int serverid, const char *gameJson);

// 退出登陆
extern void ___logOut(void);

// 交互接口
extern const char * ___ioctl(RequestCmdID request, const char *data);

#pragma mark - Configuration Interfaces for Unity

// 设置透传ip和端口，透传2.0
extern void ___setTransIP(const char *ip, int32_t port);

// 设置服务器所属区域
extern void ___setServerType(int type);

// 设置渠道信息，供用户传入该app的渠道信息（App Store）
extern void ___setChannel(const char *channel);

// 设置额外信息，用户希望我们在数据上报中包含的额外信息，使用该接口设置，可多次调用
extern void ___setExtraData(const char *value, const char *key);

// 设置代理闪退模式。（闪退仅发生在数据上报失败的情况下）
extern void ___setVPNCrashType(int type);

// 设置访问域名
extern void ___setHost(const char *host);

#pragma mark - Util Interfaces for Unity

// 数据签名接口
extern const char * ___getDataSign(const char *data);

// 白盒加密 V2 返回字符串
extern int ___safeCommToServer(int alg, unsigned char *inputData, int dataSize, unsigned char **out, int *outLen);
// 白盒加密 V2 返回二进制
extern int ___safeCommToServerByte(int alg, unsigned char *inputData, int dataSize, unsigned char **out, int *outLen);
// 白盒解密 V2 密文字符串
extern int ___safeCommFromServer(int alg, int timeout, unsigned char *inputData, int dataSize, unsigned char **out, int *outLen);
// 白盒解密 V2 密文二进制
extern int ___safeCommFromServerByte(int alg, int timeout, unsigned char *inputData, int dataSize, unsigned char **out, int *outLen);

#pragma mark - 模拟点击AI识别接口
// 模拟点击AI识别 开启数据采集
extern void ___registerTouchEvent(unsigned long gameplayId, unsigned long sceneId);
// 模拟点击AI识别 关闭数据采集
extern void ___unregisterTouchEvent(void);

// 提供释放方法
extern void ___safeFree(unsigned char **out);


#ifdef __cplusplus
}
#endif

#pragma mark - Unity.h


