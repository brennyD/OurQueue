//
//  ViewController.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 3/30/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    
    @IBOutlet weak var debuglabel: UILabel!
    
    var model = SpotifyModel();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Clear keychain
        //model.keychain.clear();
        model.beginSession();
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func pressed(_ sender: Any) {
        
        
        
        /*if(model.trackPaging != nil) {
            print(model.trackPaging!.items[0].album);
        }*/
        
        
        model.searchForTracks(search: "Baton Rouge");
        print(model.expiration?.description(with: .current) ?? "None");
        
    }
    
    

}

