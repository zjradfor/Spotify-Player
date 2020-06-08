//
//  AuthViewController.swift
//  SpotifyKitDemo
//
//  Created by Zach Radford on 2020-06-07.
//  Copyright © 2020 Zach Radford. All rights reserved.
//

import UIKit

protocol AuthCallback {
    func didDismiss()
}

class AuthViewController: UIViewController {

    @IBOutlet weak var connectButton: UIButton!
    
    var delegate: AuthCallback?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        connectButton.layer.cornerRadius = 20
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc
    func didBecomeActive() {
        if spotifyManager.hasToken {
            delegate?.didDismiss()
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func connectPressed(_ sender: Any) {
        spotifyManager.authorize()
    }
}
