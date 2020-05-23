//
//  BeginViewController.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/6/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation



class BeginViewController: UIViewController {
    
    @IBOutlet weak var beginView: StartView!
    lazy var model = (self.navigationController as! MainNavVC).model;
    
    @IBOutlet weak var hostButton: UIButton!
    
    @IBOutlet weak var joinButton: UIButton!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        hostButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        joinButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        createButton(hostButton);
        createButton(joinButton);
        beginView.addSlideInStep(hostButton);
        beginView.addSlideInStep(joinButton);
        hostButton.isHidden = false;
        joinButton.isHidden = false;
        beginView.slideIn();
        beginView.colorGradientAnimation(hostButton);
        beginView.colorGradientAnimation(joinButton);
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        beginView.colorGradientAnimation(hostButton);
        beginView.colorGradientAnimation(joinButton);
    }
    
    
    
    func createButton(_ button: UIButton){
        button.isHidden = true;
        button.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right:32.0);
        button.layer.cornerRadius = 20;
        button.translatesAutoresizingMaskIntoConstraints = false;
        button.titleLabel?.adjustsFontSizeToFitWidth = true;
    }
    
    
    
    @IBAction func hostPressed(_ sender: UIButton) {
        let nvc = storyBoard.instantiateViewController(withIdentifier: "createVC") as! CreateVC;
        self.navigationController?.pushViewController(nvc, animated: true)
    }
    
    @IBAction func joinPressed(_ sender: UIButton) {
        let nvc = storyBoard.instantiateViewController(withIdentifier: "joinVC") as! JoinVC;
        self.navigationController?.pushViewController(nvc, animated: true)
    }
    
    
    
    
}
