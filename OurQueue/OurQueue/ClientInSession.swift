//
//  ClientInSession.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/10/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation


class ClientInSession: UIViewController, UITextFieldDelegate {
    
    var clientSesh: ClientMC!;
    @IBOutlet weak var searchView: StartView!
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var nowPlaying: UIButton!
    
    @IBOutlet weak var leaveButton: StyledButton!
    
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    @IBOutlet weak var searchTable: SearchTable! {
        didSet {
            searchTable.dataSource = searchTable;
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        searchTable.action = self.queueSong;
        searchField.delegate = self;
        searchField.overrideUserInterfaceStyle = .light;
        searchField.clearButtonMode = .always;
        searchField.returnKeyType = .search;
        nowPlaying.titleLabel?.adjustsFontSizeToFitWidth = true;
        
    }
    
    @IBAction func leavePressed(_ sender: Any) {
        clientSesh.stop();
        navigationController?.popToRootViewController(animated: true);
    }
    
    
    @IBAction func searchEntered(_ sender: UITextField) {
        if let text = sender.text {
            print(text);
            (navigationController as? MainNavVC)!.model.searchForTracks(search: text, handler: searchTable.updateResults);
        }
    }
    
    
    func queueSong(trackID: String) {
        print("Queuing \(trackID)");
        clientSesh.queueSong(trackURI: trackID);
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return false;
    }
    
    
    
    @IBAction func goToPlayback(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            let pbvc = self.storyBoard.instantiateViewController(withIdentifier: "playbackController") as! PlayBackController;
            pbvc.clientSesh = self.clientSesh;
            self.navigationController?.pushViewController(pbvc, animated: true)
        }
    }
    
    
    
}
