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
    var host:String!;
    var id:String!;
    @IBOutlet weak var jamTitle: UILabel!
    
    @IBOutlet weak var endButton: UIButton!
    
    @IBOutlet weak var jamSubtitle: UILabel!
    
    @IBOutlet weak var mainView: StartView!
    
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        jamTitle.adjustsFontSizeToFitWidth = true;
        jamSubtitle.adjustsFontSizeToFitWidth = true;
        endButton.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right:32.0);
        endButton.layer.cornerRadius = 20;
        endButton.translatesAutoresizingMaskIntoConstraints = false;
        endButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        mainView.colorGradientAnimation(endButton);
        NotificationCenter.default.addObserver(self, selector: #selector(HostInSessionVC.endSession(notification:)), name: UIApplication.willTerminateNotification, object: UIApplication.shared)
        host = hostSesh.getHostToken();
        id = hostSesh.sessionID;
    }
    
    
    @objc func endSession(notification: Notification? = nil){
        print("please bro");
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        model.appRemote.authorizeAndPlayURI("");
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
    }
    
    
    @IBAction func endPressed(_ sender: Any) {
        hostSesh.endSession();
        navigationController?.popToRootViewController(animated: true);
    }
    
    
    
}
