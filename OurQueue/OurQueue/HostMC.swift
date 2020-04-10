//
//  HostMC.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/7/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation
import MultipeerConnectivity;
import KeychainSwift;
class HostMC: NSObject, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    private var browser:MCNearbyServiceBrowser;
    private var avaliablePeers:[MCPeerID] = [];
    private var clientTokens: [String] = [];
    private var sesh: MCSession;
    var sessionID:String?
    private var numReceived = 0;
    private var hostToken: String?;
    private let serviceType = "oq-session";
    private let currentAccessToken:String;
    private var sentCount = 0;
    private let refreshKey = "com.Gizzard.refreshkey";
    private let hostURL = "https://us-central1-ourqueue-8223f.cloudfunctions.net/hostSession";
    private let endURL = "https://us-central1-ourqueue-8223f.cloudfunctions.net/endHostSession";
    private var addFunc: ((MCPeerID) -> ())?;
    private var removeFunc: ((MCPeerID) -> ())?;
    var canStart: ((MCPeerID?) -> ())?;
    
    init(name: String, token: String, addHandler: ((MCPeerID) -> ())?, removeHandler: ((MCPeerID) -> ())?){
        browser = MCNearbyServiceBrowser(peer: MCPeerID(displayName: name), serviceType: serviceType);
        sesh = MCSession(peer: browser.myPeerID, securityIdentity: nil, encryptionPreference: .required);
        currentAccessToken = token;
        addFunc = addHandler;
        removeFunc = removeHandler;
        super.init();
        browser.delegate = self;
        sesh.delegate = self;
    }
    
    
    func openInvite(complete: (()->())? = nil){
        browser.startBrowsingForPeers();
    }
    
    
    private func createToken(){
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        hostToken = String((0..<25).map{ _ in letters.randomElement()! })
    }
    
    func getHostToken() -> String? {
        return hostToken;
    }
    
    
    
    
    func closeAndBegin(complete: (() -> ())?){
        browser.stopBrowsingForPeers();
        
        if(sesh.connectedPeers.count == clientTokens.count){
            createInstance(complete);
        } else {
            print("Uh oh!");
        }
        
    }
    
    
    
    private func createInstance(_ complete: (()->())?) {
        createToken();
        let key = KeychainSwift().get(refreshKey)!;
        let host = hostURL;
        let url = URL(string: host)!;
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let json:[String: Any] = ["rtoken": key, "host":hostToken!, "members":clientTokens, "token":currentAccessToken];
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed);
        request.httpBody = jsonData;
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard let data = data, error == nil else {
                print("URL Call failed with \(error?.localizedDescription ?? "No data")");
                return;
            }
            let body = try? JSONSerialization.jsonObject(with: data, options: []);
            if let response = body as? [String: Any] {
                self.sessionID = response["sessionID"] as? String;
                do {
                try self.sesh.send(self.sessionID!.data(using: .utf8)!, toPeers: self.sesh.connectedPeers, with: .reliable);
                } catch let error {
                    print(error);
                }
                self.avaliablePeers = [];
                complete?();
            }
        }
        task.resume();
        
    }
    
    func addAdmit(name: String) {
        if let peer = avaliablePeers.first(where: {p in p.displayName == name}){
            browser.invitePeer(peer, to: sesh, withContext: browser.myPeerID.displayName.data(using: .utf8), timeout: 30);
        }
    }
    
    
    func addAdmit(peer: MCPeerID) {
        browser.invitePeer(peer, to: sesh, withContext: browser.myPeerID.displayName.data(using: .utf8), timeout: 30);
    }
    
    func removeAdmit(_ name: String) {
        if let peer = sesh.connectedPeers.first(where: {p in p.displayName == name}){
            try? sesh.send("You've been kicked dummy!".data(using: .utf8)!, toPeers: [peer], with: .reliable);
        }
    }
    
    func removeAdmit(peer: MCPeerID) {
        try? sesh.send("You've been kicked dummy!".data(using: .utf8)!, toPeers: [peer], with: .reliable);
    }
    
    
    func endSession(complete: (()->())? = nil){
        print("Ending Session \(sessionID ?? "nil")");
        let url = URL(string: endURL)!;
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let json:[String: Any] = ["sessionID": sessionID!,"host":hostToken!];
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed);
        request.httpBody = jsonData;
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard let _ = data, error == nil else {
                print("URL Call failed with \(error?.localizedDescription ?? "No data")");
                return;
            }
            print("Session \(self.sessionID ?? "uh oh") ended");
            self.sessionID = nil;
            self.clientTokens = [];
            self.hostToken = nil;
            complete?();
        }
        task.resume();
    }
    
    //MARK: - MCServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Peer \(peerID.displayName) found");
            avaliablePeers.append(peerID);
            addFunc?(peerID);
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost \(peerID.displayName)");
        if let index = avaliablePeers.firstIndex(of: peerID){
            print("Peer \(peerID.displayName) lost");
            avaliablePeers.remove(at: index);
            removeFunc?(peerID);
        }
    }
    
    
    //MARK: - MCSessionDelegate
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if(state == .connected) {
            print("Succesfully connected to \(peerID.displayName)");
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let msg = String(data: data, encoding: .utf8) {
            if(msg == "ID received") {
                sentCount += 1;
                if(sentCount >= session.connectedPeers.count) {
                    self.sesh.disconnect();
                }
            } else {
                clientTokens.append(msg);
                canStart?(peerID);
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
