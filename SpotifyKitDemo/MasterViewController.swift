//
//  ViewController.swift
//  SpotifyKitDemo
//
//  Created by Zach Radford on 2020-06-02.
//  Copyright © 2020 Zach Radford. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
    
    var playerViewController: PlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let vc1 = children.first as? PlayerViewController else {
            fatalError("Could not get children")
        }
        
        playerViewController = vc1
    }
}

// MARK: Track Player delegate

extension MasterViewController: TrackPlayer {
    func playTrack(at index: Int) {
        playerViewController?.playTrack(at: index)
    }
}
