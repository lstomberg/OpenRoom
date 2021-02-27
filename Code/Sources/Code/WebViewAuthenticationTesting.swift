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
    
    @SceneStorage("WebViewAuthenticationTesting.destination")
    private var destination = "https://login.microsoftonline.com/2a789914-be8c-49c8-9f76-a78c776ba89d/saml2"
    
    @SceneStorage("WebViewAuthenticationTesting.redirectURI")
    private var redirectURI = AuthnRequest.redirectURI
    
    @SceneStorage("WebViewAuthenticationTesting.protocolBinding")
    private var protocolBinding: Bindings = .redirect
    
    @SceneStorage("WebViewAuthenticationTesting.issuerFormat")
    private var issuerFormat: NameIdFormat = .entity
    
    @SceneStorage("WebViewAuthenticationTesting.nameIDPolicyFormat")
    private var nameIDPolicyFormat: NameIdFormat = .unspecified
    
    @SceneStorage("WebViewAuthenticationTesting.requestedAuthnContextComparison")
    private var requestedAuthnContextComparison: AuthnContextComparison = .exact
    
    @SceneStorage("WebViewAuthenticationTesting.authnContextClass")
    private var authnContextClass: AuthnContextClass = .PASSWORD
    
    @SceneStorage("WebViewAuthenticationTesting.issuerValue")
    private var issuerValue = "a9a0b19e-0128-4df6-9248-17a88ed32678" // app id, should be the Epic instance unique key
    
    // Can't use with Azure
    @SceneStorage("WebViewAuthenticationTesting.nameIDFormat")
    private var nameIDFormat: NameIdFormat = .unspecified
    
    @SceneStorage("WebViewAuthenticationTesting.userName")
    private var userName = "lstomber"
    
    @SceneStorage("WebViewAuthenticationTesting.userDomain")
    private var userDomain = "epic.com"
    
    // options
    @SceneStorage("WebViewAuthenticationTesting.includeSubject")
    private var includeSubject: Boolean = .false
    
    @SceneStorage("WebViewAuthenticationTesting.includeExtensions")
    private var includeExtensions: Boolean = .false
    
    @SceneStorage("WebViewAuthenticationTesting.includeIssuerNameQualifier")
    private var includeIssuerNameQualifier: Boolean = .false
    
    @SceneStorage("WebViewAuthenticationTesting.includeIssuerSPNameQualifier")
    private var includeIssuerSPNameQualifier: Boolean = .false
    
    @SceneStorage("WebViewAuthenticationTesting.privateBrowsing")
    private var privateBrowsing = true
    
    private var startButtonEnabled: Bool {
        guard let url = URL(string: destination),
              url.scheme != nil,
              url.path.count > 0,
              redirectURI.count > 0 else {
            return false
        }
        return true
    }
    
    // Public initializer
    public init() { }
    
    // View
    public var body: some View {
        
        Form {
            // Main options
            Section(header: Text("Configuration")) {
                FormTextField("Destination", placeholder: "URL", text: $destination)
                FormTextField("Redirect URI", text: $redirectURI)
                FormTextField("App ID", text: $issuerValue)
            }
            
            // Extra options
            CollapsableSection(header: Text("Additional Options"), collapsed: true) {
                MenuEnumPicker("Include Subject", selected: $includeSubject)
                if includeSubject.isTrue {
                    HStack {
                        Divider().padding(.leading, 4)
                        VStack {
                            Group {
                                MenuEnumPicker("NameID Format", selected: $nameIDFormat)
                                FormTextField("Username", text: $userName)
                                FormTextField("User's Domain", text: $userDomain)
                            }
                        }
                    }
                }
                MenuEnumPicker("Binding", selected: $protocolBinding)
                MenuEnumPicker("Issuer Format", selected: $issuerFormat)
                MenuEnumPicker("NameIDPolicy Format", selected: $nameIDPolicyFormat)
            }
            
            // Even more options
            CollapsableSection(header: Text("Unlikely Options"), collapsed: true) {
                MenuEnumPicker("Include Extensions", selected: $includeExtensions)
                MenuEnumPicker("Include Issuer-NameQualifier", selected: $includeIssuerNameQualifier)
                MenuEnumPicker("Include Issuer-SPNameQualifier", selected: $includeIssuerSPNameQualifier)
                MenuEnumPicker("AuthnContext Comparison", selected: $requestedAuthnContextComparison)
                MenuEnumPicker("AuthnContext Class", selected: $authnContextClass)
                Toggle("Private Browsing", isOn: $privateBrowsing)
            }
            
            // Start
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
            
            
        }
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .padding(.vertical, 8)
        .pickerStyle(MenuPickerStyle())
        .fullScreenCover(isPresented: $sessionStarted) {
            self.webViewAuthenticationView()
        }
    }
    
    private func webViewAuthenticationView() -> WebViewAuthentication {

        let url = SAMLURL(xml: AuthnRequest().xml, baseURL: destination).request!.url!
        let configuration = WebViewAuthenticationConfiguration(
            url: url,
            redirectScheme: redirectURI,
            completionHandler: { (url, error) in
                print(url as Any, error as Any)
            },
            prefersEphemeralWebBrowserSession: privateBrowsing)
        return WebViewAuthentication(configuration: configuration)
    }
}

// Settings Entry

//private struct WebViewAuthenticationSettings : View {
//
//    @Binding public var urlString: String
//    @Binding public var redirectScheme: String
//    @Binding public var privateBrowsing: Bool
//
//    var body: some View {
//        Section(header: Text("Configuration")) {
//            FormTextField(
//                "Auth endpoint",
//                placeholder: "URL",
//                text: $urlString)
//                .disableAutocorrection(true)
//                .autocapitalization(.none)
//                .padding(.vertical, 8)
//            FormTextField(
//                "Redirect URI",
//                text: $redirectScheme)
//                .disableAutocorrection(true)
//                .autocapitalization(.none)
//                .padding(.vertical, 8)
//            EnumPicker("Binding", selected: $binding)
//            EnumPicker("NameID Format", selected: $nameIdFormat)
//            EnumPicker("AuthnContextClassRef", selected: $authClass)
//            Toggle(
//                "Private Browsing",
//                isOn: $privateBrowsing)
//                .padding(.vertical, 8)
//        }
//    }
//}

