//
//  EMASCurlWebProgressiveRender.m
//  EMASCurl
//

#import "EMASCurlWebProgressiveRender.h"

@implementation EMASCurlWebProgressiveRender

/**
 * 生成渐进式渲染优化脚本
 * 核心思路：所有 JavaScript 都异步加载，不阻塞 DOM 渲染
 * 增强：资源加载完成回调机制
 */
+ (NSString *)generateProgressiveRenderScript {
    return @"<script type=\"text/javascript\">"
    "window.__emasProgressiveRender = {"
    "  startTime: new Date().getTime(),"
    "  resourcesLoaded: {},"
    "  resourcesLoadCallbacks: [],"
    "  init: function() {"
    "    console.log('✅ [EMASRender] Progressive rendering enabled');"
    "    if (document.readyState === 'loading') {"
    "      document.addEventListener('DOMContentLoaded', this.onDOMReady.bind(this));"
    "    } else {"
    "      this.onDOMReady();"
    "    }"
    "    window.addEventListener('load', this.onWindowLoad.bind(this));"
    "    this.setupResourceMonitoring();"
    "  },"
    "  setupResourceMonitoring: function() {"
    "    var self = this;"
    "    if (window.PerformanceObserver) {"
    "      try {"
    "        var observer = new PerformanceObserver(function(list) {"
    "          list.getEntries().forEach(function(entry) {"
    "            self.onResourceLoaded(entry);"
    "          });"
    "        });"
    "        observer.observe({entryTypes: ['resource']});"
    "      } catch(e) {}"
    "    }"
    "  },"
    "  onResourceLoaded: function(entry) {"
    "    var url = entry.name;"
    "    var duration = entry.duration;"
    "    console.log('📦 [EMASRender] Resource loaded: ' + url + ' (' + Math.round(duration) + 'ms)');"
    "    this.resourcesLoaded[url] = {duration: duration, timestamp: Date.now()};"
    "    this.notifyResourceLoadCallbacks(url, duration);"
    "  },"
    "  onResourceLoadCallback: function(callback) {"
    "    this.resourcesLoadCallbacks.push(callback);"
    "  },"
    "  notifyResourceLoadCallbacks: function(url, duration) {"
    "    this.resourcesLoadCallbacks.forEach(function(callback) {"
    "      try {"
    "        callback({url: url, duration: duration});"
    "      } catch(e) {}"
    "    });"
    "  },"
    "  onDOMReady: function() {"
    "    var elapsed = new Date().getTime() - this.startTime;"
    "    console.log('✅ [EMASRender] DOM Ready in ' + elapsed + 'ms');"
    "  },"
    "  onWindowLoad: function() {"
    "    var elapsed = new Date().getTime() - this.startTime;"
    "    console.log('✅ [EMASRender] Page fully loaded in ' + elapsed + 'ms');"
    "  }"
    "};"
    "window.__emasProgressiveRender.init();"
    "</script>";
}

/**
 * 在 HTML 中注入优化脚本
 */
+ (NSString *)injectProgressiveRenderScriptToHTML:(NSString *)html {
    if (!html || html.length == 0) {
        return html;
    }

    NSString *renderScript = [self generateProgressiveRenderScript];
    NSMutableString *optimizedHTML = [html mutableCopy];

    // 在 <head> 开始处注入脚本
    NSRange headRange = [optimizedHTML rangeOfString:@"<head" options:NSCaseInsensitiveSearch];
    if (headRange.location != NSNotFound) {
        NSRange endRange = [optimizedHTML rangeOfString:@">"
                                            options:0
                                              range:NSMakeRange(headRange.location, optimizedHTML.length - headRange.location)];
        if (endRange.location != NSNotFound) {
            NSUInteger insertPosition = endRange.location + endRange.length;
            [optimizedHTML insertString:renderScript atIndex:insertPosition];
            return optimizedHTML;
        }
    }

    return html;
}

/**
 * ✅ 异步并发加载优化 - 核心方案
 *
 * 关键思路：不按 HTML 标签顺序加载，而是：
 * 1. 移除 HTML 中所有外部 <script src> 和 <link rel="stylesheet"> 标签
 * 2. 在 body 底部注入一个脚本，用 Promise.all 并发加载所有资源
 * 3. HTML 立即完整渲染，所有资源并发加载
 *
 * 效果：完全异步渲染，不再有阻塞
 */
+ (NSString *)optimizeScriptTagsInHTML:(NSString *)html {
    if (!html || html.length == 0) {
        return html;
    }

    NSMutableString *optimizedHTML = [html mutableCopy];
    NSMutableArray *externalScripts = [NSMutableArray array];  // 收集所有外部脚本 URL
    NSMutableArray *externalStyles = [NSMutableArray array];   // 收集所有外部样式表 URL

    // ✅ 第一步：移除所有外部 <script src="..."> 标签
    // 支持多种格式：<script src="..."></script> 或 <script async src="..."></script> 等
    NSRegularExpression *scriptRegex = [NSRegularExpression regularExpressionWithPattern:@"<script[^>]*src=[\"']([^\"']*)[\"'][^>]*>.*?</script>"
                                                                               options:NSRegularExpressionDotMatchesLineSeparators | NSRegularExpressionCaseInsensitive
                                                                                 error:nil];

    NSArray *scriptMatches = [scriptRegex matchesInString:optimizedHTML options:0 range:NSMakeRange(0, optimizedHTML.length)];

    // 反向遍历，避免索引偏移
    for (NSTextCheckingResult *match in [scriptMatches reverseObjectEnumerator]) {
        // 直接从捕获组获取 src URL（正则中的 ([^\"']*) 是第一个捕获组）
        if (match.numberOfRanges > 1) {
            NSString *srcUrl = [optimizedHTML substringWithRange:[match rangeAtIndex:1]];
            [externalScripts addObject:srcUrl];
        }

        // 删除该脚本标签
        [optimizedHTML deleteCharactersInRange:match.range];
    }

    // ✅ 第二步：移除所有外部 <link rel="stylesheet"> 标签
    // 支持多种格式：<link rel="stylesheet" href="..."> 或 <link href="..." rel="stylesheet">
    NSRegularExpression *linkRegex = [NSRegularExpression regularExpressionWithPattern:@"<link[^>]*rel=[\"']stylesheet[\"'][^>]*>"
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];

    NSArray *linkMatches = [linkRegex matchesInString:optimizedHTML options:0 range:NSMakeRange(0, optimizedHTML.length)];

    // 反向遍历，避免索引偏移
    for (NSTextCheckingResult *match in [linkMatches reverseObjectEnumerator]) {
        NSString *linkTag = [optimizedHTML substringWithRange:match.range];

        // 提取 href URL - 支持单引号和双引号
        NSRegularExpression *hrefRegex = [NSRegularExpression regularExpressionWithPattern:@"href=[\"']([^\"']*)[\"']"
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:nil];
        NSArray *hrefMatches = [hrefRegex matchesInString:linkTag options:0 range:NSMakeRange(0, linkTag.length)];
        if (hrefMatches.count > 0) {
            NSTextCheckingResult *hrefMatch = hrefMatches[0];
            // 获取捕获组中的 URL（而不是整个匹配）
            if (hrefMatch.numberOfRanges > 1) {
                NSString *hrefUrl = [linkTag substringWithRange:[hrefMatch rangeAtIndex:1]];
                [externalStyles addObject:hrefUrl];
            }
        }

        // 删除该链接标签
        [optimizedHTML deleteCharactersInRange:match.range];
    }

    // ✅ 第三步：在 </body> 前注入并发加载脚本
    NSString *bodyCloseTag = @"</body>";
    NSRange bodyCloseRange = [optimizedHTML rangeOfString:bodyCloseTag options:NSBackwardsSearch];

    if (bodyCloseRange.location != NSNotFound) {
        NSMutableString *concurrentLoadScript = [NSMutableString string];
        [concurrentLoadScript appendString:@"\n<script>\n"];
        [concurrentLoadScript appendString:@"(function(){\n"];
        [concurrentLoadScript appendString:@"var allPromises=[];\n"];

        // ✅ 并发加载所有样式表
        for (NSString *styleUrl in externalStyles) {
            [concurrentLoadScript appendString:@"allPromises.push(new Promise(function(resolve){\n"];
            [concurrentLoadScript appendFormat:@"var link=document.createElement('link');\n"];
            [concurrentLoadScript appendFormat:@"link.rel='stylesheet';\n"];
            [concurrentLoadScript appendFormat:@"link.href='%@';\n", styleUrl];
            [concurrentLoadScript appendFormat:@"link.onload=link.onerror=function(){resolve();};\n"];
            [concurrentLoadScript appendFormat:@"document.head.appendChild(link);\n"];
            [concurrentLoadScript appendString:@"}));\n"];
        }

        // ✅ 并发加载所有脚本
        for (NSString *scriptUrl in externalScripts) {
            [concurrentLoadScript appendString:@"allPromises.push(new Promise(function(resolve){\n"];
            [concurrentLoadScript appendFormat:@"var script=document.createElement('script');\n"];
            [concurrentLoadScript appendFormat:@"script.src='%@';\n", scriptUrl];
            [concurrentLoadScript appendFormat:@"script.async=true;\n"];
            [concurrentLoadScript appendFormat:@"script.onload=script.onerror=function(){resolve();};\n"];
            [concurrentLoadScript appendFormat:@"document.body.appendChild(script);\n"];
            [concurrentLoadScript appendString:@"}));\n"];
        }

        [concurrentLoadScript appendString:@"// 所有资源并发加载，完成顺序不固定，但都不阻塞 DOM\n"];
        [concurrentLoadScript appendString:@"console.log('🚀 [AsyncRender] Loading ' + allPromises.length + ' external resources concurrently');\n"];
        [concurrentLoadScript appendString:@"})();\n"];
        [concurrentLoadScript appendString:@"</script>\n"];

        [optimizedHTML insertString:concurrentLoadScript atIndex:bodyCloseRange.location];
    }

    return optimizedHTML;
}

/**
 * 为所有图片添加 lazy loading
 * 不阻塞页面渲染
 */
+ (NSString *)optimizeImageTagsInHTML:(NSString *)html {
    if (!html || html.length == 0) {
        return html;
    }

    NSMutableString *optimizedHTML = [html mutableCopy];

    // 查找所有 <img> 标签
    NSRegularExpression *imgRegex = [NSRegularExpression regularExpressionWithPattern:@"<img[^>]*>" options:NSRegularExpressionCaseInsensitive error:nil];

    NSArray *matches = [imgRegex matchesInString:optimizedHTML options:0 range:NSMakeRange(0, optimizedHTML.length)];

    // 反向遍历以避免索引偏移
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSString *imgTag = [optimizedHTML substringWithRange:match.range];

        // 如果已经有 loading 属性，跳过
        if ([imgTag containsString:@" loading="]) {
            continue;
        }

        // ✅ 所有图片都使用 lazy loading
        NSString *optimizedTag = [imgTag stringByReplacingOccurrencesOfString:@">" withString:@" loading=\"lazy\">"];
        [optimizedHTML replaceCharactersInRange:match.range withString:optimizedTag];
    }

    return optimizedHTML;
}

/**
 * 优化 CSS 加载
 * 非关键 CSS 异步加载，不阻塞渲染
 */
+ (NSString *)optimizeCSSTagsInHTML:(NSString *)html {
    if (!html || html.length == 0) {
        return html;
    }

    NSMutableString *optimizedHTML = [html mutableCopy];

    // 查找所有 <link rel="stylesheet"> 标签
    NSRegularExpression *cssRegex = [NSRegularExpression regularExpressionWithPattern:@"<link[^>]*rel=[\"']stylesheet[\"'][^>]*>"
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];

    NSArray *matches = [cssRegex matchesInString:optimizedHTML options:0 range:NSMakeRange(0, optimizedHTML.length)];

    // 反向遍历以避免索引偏移
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSString *linkTag = [optimizedHTML substringWithRange:match.range];

        // 如果已经有特殊属性，跳过
        if ([linkTag containsString:@" media="] || [linkTag containsString:@"onload="]) {
            continue;
        }

        // ✅ 为 CSS 添加异步加载：media="print" 让浏览器不阻塞，onload 改为 all
        NSString *optimizedTag = [linkTag stringByReplacingOccurrencesOfString:@" href=" withString:@" media=\"print\" onload=\"this.media='all'\" href="];
        [optimizedHTML replaceCharactersInRange:match.range withString:optimizedTag];
    }

    return optimizedHTML;
}

@end
