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
    private var hostPeer: MCPeerID!;
    private var advertiser:MCNearbyServiceAdvertiser;
    private let serviceType = "oq-session";
    private let URI_PREFIX = "spotify:track:";
    private let queueURL = "https://us-central1-ourqueue-8223f.cloudfunctions.net/queueSong";
    private let sesh:MCSession;
    private var addFunc: ((MCPeerID, ((Bool) -> ())?) -> ())?;
    private var startFunc: (() -> ())
    
    init(name: String, addHandler: ((MCPeerID, ((Bool) -> ())?) -> ())?, transitionHandler: @escaping (() -> ())){
        peer = MCPeerID(displayName: name);
        sesh = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .required);
        startFunc = transitionHandler;
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
    
    
    func queueSong(trackURI: String){
        let trackURI = URI_PREFIX+trackURI;
        let url = URL(string: queueURL)!;
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let json:[String: Any] = ["sessionID": self.sessionID!, "trackURI":trackURI, "member":self.clientToken!];
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed);
        request.httpBody = jsonData;
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard let data = data, error == nil else {
                print("URL Call failed with \(error?.localizedDescription ?? "No data")");
                return;
            }
            let body = try? JSONSerialization.jsonObject(with: data, options: []);
            if let _ = body as? [String: Any] {
                print("Yes?");
            }
        }
        task.resume();
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
            if(self.hostPeer == nil){
                self.hostPeer = peerID;
            }
            try session.send(self.clientToken!.data(using: .utf8)!, toPeers: [peerID], with: .reliable);
                
            } catch let error{
                print(error)
            }
        }
       }
       
       func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let msg = String(data: data, encoding: .utf8) {
            if(peerID == self.hostPeer){
                if(msg == "You've been kicked dummy!") {
                    session.disconnect();
                } else {
                    sessionID = msg;
                    print(sessionID!);
                    self.advertiser.stopAdvertisingPeer();
                    try? self.sesh.send("ID received".data(using: .utf8)!, toPeers: [peerID], with: .reliable);
                    startFunc();
                }
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
