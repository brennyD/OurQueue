//
//  SessionTable.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/7/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation
import MultipeerConnectivity;




class JoinTableCell: UITableViewCell {
    var peer:cellData!;
    @IBOutlet weak var joinName: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    @IBAction func joinPressed(_ sender: Any) {
        peer.handler?(true);
        joinButton.isHidden = true;
    }
    
}


class InviteTableCell: UITableViewCell {
    
    @IBOutlet weak var inviteName: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    var peer:cellData!;
    
    @IBAction func invitePressed(_ sender: Any) {
        peer.handler?(true);
        inviteButton.isHidden = true;
    }
    
    
}


struct cellData {
    var peer: MCPeerID;
    var handler: ((Bool) -> Void)?
}



class SessionTable: UITableView, UITableViewDataSource {
    var peers:[cellData] = [];
    
    var isInvite:Bool!;
    
    func addPeer(_ peer: MCPeerID, handler: ((Bool) -> Void)? = nil){
        self.beginUpdates();
        peers.append(cellData(peer: peer, handler: handler));
        self.insertRows(at: [IndexPath(row: peers.count-1, section: 0)], with: .automatic);
       
        self.endUpdates();
        print("I'm here!");
        self.reloadData();
    }
    
    func removePeer(_ peer: MCPeerID, handler: ((Bool) -> Void)? = nil){
        self.beginUpdates();
        if let index = peers.firstIndex(where: {cell in cell.peer == peer}) {
        peers.remove(at: index);
        reloadData();
        }
        self.endUpdates();
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peers.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(isInvite) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inviteCell") as! InviteTableCell;
        cell.peer = peers[indexPath.item];
            cell.inviteName.text = peers[indexPath.item].peer.displayName;
        cell.inviteButton.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right:32.0);
        cell.inviteButton.layer.cornerRadius = 20;
        cell.inviteButton.translatesAutoresizingMaskIntoConstraints = false;
        cell.inviteButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        cell.inviteName.adjustsFontSizeToFitWidth = true;
        cell.inviteButton.titleLabel?.textColor = UIColor.white;
        return cell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "joinCell") as! JoinTableCell;
            cell.peer = peers[indexPath.item];
            cell.joinButton.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right:32.0);
            cell.joinButton.layer.cornerRadius = 20;
            cell.joinButton.translatesAutoresizingMaskIntoConstraints = false;
            cell.joinButton.titleLabel?.adjustsFontSizeToFitWidth = true;
            cell.joinName.adjustsFontSizeToFitWidth = true;
            cell.joinName.text = cell.peer.peer.displayName;
            cell.joinButton.titleLabel?.textColor = UIColor.white;
            return cell;
        }
        
    }
    

    
    
}
