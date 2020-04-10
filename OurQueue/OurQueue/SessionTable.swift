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
        inviteButton.isEnabled = false;
        
        if let v = self.superview as? SessionTable {
            v.invitedPeer(peer.peer);
        }
        
        
        inviteButton.backgroundColor = UIColor.red;
        inviteButton.setTitle("Invited", for: .normal);
    }
    
    
}


struct cellData {
    var peer: MCPeerID;
    var handler: ((Bool) -> Void)?
    var didAccept: Bool;
    var didInvite: Bool;
}



class SessionTable: UITableView, UITableViewDataSource {
    var peers:[cellData] = [];
    
    var isInvite:Bool!;
    
    
    func invitedPeer(_ peer: MCPeerID) {
        if let p = peers.firstIndex(where: {cell in cell.peer == peer}) {
            peers[p].didInvite = true;
        }
    }
    
    
    func addPeer(_ peer: MCPeerID, handler: ((Bool) -> Void)? = nil){
        self.beginUpdates();
        peers.append(cellData(peer: peer, handler: handler, didAccept: false, didInvite:false));
        self.insertRows(at: [IndexPath(row: peers.count-1, section: 0)], with: .automatic);
       
        self.endUpdates();
        self.reloadData();
    }
    
    
    func peerAccepted(_ peer: MCPeerID?) {
        if let p = peers.firstIndex(where: {cell in cell.peer == peer}){
            peers[p].didAccept = true;
            self.reloadData();
        }
        
    }
    
    func removePeer(_ peer: MCPeerID, handler: ((Bool) -> Void)? = nil){
        
        if let index = peers.firstIndex(where: {cell in cell.peer == peer}) {
        peers.remove(at: index);
        reloadData();
        self.beginUpdates();
        self.endUpdates();
        }
        
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
        let text = cell.peer.didAccept ? "Joined" : (cell.peer.didInvite ? "Invited": "Invite");
        let color = cell.peer.didAccept ? #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) : (!cell.peer.didInvite ? #colorLiteral(red: 0.1137254902, green: 0.7254901961, blue: 0.3294117647, alpha: 1) : UIColor.red);
        cell.inviteButton.setTitle(text, for: .normal);
        cell.inviteButton.backgroundColor = color;
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
