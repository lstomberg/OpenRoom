//
//  WebViewAuthenticationTesting.swift
//
//
//  Created by Lucas Stomberg on 2/26/21.
//

import Foundation
import SwiftUI

// MARK: Testing WebViewAuthentication

public struct WebViewAuthenticationTesting : View {
    @State private var sessionStarted: Bool = false
    
    @SceneStorage("WebViewAuthenticationTesting.urlString")
    private var urlString = "https://"
    
    @SceneStorage("WebViewAuthenticationTesting.redirectScheme")
    private var redirectScheme = "https://mobileapp.epic.com/SAML/redirect"
    
    @SceneStorage("WebViewAuthenticationTesting.privateBrowsing")
    private var privateBrowsing = true
    
    private var startButtonEnabled: Bool {
        guard let url = URL(string: urlString),
              url.scheme != nil,
              url.path.count > 0,
              redirectScheme.count > 0 else {
            return false
        }
        return true
    }
    
    // Public initializer
    public init() { }
    
    // View
    public var body: some View {
        
        Form {
            
            WebViewAuthenticationSettings(
                urlString: $urlString,
                redirectScheme: $redirectScheme,
                privateBrowsing: $privateBrowsing)
            
            Button(action: {
                sessionStarted = true
            }, label: {
                HStack {
                    Spacer()
                    Text("Start")
                    Spacer()
                }
            })
            .disabled(!startButtonEnabled)
            
        }.fullScreenCover(isPresented: $sessionStarted) {
            self.webViewAuthenticationView()
        }
    }
    
    private func webViewAuthenticationView() -> WebViewAuthentication {
        
        let url = URL(string: urlString)!
        let configuration = WebViewAuthenticationConfiguration(
            url: url,
            redirectScheme: redirectScheme,
            completionHandler: { (url, error) in
                print(url as Any, error as Any)
            },
            prefersEphemeralWebBrowserSession: privateBrowsing)
        return WebViewAuthentication(configuration: configuration)
    }
}

// Settings Entry

private struct WebViewAuthenticationSettings : View {
    
    @Binding public var urlString: String
    @Binding public var redirectScheme: String
    @Binding public var privateBrowsing: Bool
    
    var body: some View {
        Section(header: Text("Configuration")) {
            FormTextField(
                "Auth endpoint",
                placeholder: "URL",
                text: $urlString)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding(.vertical, 8)
            FormTextField(
                "Redirect URI",
                text: $redirectScheme)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding(.vertical, 8)
            Toggle(
                "Private Browsing",
                isOn: $privateBrowsing)
                .padding(.vertical, 8)
        }
    }
}

