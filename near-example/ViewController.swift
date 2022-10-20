//
//  ViewController.swift
//  web3-demo2
//
//  Created by Byurhan Beyzat on 19.10.22.
//

import UIKit
import WebKit
import WKWebViewJavascriptBridge

struct Wallet {
    let address: String;
    let phrase: String;
    let publicEncKey: String;
    let publicKey: String;
    let secretEncKey: String;
    let secretKey: String;
}

class ViewController: UIViewController {
    let webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
    var bridge: WKWebViewJavascriptBridge!
    
    let createWalletBtn = UIButton(type: .custom)
    
    private var wallet: Any = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup webView
        webView.frame = view.bounds
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // setup btns
        createWalletBtn.setTitle("Create Identity", for: .normal)
        createWalletBtn.addTarget(self, action: #selector(createWallet), for: .touchUpInside)
        createWalletBtn.backgroundColor = UIColor(cgColor: CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        createWalletBtn.frame = CGRect(x: 120, y: 400, width: UIScreen.main.bounds.size.width * 0.4, height: 35)
        view.insertSubview(createWalletBtn, aboveSubview: webView)
        
        // setup bridge
        bridge = WKWebViewJavascriptBridge(webView: webView)
        bridge.isLogEnable = true
        
        // Init library with NEAR chain
        bridge.call(handlerName: "init")
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
    
    @objc func createWallet() {
        bridge.call(handlerName: "createKeys", data: "null") { (response) in
            if (response != nil) {
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
            }
        }
    }    
    
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("webViewDidStartLoad")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webViewDidFinishLoad")
    }
}


