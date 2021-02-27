//
//  File.swift
//  
//
//  Created by Lucas Stomberg on 2/26/21.
//

import Foundation

struct SAMLURL {
    let xml: String
    let baseURL: String
    
    var request: URLRequest? {
        guard let encodedRequest = xml
            .data(using: .utf8)?
            .zlibCompressed()?
            .base64EncodedString()
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let samlurl = URL(string: "\(baseURL)?SAMLRequest=\(encodedRequest)") else {
            return nil
        }
        return URLRequest(url: samlurl)
    }
}

// MARK: AuthnRequest

public struct AuthnRequest {
    // static
    private let ID: String = with("E" + UUID().uuidString) { $0.removeLast() }
    private let issuerInstant = ISO8601DateFormatter().string(from: Date())
    let redirectURI = "https://mobileapp.epic.com/SAML/redirect"
    
    // dynamic
    var protocolBinding: Bindings = .post
    var issuerFormat: NameIdFormat = .entity
    var nameIDPolicyFormat: NameIdFormat = .unspecified
    var requestedAuthnContextComparison: AuthnContextComparison = .exact
    var authnContextClass: AuthnContextClass = .PASSWORD
    
    var destination = "https://login.microsoftonline.com/2a789914-be8c-49c8-9f76-a78c776ba89d/saml2"
    var issuerValue = "a9a0b19e-0128-4df6-9248-17a88ed32678" // app id, should be the Epic instance unique key
    
    // Didn't use in successful attempt
    var issuerNameQualifier = "asdf" // ??
    var issuerSPNameQualifier = "Epic" // ??
    
    // Can't use with Azure
    var nameIDFormat: NameIdFormat = .unspecified
    var userName = "lstomber"
    var userDomain = "epic.com"
    
    // Didn't use in successful attempt
    private let extensions = "<epic:Attribute Name=\"OS\">iOS</epic:Attribute>"
    
    // options
    var includeSubject: Boolean = .false
    var includeExtensions: Boolean = .false
    var includeIssuerNameQualifier: Boolean = .false
    var includeIssuerSPNameQualifier: Boolean = .false
}

// MARK: Computed AuthnRequest XML

extension AuthnRequest {
    
    // Compute xml
    public var xml: String {"""
        <?xml version="1.0" encoding="UTF-8"?>
        <samlp:AuthnRequest xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
          xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"
          xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
          xmlns:epic="urn:epic:names:tc:SAML:2.0:protocol:extensions"
          ID="\(ID)"
          Version="2.0"
          IssueInstant="\(issuerInstant)"
          Destination="\(destination)"
          ProtocolBinding="\(protocolBinding)"
          AssertionConsumerServiceURL="\(redirectURI)"
          ProviderName="Epic Testing">
          <saml:Issuer xmlns="urn:oasis:names:tc:SAML:2.0:assertion"
              \(includeIssuerNameQualifier.isTrue ? issuerNameQualifierAttribute : "")
              \(includeIssuerSPNameQualifier.isTrue ? issuerSPNameQualifierAttribute : "")
              Format="\(issuerFormat)">\(issuerValue)</saml:Issuer>
          \(includeExtensions.isTrue ? extensionsNode : "")
          \(includeSubject.isTrue ? subjectNode : "")
          <samlp:NameIDPolicy Format="\(nameIDPolicyFormat)" />
          <samlp:RequestedAuthnContext Comparison="\(requestedAuthnContextComparison)">
              <saml:AuthnContextClassRef>\(authnContextClass)</saml:AuthnContextClassRef>
          </samlp:RequestedAuthnContext>
        </samlp:AuthnRequest>
    """}
    
    // private helper
    private var subjectNode: String {"""
        <saml:Subject>
          <saml:NameID
            Format="\(nameIDFormat)"
            NameQualifier="\(userDomain)">\(userName)</saml:NameID>
        </saml:Subject>
    """}
    
    // private helper
    private var extensionsNode: String {"""
        <samlp:Extensions>\(extensions)</samlp:Extensions>
    """}
    
    // private helper
    private var issuerNameQualifierAttribute: String {"""
        NameQualifier="\(issuerNameQualifier)"
    """}
    
    // private helper
    private var issuerSPNameQualifierAttribute: String {"""
        SPNameQualifier="\(issuerSPNameQualifier)"
    """}
}

// MARK: AuthnResponse

struct AuthnResponse {
    let url: URL
    
    var xml: String? {
        guard let b64Data = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "SAMLResponse" })?
                .value?
                .removingPercentEncoding?
                .data(using: .utf8),
              let data = Data(base64Encoded: b64Data)?.zlibDecompressed(),
              let xml = String(data: data, encoding: .utf8) else {
            return nil
        }
        return xml
    }
}

// MARK: SAML2 Constants

enum Bindings : String {
    case redirect = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
    case post = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
}

enum NameIdFormat : String {
    case persistent = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
    case transient = "urn:oasis:names:tc:SAML:2.0:nameid-format:transient"
    case emailAddress = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
    case unspecified = "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified"
    case x509SubjectName = "urn:oasis:names:tc:SAML:1.1:nameid-format:X509SubjectName"
    case windowsDomainQualifiedName = "urn:oasis:names:tc:SAML:1.1:nameid-format:WindowsDomainQualifiedName"
    case kerberos = "urn:oasis:names:tc:SAML:2.0:nameid-format:kerberos"
    case entity = "urn:oasis:names:tc:SAML:2.0:nameid-format:entity"
}

enum AuthnContextComparison : String {
    case exact = "exact"
}

enum AuthnContextClass : String {
    case epcs = "urn:healthcare:saml:workflows:MOBILEEPCS"
    case INTERNET_PROTOCOL = "urn:oasis:names:tc:SAML:2.0:ac:classes:InternetProtocol"
    case INTERNET_PROTOCOL_PASSWORD = "urn:oasis:names:tc:SAML:2.0:ac:classes:InternetProtocolPassword"
    case KERBEROS = "urn:oasis:names:tc:SAML:2.0:ac:classes:Kerberos"
    case MOBILE_ONE_FACTOR_UNREGISTERED = "urn:oasis:names:tc:SAML:2.0:ac:classes:MobileOneFactorUnregistered"
    case MOBILE_TWO_FACTOR_UNREGISTERED = "urn:oasis:names:tc:SAML:2.0:ac:classes:MobileTwoFactorUnregistered"
    case MOBILE_ONE_FACTOR_CONTRACT = "urn:oasis:names:tc:SAML:2.0:ac:classes:MobileOneFactorContract"
    case MOBILE_TWO_FACTOR_CONTRACT = "urn:oasis:names:tc:SAML:2.0:ac:classes:MobileTwoFactorContract"
    case PASSWORD = "urn:oasis:names:tc:SAML:2.0:ac:classes:Password"
    case PASSWORD_PROTECTED_TRANSPORT = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    case PREVIOUS_SESSION = "urn:oasis:names:tc:SAML:2.0:ac:classes:PreviousSession"
    case X509 = "urn:oasis:names:tc:SAML:2.0:ac:classes:X509"
    case PGP = "urn:oasis:names:tc:SAML:2.0:ac:classes:PGP"
    case SPKI = "urn:oasis:names:tc:SAML:2.0:ac:classes:SPKI"
    case XMLDSIG = "urn:oasis:names:tc:SAML:2.0:ac:classes:XMLDSig"
    case SMARTCARD = "urn:oasis:names:tc:SAML:2.0:ac:classes:Smartcard"
    case SMARTCARD_PKI = "urn:oasis:names:tc:SAML:2.0:ac:classes:SmartcardPKI"
    case SOFTWARE_PKI = "urn:oasis:names:tc:SAML:2.0:ac:classes:SoftwarePKI"
    case TELEPHONY = "urn:oasis:names:tc:SAML:2.0:ac:classes:Telephony"
    case NOMAD_TELEPHONY = "urn:oasis:names:tc:SAML:2.0:ac:classes:NomadTelephony"
    case PERSONAL_TELEPHONY = "urn:oasis:names:tc:SAML:2.0:ac:classes:PersonalTelephony"
    case AUTHENTICATED_TELEPHONY = "urn:oasis:names:tc:SAML:2.0:ac:classes:AuthenticatedTelephony"
    case SECURED_REMOTE_PASSWORD = "urn:oasis:names:tc:SAML:2.0:ac:classes:SecureRemotePassword"
    case TLS_CLIENT = "urn:oasis:names:tc:SAML:2.0:ac:classes:TLSClient"
    case TIME_SYNC_TOKEN = "urn:oasis:names:tc:SAML:2.0:ac:classes:TimeSyncToken"
    case UNSPECIFIED = "urn:oasis:names:tc:SAML:2.0:ac:classes:unspecified"
}

enum Boolean {
    case `true`
    case `false`
    var isTrue: Bool {
        self == .true
    }
}
