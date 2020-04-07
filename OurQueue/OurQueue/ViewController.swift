//
//  ViewController.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 3/30/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var start: StartView!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var connectLabel: UILabel!
    @IBOutlet weak var buffering: UIActivityIndicatorView!
    
    var model = SpotifyModel();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //model.keychain.clear();
        start.addFadeInStep(mainTitle);
        start.addFadeInStep(subtitle);
        start.addFadeInStep(logo);
        
        if(model.needsAppAuthorization()) {
        buffering.isHidden = true;
        start.colorGradientAnimation(authButton);
        authButton.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right:32.0);
        authButton.layer.cornerRadius = 20;
        authButton.translatesAutoresizingMaskIntoConstraints = false;
        authButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        authButton.titleLabel?.lineBreakMode = .byWordWrapping;
        let font: UIFont? = UIFont(name: "Futura", size: 17);
        let superFont:UIFont? = UIFont(name: "Futura", size:7);
        let range = (connectLabel.text! as NSString).range(of: "TM");
        let attString = NSMutableAttributedString(string: connectLabel.text!, attributes: [NSAttributedString.Key.font: font!]);
        attString.addAttribute(NSAttributedString.Key.font, value: superFont!, range: range)
        attString.addAttribute(NSAttributedString.Key.baselineOffset, value: 10, range: range)
        connectLabel.attributedText = attString;
        start.addSlideInStep(connectLabel);
        start.addSlideInStep(authButton);
        start.slideIn();
        } else {
            connectLabel.isHidden = true;
            authButton.isHidden = true;
            model.beginSession(complete: transitionToNext);
        }
    }
    
    
    
    func transitionToNext(){
        DispatchQueue.main.async {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "BeginViewControl") as! BeginViewController;
            let sd = self.view.window?.windowScene?.delegate as! SceneDelegate;
            sd.didLogin(vc: newViewController);
            newViewController.model = self.model;
            
        }
    }
    
    
    
    
    
    
    @IBAction func authPressed(_ sender: Any) {
        authButton.isHidden = true;
        connectLabel.isHidden = true;
        buffering.isHidden = false;
        model.beginSession(complete: {
            self.transitionToNext();
        });
    }
    


    
    

}

