//
//  AboutProgramViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class AboutProgramViewController: UIViewController, UIWebViewDelegate {

    var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = UIWebView(frame: UIScreen.main.bounds)
        webView.delegate = self
        view.addSubview(webView)
        if let url = URL(string: "https://waruc.github.io") {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
        self.navigationController?.navigationBar.tintColor = Colors.green
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
}
