/*
 * Copyright (c) Rakuten Payment, Inc. All Rights Reserved.
 *
 * This program is the information asset which are handled
 * as "Strictly Confidential".
 * Permission of use is only admitted in Rakuten Payment, Inc.
 * If you don't have permission, MUST not be published,
 * broadcast, rewritten for broadcast or publication
 * or redistributed directly or indirectly in any medium.
 */

import SwiftUI
import UIKit
import WebKit
import Combine

class UIViewContainerView<ContentView: UIView>: UIView {
    var contentView: ContentView? {
        willSet {
            contentView?.removeFromSuperview()
        }
        didSet {
            if let contentView = contentView {
                addSubview(contentView)
                contentView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    contentView.topAnchor.constraint(equalTo: topAnchor),
                    contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
            }
        }
    }
}

struct WebView: View, UIViewRepresentable {
    public let webView: WKWebView
    public typealias UIViewType = UIViewContainerView<WKWebView>
    
    public init(webView: WKWebView) {
        self.webView = webView
    }
    
    public func makeUIView(context: UIViewRepresentableContext<WebView>) -> WebView.UIViewType {
        return UIViewContainerView()
    }
    
    public func updateUIView(_ uiView: WebView.UIViewType, context: UIViewRepresentableContext<WebView>) {
        // If its the same content view we don't need to update.
        if uiView.contentView !== webView {
            uiView.contentView = webView
        }
    }
}

class WebViewViewModel: ObservableObject {
    @Published var title: String?
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var estimatedProgress: Double = 0
    @Published var recentURL: URL?
    
    private var observers: [NSKeyValueObservation?] = []
    private var webviewDidChange = PassthroughSubject<Void, Never>()
    
    private(set) var webview: WKWebView
    private(set) var baseURL: URL
    
    init(url: URL) {
        baseURL = url
        webview = WebViewViewModel.createWebView()
        reload()
        setupObservers()
    }
    
    func reload() {
        webview.load(URLRequest(url: baseURL))
    }
    
    func goBack() {
        webview.goBack()
    }
    
    func goForward() {
        webview.goForward()
    }
    
    func loadWeb(_ url: URL) {
        baseURL = url
        webview.load(URLRequest(url: url))
    }
    
}

extension WebViewViewModel {
    static func createWebView() -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = false
        return WKWebView(frame: .zero, configuration: config)
    }
    
    fileprivate func setupObservers() {
        func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation? {
            return webview.observe(keyPath, options: [.prior, .new]) { [weak self] _, change in
                self?.objectWillChange.send()
                if change.isPrior {
                    self?.webviewDidChange.send()
                }
            }
        }
        observers = [
            subscriber(for: \.title),
            subscriber(for: \.url),
            subscriber(for: \.isLoading),
            subscriber(for: \.estimatedProgress),
            subscriber(for: \.hasOnlySecureContent),
            subscriber(for: \.serverTrust),
            subscriber(for: \.canGoBack),
            subscriber(for: \.canGoForward)
        ]
        
        let webViewNoti = self.webviewDidChange
            .compactMap { [weak self] in self?.webview }
            .share()
        
        webViewNoti.map { $0.title }.assign(to: &$title)
        webViewNoti.map { $0.canGoBack }.assign(to: &$canGoBack)
        webViewNoti.map { $0.canGoForward }.assign(to: &$canGoForward)
        webViewNoti.map { $0.estimatedProgress }.assign(to: &$estimatedProgress)
        webViewNoti.map { $0.estimatedProgress < 1 }.assign(to: &$isLoading)
        webViewNoti.map { $0.url }.assign(to: &$recentURL)
    }
}
