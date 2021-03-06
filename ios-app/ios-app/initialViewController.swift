//
//  initialViewController.swift
//  ios-app
//
//  Created by iGuest on 5/5/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Eureka


class initialViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var greenLogIn: UIButton!
    @IBOutlet weak var greenSignUp: UIButton!
    
//    Scrolling:
//    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: 550))
//    var colors:[UIColor] = [UIColor.clear, UIColor.clear, UIColor.clear, UIColor.clear]
//    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
//    var pageControl : UIPageControl = UIPageControl(frame:CGRect(x: 86, y: 550, width: 200, height: 50))
    
    var player: AVPlayer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    @IBAction func signUpDylan(_ sender: UIButton) {
        performSegue(withIdentifier: "toAbout", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        video()

        greenLogIn.layer.cornerRadius = CGFloat(Constants.round)
        greenSignUp.layer.cornerRadius = CGFloat(Constants.round)
        
        greenLogIn.layer.borderWidth = 2
        greenLogIn.layer.borderColor = Colors.green.cgColor
        //BLERouter.sharedInstance.scan()


        
    }
    

    @IBAction func login(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToLogin", sender: self)
    }

    @IBAction func signUp(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToSignUp", sender: self)
    }
    
    func video() {
        // Load the video from the app bundle.
        let videoURL: URL = Bundle.main.url(forResource: "seattle", withExtension: "mov")!
        
        player = AVPlayer(url: videoURL)
        player?.actionAtItemEnd = .none
        player?.isMuted = true
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.zPosition = -1
        
        playerLayer.frame = view.frame
        
        view.layer.addSublayer(playerLayer)
        
        player?.play()
        
        //allow user music to continue playing
        let audioSession = AVAudioSession.sharedInstance()
        try!audioSession.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
        
        //loop video
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(initialViewController.loopVideo),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    func loopVideo() {
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    @IBAction func loginForm(_ sender: Any) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "signIn") as! signInFormViewController
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func signUpForm(_ sender: Any) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "signUp") as! userRegistrationFormViewController
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
}
