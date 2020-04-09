//
//  HostInSessionVC.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/8/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation



class HostInSessionVC: UIViewController {
    lazy var model:SpotifyModel! = (self.navigationController as! MainNavVC).model;
    var hostSesh:HostMC! = nil;
    
    @IBOutlet weak var jamTitle: UILabel!
    
    @IBOutlet weak var endButton: UIButton!
    
    @IBOutlet weak var jamSubtitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        jamTitle.adjustsFontSizeToFitWidth = true;
        jamSubtitle.adjustsFontSizeToFitWidth = true;
        endButton.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right:32.0);
        endButton.layer.cornerRadius = 20;
        endButton.translatesAutoresizingMaskIntoConstraints = false;
        endButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        endButton.titleLabel?.lineBreakMode = .byWordWrapping;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        model.appRemote.authorizeAndPlayURI("");
    }
    
    
}
