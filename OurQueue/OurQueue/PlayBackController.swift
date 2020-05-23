//
//  PlayBackController.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/30/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation




class PlayBackController: UIViewController {
    
    
    
    lazy var spotModel: SpotifyModel! = (self.navigationController as? MainNavVC)?.model;
    
    var clientSesh: ClientMC!;
    
    
    @IBOutlet weak var trackImage: UIImageView!
    
    @IBOutlet weak var nowPlaying: UILabel!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet weak var FastForward: UIButton!
    
    @IBOutlet weak var play: UIButton!
    
    @IBOutlet weak var rewind: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    
    @IBAction func goBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true);
    }
    
    
    @IBAction func updatePlayback(_ sender: UIButton) {
        
    }
    
    
    
}
