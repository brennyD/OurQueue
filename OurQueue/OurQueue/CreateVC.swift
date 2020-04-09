//
//  CreateVC.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/7/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation;
import MultipeerConnectivity;



class CreateVC: UIViewController {
    
    @IBOutlet weak var subtitle: UILabel!
    
    var displayName:String! = nil;
    
    @IBOutlet weak var inviteTitle: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var invTable: SessionTable! {
        didSet{
            invTable.dataSource = invTable;
            invTable.isInvite = true;
        }
    }
    
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    lazy var spotModel = (self.navigationController as! MainNavVC).model!;
    var hostSesh:HostMC! = nil;
    let alert = UIAlertController(title: "Enter Display Name", message: "This name will identify you to people around you", preferredStyle: .alert);
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        startButton.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right:32.0);
        startButton.layer.cornerRadius = 20;
        startButton.translatesAutoresizingMaskIntoConstraints = false;
        startButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        startButton.titleLabel?.lineBreakMode = .byWordWrapping;
        subtitle.text = "you can invite friends who are nearby\n(or on the same Wifi network)"
        subtitle.adjustsFontSizeToFitWidth = true;
        inviteTitle.adjustsFontSizeToFitWidth = true;
        startButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        var field:UITextField! = nil;
        alert.addTextField(configurationHandler: {text in
            text.autocapitalizationType = .sentences;
            text.keyboardAppearance = .dark;
            text.autocorrectionType = .default;
            field = text;
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {alert in self.navigationController?.popViewController(animated: true)}));
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: {alert in
            self.displayName = field.text
            self.hostSesh = HostMC(name: self.displayName, token: self.spotModel.appRemote.connectionParameters.accessToken!, addHandler:self.addPeer, removeHandler: self.removePeer);
            self.hostSesh.openInvite();
        }));
    }
    
    func addPeer(_ peer: MCPeerID){
        DispatchQueue.main.async {
            self.invTable.addPeer(peer, handler: {
                bool in self.hostSesh.addAdmit(peer: peer);
            });
        }
    }
    
    func removePeer(_ peer: MCPeerID){
        invTable.removePeer(peer);
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.present(alert, animated: true);
    }
    
    
    /* TO AUTOPLAY SPOTIFY PASTE THIS IN ON SESSION BEGIN BUTTON
        self.spotModel.appRemote.authorizeAndPlayURI("");
     */
    
    @IBAction func beginPressed(_ sender: Any) {
        hostSesh.closeAndBegin(complete: transitiontoSession)
    }
    
    
    func transitiontoSession(){
        DispatchQueue.main.async {
            let nvc = self.storyBoard.instantiateViewController(withIdentifier: "hostSessionVC") as! HostInSessionVC;
            nvc.hostSesh = self.hostSesh;
            self.navigationController?.pushViewController(nvc, animated: true)
        }
    }
    
    
    
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true);
    }
    
    
    
    
}
