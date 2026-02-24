//
//  EMASCurlWebProgressiveRender.h
//  EMASCurl
//
//  Created on 2025/11/09
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 渐进式渲染优化工具
 * 作用：注入JavaScript代码到HTML中，实现流式加载和渐进式渲染
 */
@interface EMASCurlWebProgressiveRender : NSObject

/**
 * 生成优化脚本
 * 包含：
 * - 禁用同步脚本加载阻塞
 * - 实现动态脚本加载（async）
 * - 延迟加载非关键资源
 * - 监听资源加载完成
 */
+ (NSString *)generateProgressiveRenderScript;

/**
 * 在 HTML 中注入优化脚本
 * @param html 原始 HTML 内容
 * @return 注入脚本后的 HTML
 */
+ (NSString *)injectProgressiveRenderScriptToHTML:(NSString *)html;

/**
 * 为非关键脚本标签添加 defer 属性
 * @param html 原始 HTML
 * @return 优化后的 HTML
 */
+ (NSString *)optimizeScriptTagsInHTML:(NSString *)html;

/**
 * 为图片添加 lazy loading 属性
 * @param html 原始 HTML
 * @return 优化后的 HTML
 */
+ (NSString *)optimizeImageTagsInHTML:(NSString *)html;

/**
 * 优化 CSS 加载，使其异步加载不阻塞渲染
 * @param html 原始 HTML
 * @return 优化后的 HTML
 */
+ (NSString *)optimizeCSSTagsInHTML:(NSString *)html;

@end

NS_ASSUME_NONNULL_END
