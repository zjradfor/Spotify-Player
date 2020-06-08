//
//  PlaylistViewController.swift
//  SpotifyKitDemo
//
//  Created by Zach Radford on 2020-05-31.
//  Copyright © 2020 Zach Radford. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var playlists = [SpotifyPlaylist]()
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        setTitle()
        
        loginIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getPlaylists()
    }
    
    // MARK: - Private methods
    
    private func setTitle() {
        self.navigationItem.title = "Playlists"
    }
    
    private func getPlaylists() {
        spotifyManager.library(SpotifyPlaylist.self) { [weak self] result in
            self?.playlists = result
            self?.tableView.reloadData()
        }
    }
    
    private func loginIfNeeded() {
        if !spotifyManager.hasToken {
            let vc = AuthViewController(nibName: "AuthViewController", bundle: nil)
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func logout() {
        spotifyManager.deauthorize()
        playlists = []
        CurrentlyPlaying.playlist = []
        CurrentlyPlaying.index = 0
        tableView.reloadData()
        loginIfNeeded()
    }
    
    // MARK: - Table View Datasource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.row == playlists.count {
            cell.textLabel?.text = "Logout"
            cell.backgroundColor = .red
        } else {
            cell.textLabel?.text = playlists[indexPath.row].name
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == playlists.count {
            logout()
        } else {
            performSegue(withIdentifier: "toList", sender: self)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! TrackTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            spotifyManager.get(SpotifyPlaylist.self, id: playlists[indexPath.row].id) { (result) in
                vc.playlist = result
                vc.navigationItem.title = result.name
                vc.delegate = self.navigationController?.parent as? MasterViewController
            }
        }
    }
}

// MARK: - Auth callback delegate

extension PlaylistViewController: AuthCallback {
    func didDismiss() {
        getPlaylists()
    }
}
