//
//  SpotifyModel.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 3/31/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation
import KeychainSwift
import Spartan

class SpotifyModel: NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate, SPTSessionManagerDelegate {
    
    
    let SpotifyClientID = ProcessInfo.processInfo.environment["CLIENT_ID"]!;
    let SpotifyRedirectURL = URL(string: ProcessInfo.processInfo.environment["REDIRECT_URI"]!)!
    let refreshKey = ProcessInfo.processInfo.environment["REFRESH_KEY"]!;
    let keychain = KeychainSwift();
    var expiration: Date? = nil;
    var trackPaging: PagingObject<Track>? = nil;

    lazy var configuration:SPTConfiguration = {
        let config = SPTConfiguration(clientID: SpotifyClientID, redirectURL:SpotifyRedirectURL);
        if let refresh = ProcessInfo.processInfo.environment["REFRESH_URL"] {
            config.tokenRefreshURL = URL(string: refresh);
        }
        if let swap = ProcessInfo.processInfo.environment["SWAP_URL"] {
            config.tokenSwapURL = URL(string: swap);
        }
        config.playURI = "";
        return config;
    }();
    
    
    lazy var spotManager:SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self);
        //MUST BE REMOVED IN PROD
        manager.alwaysShowAuthorizationDialog = true;
        return manager;
        }();
    

    let scope:SPTScope = [.appRemoteControl, .streaming, .userModifyPlaybackState, .userReadRecentlyPlayed];
    
    
    
    func beginSession(){
        Spartan.loggingEnabled = true;
        if let _ = keychain.get(refreshKey) {
            if(expiration == nil || expiration! < Date()){
                refreshSession();
            }
        } else {
            if #available(iOS 11, *) {
                // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
                spotManager.initiateSession(with: scope, options: .clientOnly);
            } else {
                // Use this on iOS versions < 11 to use SFSafariViewController
                spotManager.initiateSession(with: scope, options: .clientOnly, presenting: UIApplication.shared.keyWindow!.rootViewController as! ViewController);
            }
        }
    }
    
    
    
    func searchForTracks(search: String) {
        checkExpiration();
        let good:(PagingObject<Track>) -> () = { page in
            self.trackPaging = page;
        }
        Spartan.search(query: search, type: .track, success: good, failure: {error in print(error)});
    }

    
    
    private func parseURI(_ uri: String) -> String {
        return "I gotta do this!";
    }
    
    
    private func checkExpiration(){
        if(expiration! < Date()){
            refreshSession();
        }
    }
    
    private func refreshSession(){
        if let refresh = ProcessInfo.processInfo.environment["REFRESH_URL"] {
            let url = URL(string: refresh)!;
            var request = URLRequest(url: url);
            request.httpMethod = "POST";
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let json:[String: Any] = ["refresh_token": keychain.get(refreshKey)!];
            let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed);
            request.httpBody = jsonData;
            
            let semaphore = DispatchSemaphore(value: 0);
            
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                guard let data = data, error == nil else {
                    print("URL Call failed with \(error?.localizedDescription ?? "No data")");
                    semaphore.signal();
                    return;
                }
                let body = try? JSONSerialization.jsonObject(with: data, options: []);
                if let response = body as? [String: Any] {
                    Spartan.authorizationToken = response["access_token"] as? String;
                    self.expiration = Date(timeInterval: TimeInterval(response["expires_in"] as! Int), since: Date());
                }
                semaphore.signal();
            }
            task.resume();
            _ = semaphore.wait(timeout: .distantFuture);
            
        }
        
        
        
        
        
    }
    
    
    

    
    
    
    //MARK: - STPAppRemoteDelegate
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Connected")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Couldn't connect with Error:\n\(error?.localizedDescription ?? "None")")
    
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Connection lost with Error:\n\(error?.localizedDescription ?? "None")")
    }
    
    
    //MARK: - SPTAppRemotePlayerStateDelegate
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("Player state changed to something idk man")
    }
    
    
    
    //MARK: - SPTSessionManagerDelegate
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("Succesfully initiated session with Expiration \(manager.session!.expirationDate)");
        expiration = manager.session!.expirationDate;
        Spartan.authorizationToken = session.accessToken;
        
        if(!keychain.set(session.refreshToken, forKey: refreshKey)){
            print("Failed to store refresh token");
        }
        
        
        
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("Error \(error.localizedDescription)")
    }

}
