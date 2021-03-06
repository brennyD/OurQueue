//
//  JoinVC.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/7/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation
import MultipeerConnectivity;


class JoinVC: UIViewController {
    
    var displayName:String! = nil;
    var clientSesh:ClientMC!;
    
    @IBOutlet weak var joinTitle: UILabel!
    
    @IBOutlet weak var joinsubtitle: UILabel!
    @IBOutlet weak var joinTable: SessionTable! {
        didSet {
            joinTable.dataSource = joinTable;
            joinTable.isInvite = false;
        }
    }
    
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    let alert = UIAlertController(title: "Enter Display Name", message: "This name will identify you to the host", preferredStyle: .alert);
    
    override func viewDidLoad() {
        super.viewDidLoad();
        joinTitle.adjustsFontSizeToFitWidth = true;
        joinsubtitle.adjustsFontSizeToFitWidth = true;
        var field:UITextField! = nil;
        
        alert.addTextField(configurationHandler: {text in
            text.autocapitalizationType = .sentences;
            text.keyboardAppearance = .dark;
            text.keyboardType = .alphabet;
            field = text;
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {alert in self.navigationController?.popViewController(animated: true)}));
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: {alert in
            self.displayName = field.text
            self.clientSesh = ClientMC(name: self.displayName, addHandler: self.addHandle,transitionHandler: self.transitionToSession)
            self.clientSesh.begin();
        }));
    }
    
    
    func addHandle(_ peer: MCPeerID, _ state: ((Bool)->())?) {
        DispatchQueue.main.async {
            self.joinTable.addPeer(peer, handler: state);
        }
    }
    
    
    
    func transitionToSession(){
       DispatchQueue.main.async {
            let nvc = self.storyBoard.instantiateViewController(withIdentifier: "clientSessionVC") as! ClientInSession;
            nvc.clientSesh = self.clientSesh;
            self.navigationController?.pushViewController(nvc, animated: true)
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.present(alert, animated: true);
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        clientSesh.stop();
        navigationController?.popViewController(animated: true);
    }
}
