//
//  ViewController.swift
//  web3-demo2
//
//  Created by Byurhan Beyzat on 19.10.22.
//

import UIKit
import WebKit
import WKWebViewJavascriptBridge

struct RelayerPayload: Codable {
    let tosHash: String
    let from: String
    let signature: String
}

struct Wallet: Codable {
    let address: String
    let phrase: String
    let publicEncKey: String
    let publicKey: String
    let secretEncKey: String
    let secretKey: String
}

class ViewController: UIViewController {
    private let relayUrl: String = "https://gravity-relay.recheck.io"
    private let termsOfServiceStringified: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
    
    
    var bridge: WKWebViewJavascriptBridge!
    let webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())

    let registerUserBtn = UIButton(type: .roundedRect)
    let verifyTermsBtn = UIButton(type: .roundedRect)
    let signTermsBtn = UIButton(type: .roundedRect)
    
    var wallet: Wallet = Wallet(address: "", phrase: "", publicEncKey: "", publicKey: "", secretEncKey: "", secretKey: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup webView
        webView.frame = view.bounds
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // setup btns
        registerUserBtn.setTitle("Create Identity", for: .normal)
        registerUserBtn.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
        registerUserBtn.frame = CGRect(x: 120, y: 300, width: UIScreen.main.bounds.size.width * 0.4, height: 35)
        view.insertSubview(registerUserBtn, aboveSubview: webView)
        
        signTermsBtn.setTitle("Sign Terms", for: .normal)
        signTermsBtn.addTarget(self, action: #selector(signTerms), for: .touchUpInside)
        signTermsBtn.frame = CGRect(x: 120, y: 340, width: UIScreen.main.bounds.size.width * 0.4, height: 35)
        view.insertSubview(signTermsBtn, aboveSubview: webView)
        
        verifyTermsBtn.setTitle("Verify Terms", for: .normal)
        verifyTermsBtn.addTarget(self, action: #selector(verifyTermsSignature), for: .touchUpInside)
        verifyTermsBtn.frame = CGRect(x: 120, y: 380, width: UIScreen.main.bounds.size.width * 0.4, height: 35)
        view.insertSubview(verifyTermsBtn, aboveSubview: webView)
    
        
        // setup bridge
        bridge = WKWebViewJavascriptBridge(webView: webView)
        bridge.isLogEnable = true
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecheckLibrary()
    }
    
    func loadRecheckLibrary() {
        enum LoadDemoPageError: Error {
            case nilPath
        }
        
        do {
            guard let pagePath = Bundle.main.path(forResource: "recheck-clientjs", ofType: "html") else {
                throw LoadDemoPageError.nilPath
            }
            let pageHtml = try String(contentsOfFile: pagePath, encoding: .utf8)
            let baseURL = URL(fileURLWithPath: pagePath)
            webView.loadHTMLString(pageHtml, baseURL: baseURL)
            print("test")
        } catch LoadDemoPageError.nilPath {
            print("webView loadDemoPage error: pagePath is nil")
        } catch let error {
            print("webView loadDemoPage error: \(error)")
        }
    }
    
    @objc func registerUser() {
        // Init library with NEAR chain
        bridge.call(handlerName: "init")
        
        // Parameters:
        // for import/recover account pass 12 words
        // For creating new keys just pass "null" as string
        let params = "arrest flat december acid blur alcohol obscure auto admit pass bargain ready"
        
        bridge.call(handlerName: "createKeys", data: params, callback: { (response) in
            if (response == nil) {
                return
            }
            
            // TODO: Had problems with casting Any? to type Wallet - please do it in a proper way
            let data = response as? [String: Any]
            
            self.wallet = Wallet(
                address: data.unsafelyUnwrapped["address"] as! String,
                phrase: data.unsafelyUnwrapped["phrase"] as! String,
                publicEncKey: data.unsafelyUnwrapped["publicEncKey"] as! String,
                publicKey: data.unsafelyUnwrapped["publicKey"] as! String,
                secretEncKey: data.unsafelyUnwrapped["secretEncKey"] as! String,
                secretKey: data.unsafelyUnwrapped["secretKey"] as! String
            )
            
            do {
                let jsonData = try JSONEncoder().encode(self.wallet)
                let stringifiedWallet = String(data: jsonData, encoding: .utf8)
                
                // encrypting user's keys
                let encryptedString = AES256().encryptString(data: stringifiedWallet!)
                print("encryptedString", encryptedString)
                // TODO: Store encryptedString in backend
                
                // Decrypting keys
                let decryptedKeys = AES256().decryptString(encryptedString: encryptedString)
                print("decryptedKeys", decryptedKeys)
            } catch {
              print("Failed")
            }
        })
    }
    
    @objc func signTerms() {
        var payload = RelayerPayload(tosHash: "", from: "", signature: "")
        let tosHash: String = "0x0000000000000000000000000000000000000000"
        
        // Prepare params for signing with user's identity
        let params = ["message": tosHash, "secretKey": self.wallet.secretKey]
        
        // Sign message (tosHash) and submit RelayerPayload to the relayer
        self.bridge.call(handlerName: "signMessage", data: params, callback: { (signature) in
            if (signature != nil) {
                print("Signature", signature as! String)
                payload = RelayerPayload(tosHash: tosHash, from: self.wallet.address, signature: signature.unsafelyUnwrapped as! String)
                submitRelayRequest(object: payload)
            }
        })
        
        func submitRelayRequest(object: RelayerPayload) {
            do {
                let jsonData = try JSONEncoder().encode(object)
                print(String(data: jsonData, encoding: .utf8) as Any)
                let url = URL(string: relayUrl + "/signTerms")!
                var request = URLRequest(url: url)
                
                request.httpBody = jsonData
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard
                        let data = data,                              // is there data
                        let response = response as? HTTPURLResponse,  // is there HTTP response
                        200 ..< 300 ~= response.statusCode,           // is statusCode 2XX
                        error == nil                                  // was there no error
                    else {
                        return
                    }
                    
                    let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                    print("Tx response: ", responseObject as Any)
                }

                task.resume()
            } catch {
                print(error)
            }
        }
    }
    
    @objc func verifyTermsSignature() {
        let tosHash: String = "0x0000000000000000000000000000000000000000"
        
        var components = URLComponents(string: relayUrl + "/verifySignature")!
        components.queryItems = [
            URLQueryItem(name: "tosHash", value: tosHash),
            URLQueryItem(name: "pubKey", value: wallet.publicKey)
        ]
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")

        var request = URLRequest(url: components.url!)

        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,                              // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                200 ..< 300 ~= response.statusCode,           // is statusCode 2XX
                error == nil                                  // was there no error
            else {
                return
            }
            
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            print("Verify Signature Response: ", responseObject as Any)
        }

        task.resume()
        
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        print("webViewDidStartLoad")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        print("webViewDidFinishLoad")
    }
}
