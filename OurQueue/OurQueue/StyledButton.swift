//
//  StyledButton.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/9/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation


class StyledButton: UIButton {
    
    
    init(){
        super.init(frame: .zero);
        self.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right:32.0);
        self.layer.cornerRadius = 20;
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.titleLabel?.adjustsFontSizeToFitWidth = true;
        self.titleLabel?.lineBreakMode = .byWordWrapping;
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        self.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right:32.0);
        self.layer.cornerRadius = 20;
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.titleLabel?.adjustsFontSizeToFitWidth = true;
        self.titleLabel?.textAlignment = .center;
    }
    
    
    
}
