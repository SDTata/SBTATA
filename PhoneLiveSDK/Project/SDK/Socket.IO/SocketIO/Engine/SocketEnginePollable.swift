//
//  SocketEnginePollable.swift
//  Socket.IO-Client-Swift
//
//  Created by Erik Little on 1/15/16.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

/// Protocol that is used to implement socket.io polling support
public protocol SocketEnginePollable : SocketEngineSpec {
    // MARK: Properties

    /// `true` If engine's session has been invalidated.
    var invalidated: Bool { get }

    /// A queue of engine.io messages waiting for POSTing
    ///
    /// **You should not touch this directly**
    var postWait: [Post] { get set }

    /// The URLSession that will be used for polling.
    var session: URLSession? { get }

    /// `true` if there is an outstanding poll. Trying to poll before the first is done will cause socket.io to
    /// disconnect us.
    ///
    /// **Do not touch this directly**
    var waitingForPoll: Bool { get set }

    /// `true` if there is an outstanding post. Trying to post before the first is done will cause socket.io to
    /// disconnect us.
    ///
    /// **Do not touch this directly**
    var waitingForPost: Bool { get set }

    // MARK: Methods

    /// Call to send a long-polling request.
    ///
    /// You shouldn't need to call this directly, the engine should automatically maintain a long-poll request.
    func doPoll()

    /// Sends an engine.io message through the polling transport.
    ///
    /// You shouldn't call this directly, instead call the `write` method on `SocketEngine`.
    ///
    /// - parameter message: The message to send.
    /// - parameter withType: The type of message to send.
    /// - parameter withData: The data associated with this message.
    func sendPollMessage(_ message: String, withType type: SocketEnginePacketType, withData datas: [Data], completion: (() -> ())?)

    /// Call to stop polling and invalidate the URLSession.
    func stopPolling()
}

// Default polling methods
extension SocketEnginePollable {
    func createRequestForPostWithPostWait() -> URLRequest {
        defer {
            for packet in postWait { packet.completion?() }
            postWait.removeAll(keepingCapacity: true)
        }

        var postStr = ""

        for packet in postWait {
            postStr += "\(packet.msg.utf16.count):\(packet.msg)"
        }

        DefaultSocketLogger.Logger.log("Created POST string: \(postStr)", type: "SocketEnginePolling")

        var req = URLRequest(url: urlPollingWithSid)
        let postData = postStr.data(using: .utf8, allowLossyConversion: false)!

        addHeaders(to: &req)

        req.httpMethod = "POST"
        req.setValue("text/plain; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        req.httpBody = postData
        req.setValue(String(postData.count), forHTTPHeaderField: "Content-Length")

        return req
    }

    /// Call to send a long-polling request.
    ///
    /// You shouldn't need to call this directly, the engine should automatically maintain a long-poll request.
    public func doPoll() {
        guard polling && !waitingForPoll && connected && !closed else { return }

        var req = URLRequest(url: urlPollingWithSid)
        addHeaders(to: &req)

        doLongPoll(for: req)
    }

    func doRequest(for req: URLRequest, callbackWith callback: @escaping (Data?, URLResponse?, Error?) -> ()) {
        guard polling && !closed && !invalidated && !fastUpgrade else { return }
        
        // 创建可变请求对象
        var mutableReq = req
        
        // 直接在这里处理 DNS 解析和 Host 头设置
        if let skyShield = SkyShield.shareInstance(), skyShield.dohLists != nil, skyShield.dohLists.count > 0,
           let originalURL = req.url {
            
            // 保存原始域名
            var originalHost = originalURL.host
            
            // 处理 host 为 nil 的情况
            if originalHost == nil {
                var fixedUrlString = originalURL.absoluteString
                fixedUrlString = fixedUrlString.replacingOccurrences(of: "http:///", with: "http://")
                fixedUrlString = fixedUrlString.replacingOccurrences(of: "https:///", with: "https://")
                
                if (fixedUrlString.hasPrefix("http:/") && !fixedUrlString.hasPrefix("http://")) || 
                   (fixedUrlString.hasPrefix("https:/") && !fixedUrlString.hasPrefix("https://")) {
                    fixedUrlString = fixedUrlString.replacingOccurrences(of: "http:/", with: "http://")
                    fixedUrlString = fixedUrlString.replacingOccurrences(of: "https:/", with: "https://")
                    if let fixedUrl = URL(string: fixedUrlString) {
                        originalHost = fixedUrl.host
                    }
                }
            }
            
            if let originalHost = originalHost { // 确保有有效的 host
                // 存储原始域名供证书验证使用
                // 如枟当前对象就是SocketEngine，直接设置属性
                if self is SocketEngine {
                    (self as! SocketEngine).originalHost = originalHost
                }
                
                // 使用 SkyShield 进行 DNS 解析
                // 直接使用host而不是整个URL进行解析
                if let resolvedHost = skyShield.replaceUrlHost(toDNS: originalHost),
                   originalHost != resolvedHost {
                    // 构建新的URL
                    var components = URLComponents(url: originalURL, resolvingAgainstBaseURL: false)!
                    components.host = resolvedHost
                    if let resolvedURL = components.url {
                        
                        DefaultSocketLogger.Logger.log("DNS resolved: \(originalURL) -> \(resolvedURL)", type: "SocketEnginePolling")
                        
                        // 更新请求 URL
                        mutableReq.url = resolvedURL
                        
                        // 添加原始域名作为 Host 头
                        DefaultSocketLogger.Logger.log("Adding Host header: \(originalHost) for polling request", type: "SocketEnginePolling")
                        mutableReq.addValue(originalHost, forHTTPHeaderField: "Host")
                        
                        // 设置请求超时时间更长，防止网络不稳定导致连接失败
                        mutableReq.timeoutInterval = 60.0
                        
                        // 设置缓存策略为不使用缓存，确保每次请求都是新的
                        mutableReq.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                    }
                }
            }
        }

        DefaultSocketLogger.Logger.log("Doing polling \(mutableReq.httpMethod ?? "") \(mutableReq)", type: "SocketEnginePolling")

        session?.dataTask(with: mutableReq, completionHandler: callback).resume()
    }

    func doLongPoll(for req: URLRequest) {
        waitingForPoll = true

        doRequest(for: req) {[weak self] data, res, err in
            guard let this = self, this.polling else { return }
            guard let data = data, let res = res as? HTTPURLResponse, res.statusCode == 200 else {
                if let err = err {
                    DefaultSocketLogger.Logger.error(err.localizedDescription, type: "SocketEnginePolling")
                } else {
                    DefaultSocketLogger.Logger.error("Error during long poll request", type: "SocketEnginePolling")
                }

                if this.polling {
                    this.didError(reason: err?.localizedDescription ?? "Error")
                }

                return
            }

            DefaultSocketLogger.Logger.log("Got polling response", type: "SocketEnginePolling")

            if let str = String(data: data, encoding: .utf8) {
                this.parsePollingMessage(str)
            }

            this.waitingForPoll = false

            if this.fastUpgrade {
                this.doFastUpgrade()
            } else if !this.closed && this.polling {
                this.doPoll()
            }
        }
    }

    private func flushWaitingForPost() {
        guard postWait.count != 0 && connected else { return }
        guard polling else {
            flushWaitingForPostToWebSocket()

            return
        }

        let req = createRequestForPostWithPostWait()

        waitingForPost = true

        DefaultSocketLogger.Logger.log("POSTing", type: "SocketEnginePolling")

        doRequest(for: req) {[weak self] _, res, err in
            guard let this = self else { return }
            guard let res = res as? HTTPURLResponse, res.statusCode == 200 else {
                if let err = err {
                    DefaultSocketLogger.Logger.error(err.localizedDescription, type: "SocketEnginePolling")
                } else {
                    DefaultSocketLogger.Logger.error("Error flushing waiting posts", type: "SocketEnginePolling")
                }

                if this.polling {
                    this.didError(reason: err?.localizedDescription ?? "Error")
                }

                return
            }

            this.waitingForPost = false

            if !this.fastUpgrade {
                this.flushWaitingForPost()
                this.doPoll()
            }
        }
    }

    func parsePollingMessage(_ str: String) {
        guard str.count != 1 else { return }

        DefaultSocketLogger.Logger.log("Got poll message: \(str)", type: "SocketEnginePolling")

        var reader = SocketStringReader(message: str)

        while reader.hasNext {
            if let n = Int(reader.readUntilOccurence(of: ":")) {
                parseEngineMessage(reader.read(count: n))
            } else {
                parseEngineMessage(str)
                break
            }
        }
    }

    /// Sends an engine.io message through the polling transport.
    ///
    /// You shouldn't call this directly, instead call the `write` method on `SocketEngine`.
    ///
    /// - parameter message: The message to send.
    /// - parameter withType: The type of message to send.
    /// - parameter withData: The data associated with this message.
    /// - parameter completion: Callback called on transport write completion.
    public func sendPollMessage(_ message: String, withType type: SocketEnginePacketType, withData datas: [Data], completion: (() -> ())? = nil) {
        DefaultSocketLogger.Logger.log("Sending poll: \(message) as type: \(type.rawValue)", type: "SocketEnginePolling")

        postWait.append((String(type.rawValue) + message, completion))

        for data in datas {
            if case let .right(bin) = createBinaryDataForSend(using: data) {
                postWait.append((bin, {}))
            }
        }

        if !waitingForPost {
            flushWaitingForPost()
        }
    }

    /// Call to stop polling and invalidate the URLSession.
    public func stopPolling() {
        waitingForPoll = false
        waitingForPost = false
        session?.finishTasksAndInvalidate()
    }
}

// 添加URLSessionDelegate扩展，确保在使用SocketEnginePollable协议时也能处理证书验证
extension SocketEnginePollable where Self: URLSessionDelegate {
    /// 处理SSL证书验证的辅助方法
    func handleSSLCertificateValidation(session: URLSession, challenge: URLAuthenticationChallenge, originalHost: String?, selfSigned: Bool, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        DefaultSocketLogger.Logger.log("Handling SSL certificate validation in SocketEnginePollable", type: "SocketEnginePolling")
        
        // 获取服务器信任对象
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            DefaultSocketLogger.Logger.error("No server trust found for authentication challenge", type: "SocketEnginePolling")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // 获取当前连接的主机名
        let host = challenge.protectionSpace.host
        
        // 检测IP地址模式
        let ipv4Pattern = "^\\d+\\.\\d+\\.\\d+\\.\\d+$"
        let ipv6Pattern = "^\\[?([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}\\]?$"
        let isIPv4Address = host.range(of: ipv4Pattern, options: .regularExpression) != nil
        let isIPv6Address = host.range(of: ipv6Pattern, options: .regularExpression) != nil
        let isIPAddress = isIPv4Address || isIPv6Address
        
        // 无条件信任所有证书，特别是对IP地址的请求或者有原始域名的请求
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
        
        if isIPAddress || originalHost != nil {
            DefaultSocketLogger.Logger.log("Trust all certificates for IP address or custom host. Host: \(host), Original Host: \(originalHost ?? "nil")", type: "SocketEnginePolling")
        } else {
            DefaultSocketLogger.Logger.log("Trust certificate for host: \(host)", type: "SocketEnginePolling")
        }
    }
}
