//
//  JoinMC.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/8/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation
import MultipeerConnectivity;

class ClientMC: NSObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
   
    private var clientToken: String?;
    private var sessionID: String?;
    private var hostName: String?
    private var peer: MCPeerID;
    private var advertiser:MCNearbyServiceAdvertiser;
    private let serviceType = "oq-session";
    private let sesh:MCSession;
    private var addFunc: ((MCPeerID, ((Bool) -> ())?) -> ())?;
    
    init(name: String, addHandler: ((MCPeerID, ((Bool) -> ())?) -> ())?){
        peer = MCPeerID(displayName: name);
        sesh = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .none);
        
        addFunc = addHandler;
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: ["sericeType": serviceType], serviceType: serviceType);
        super.init();
        advertiser.delegate = self;
        sesh.delegate = self;
    }
    
    func begin() {
        advertiser.startAdvertisingPeer();
    }
    
    func stop(){
        advertiser.stopAdvertisingPeer();
        clientToken = nil;
        hostName = nil;
        sessionID = nil;
    }
    
    private func createToken(){
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        clientToken = String((0..<25).map{ _ in letters.randomElement()! })
    }
    
    
    //MARK: - MCNearbyServoceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let newHandler:(Bool) -> Void = {
            bool in
            invitationHandler(bool, self.sesh);
            self.createToken();
        };
        addFunc?(peerID, newHandler);
    }
    
    
    //MARK: - MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if(state == .connected){
        print("Connected to \(peerID.displayName)");
        do {
        try session.send(self.clientToken!.data(using: .utf8)!, toPeers: [peerID], with: .reliable);
            
        } catch let error{
            print(error)
        }
        }
       }
       
       func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let msg = String(data: data, encoding: .utf8) {
            if(msg == "You've been kicked dummy!") {
                session.disconnect();
            } else {
                sessionID = msg;
                print(sessionID!);
                self.advertiser.stopAdvertisingPeer();
                try? self.sesh.send("ID received".data(using: .utf8)!, toPeers: [peerID], with: .reliable);
            }
        }
       }
       
       func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
       }
       
       func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
       }
       
       func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
       }
}
