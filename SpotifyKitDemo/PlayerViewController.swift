//
//  PlayerViewController.swift
//  SpotifyKitDemo
//
//  Created by Zach Radford on 2020-06-01.
//  Copyright © 2020 Zach Radford. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class PlayerViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    
    // MARK: - Properties
    
    let audioSession = AVAudioSession.sharedInstance()
    var isChangingProgress: Bool = false
    var canPlayTrack: Bool = false
    
    var player: SPTAudioStreamingController?
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNewSession()
    }
    
    // MARK: - Methods
    
    private func handleNewSession() {
        if player == nil {
            player = SPTAudioStreamingController.sharedInstance()
            player?.playbackDelegate = self
            player?.delegate = self
            try! player?.start(withClientId: ClientKeys.clientId)
            player?.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
            player?.login(withAccessToken: spotifyManager.getToken())
        }
    }
    
    // MARK: - Actions
    
    @IBAction func playPausePressed(_ sender: Any) {
        guard canPlayTrack, let isPlaying = player?.playbackState.isPlaying else { return }
        
        player?.setIsPlaying(!isPlaying, callback: nil)
        
        playPauseButton.setImage(UIImage(systemName: isPlaying ? "play" : "pause"), for: .normal)
    }
    
    @IBAction func nextPressed() {
        CurrentlyPlaying.index = CurrentlyPlaying.index + 1 < CurrentlyPlaying.playlist.count ? CurrentlyPlaying.index + 1 : 0
        playTrack(at: CurrentlyPlaying.index)
    }
    
    @IBAction func previousPressed() {
        CurrentlyPlaying.index = CurrentlyPlaying.index - 1 > 0 ? CurrentlyPlaying.index - 1 : 0
        playTrack(at: CurrentlyPlaying.index)
    }
    
    @IBAction func seekValue(_ sender: Any) {
        guard let duration = SPTAudioStreamingController.sharedInstance()?.metadata.currentTrack?.duration else { return }
        
        let dest = duration * Double(progressSlider.value)
        SPTAudioStreamingController.sharedInstance()?.seek(to: dest, callback: { _ in
            self.isChangingProgress = false
        })
    }
    
    @IBAction func progressTouched(_ sender: Any) {
        isChangingProgress = true
    }
    
    // MARK: - Audio playback methods
     
    func playTrack(at index: Int) {
        guard canPlayTrack else { return }
        
        player?.playSpotifyURI(CurrentlyPlaying.playlist[index].uri, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if error != nil {
                print(error!)
            }
        })
        
        trackTitleLabel.text = "\(CurrentlyPlaying.playlist[index].name) - \(CurrentlyPlaying.playlist[index].artist.name)"
        playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        
        DispatchQueue.main.async {
            guard
                let imageURL = CurrentlyPlaying.playlist[CurrentlyPlaying.index].album?.artUri,
                let url = URL(string: imageURL),
                let data = try? Data(contentsOf: url) else {
                    return
            }
           
            self.albumImageView.image = UIImage(data: data)
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if isPlaying {
            activateAudioSession()
        } else {
            deactivateAudioSession()
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        guard !isChangingProgress,
            let duration = SPTAudioStreamingController.sharedInstance()?.metadata.currentTrack?.duration,
            duration > 0 else {
                return
        }
        
        let positionDouble = Double(position)
        let durationDouble = Double(duration)
        let position = Float(positionDouble / durationDouble)
        progressSlider.value = position
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        nextPressed()
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        canPlayTrack = true
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        canPlayTrack = false
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print(error as Any)
    }
    
    func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print(error)
        }
    }
}
