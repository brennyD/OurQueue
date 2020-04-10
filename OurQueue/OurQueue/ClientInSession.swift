//
//  ClientInSession.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/10/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation


class ClientInSession: UIViewController {
    
    var clientSesh: ClientMC!;
    @IBOutlet weak var searchView: StartView!
    
    @IBOutlet weak var searchField: UITextField!
    
    
    @IBOutlet weak var leaveButton: StyledButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
    }
    
    @IBAction func leavePressed(_ sender: Any) {
        clientSesh.stop();
        navigationController?.popToRootViewController(animated: true);
    }
    
}
