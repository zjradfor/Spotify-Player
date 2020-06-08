//
//  TrackTableViewController.swift
//  SpotifyKitDemo
//
//  Created by Zach Radford on 2020-05-31.
//  Copyright © 2020 Zach Radford. All rights reserved.
//

import UIKit

protocol TrackPlayer {
    func playTrack(at index: Int)
}

class TrackTableViewController: UITableViewController {

    // MARK: - Properties
    
    var delegate: TrackPlayer?
    
    var tracks = [SpotifyTrack]()
    
    var playlist: SpotifyPlaylist? {
        didSet {
            loadTracks()
        }
    }
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - methods
    
    func loadTracks() {
        if let trackList = playlist?.collectionTracks {
            tracks = trackList
        }
        
        tableView.reloadData()
    }

    // MARK: - Table View data source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = tracks[indexPath.row].name
        
        return cell
    }
    
    // MARK: - Table View delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CurrentlyPlaying.playlist = tracks
        CurrentlyPlaying.index = indexPath.row
        
        delegate?.playTrack(at: indexPath.row)
    }

}
