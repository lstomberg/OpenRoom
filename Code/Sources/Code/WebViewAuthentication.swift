//
//  WebViewAuthentication.swift
//  
//
//  Created by Lucas Stomberg on 2/26/21.
//

import AuthenticationServices
import Foundation
import SwiftUI
import UIKit
import WebKit


// MARK: Workflow entry point view

public struct WebViewAuthentication : View {
    
    public let configuration: WebViewAuthenticationConfiguration
    
    @Environment(\.presentationMode) var presentationMode
    
    public var body: some View {
        NavigationView {
            RedirectDetectingWebView(configuration: configuration)
                .navigationBarItems(leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                })
                .navigationTitle("Authentication")
        }
    }
}

// configuration object for authentication session

public struct WebViewAuthenticationConfiguration {
    public let url: URL
    public let redirectScheme: String
    public let completionHandler: ASWebAuthenticationSession.CompletionHandler
    public var prefersEphemeralWebBrowserSession: Bool
}

// MARK: Private UIKit implementation

// SwiftUI wrapper around VC
private struct RedirectDetectingWebView : UIViewControllerRepresentable {
    public let configuration: WebViewAuthenticationConfiguration
    
    // create view controller
    func makeUIViewController(context: Context) -> RedirectDetectingWebViewController {
        let vc = RedirectDetectingWebViewController()
        vc.configuration = configuration
        return vc
    }
    
    func updateUIViewController(_ uiViewController: RedirectDetectingWebViewController, context: Context) { }
}

// content VC
private class RedirectDetectingWebViewController : UIViewController, WKNavigationDelegate {
    
    /// The configuration object for the workflow
    public var configuration: WebViewAuthenticationConfiguration!
    
    /// internal web view.  This is set as the `view` property of this controller.
    private var webView: WKWebView!
    
    // configure view
    override func loadView() {

        let webView: WKWebView
        if configuration.prefersEphemeralWebBrowserSession {
            let configuration = WKWebViewConfiguration()
            configuration.websiteDataStore = .nonPersistent()
            webView = WKWebView(frame: .zero, configuration: configuration)
        } else {
            webView = WKWebView()
        }
        
        webView.navigationDelegate = self
        
        self.webView = webView
        self.view = webView
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                target: self,
                                                                action: #selector(cancelTapped))
    }
    
    // begin loading URL
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.load(URLRequest(url: configuration.url))
    }
    
    // cancel authentication
    @objc
    private func cancelTapped() {
        dismiss(animated: true) {
            self.configuration.completionHandler(nil, ASWebAuthenticationSessionError(.canceledLogin))
        }
    }
    
    // Detect redirect
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        
        guard let url = navigationAction.request.url,
              url.absoluteString.hasPrefix(configuration.redirectScheme) else {
            decisionHandler(.allow, preferences)
            return
        }
        
        decisionHandler(.cancel, preferences)
        configuration.completionHandler(url, nil)
    }
}

