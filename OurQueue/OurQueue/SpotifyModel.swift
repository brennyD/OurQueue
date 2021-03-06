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
    
    
    let SpotifyClientID = "Spotify app Client ID here"; //ProcessInfo.processInfo.environment["CLIENT_ID"]!;
    let SpotifyRedirectURL = URL(string:"Spotify callback URL here");//URL(string: ProcessInfo.processInfo.environment["REDIRECT_URI"]!)!
    let refreshKey = "refresh key here"//ProcessInfo.processInfo.environment["REFRESH_KEY"]!;
    let refreshURL = "Spotify refresh url here";
    let swapURL = "token swap url here"
    let keychain = KeychainSwift();
    var expiration: Date? = nil;
    var trackPaging: PagingObject<Track>? = nil;
    private var completionFunction: (()->())? = nil;

    lazy var configuration:SPTConfiguration = {
        let config = SPTConfiguration(clientID: SpotifyClientID, redirectURL:SpotifyRedirectURL!);
       
        config.tokenRefreshURL = URL(string: refreshURL);
        
        
        config.tokenSwapURL = URL(string: swapURL);
        
       // config.playURI = "";
        return config;
    }();
    
    
    lazy var appRemote: SPTAppRemote = {
        var ret = SPTAppRemote(configuration: self.configuration, logLevel: .debug);
        return ret;
    }();
    
    lazy var spotManager:SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self);
        //MUST BE REMOVED IN PROD
        manager.alwaysShowAuthorizationDialog = true;
        return manager;
        }();
    

    let scope:SPTScope = [.appRemoteControl, .streaming, .userModifyPlaybackState, .userReadCurrentlyPlaying];
    
    
    
    func beginSession(complete:(() -> ())? = nil){
        Spartan.loggingEnabled = true;
        completionFunction = complete;
        if let _ = keychain.get(refreshKey) {
            if(expiration == nil || expiration! < Date()){
                refreshSession(complete: completionFunction);
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
    
    
    func isAppInstalled() -> Bool {
        return spotManager.isSpotifyAppInstalled;
    }
    
    func searchForTracks(search: String, handler: @escaping (PagingObject<Track>)->()) {
        checkExpiration();
        Spartan.search(query: search, type: .track, success: handler, failure: {error in print(error)});
    }

    func needsAppAuthorization() -> Bool{
        return keychain.get(refreshKey) == nil;
    }
    
    
    
    private func checkExpiration(){
        if(expiration! < Date()){
            refreshSession();
        }
    }
    
    private func refreshSession(complete: (() -> ())? = nil){
        let refresh = refreshURL;
        let url = URL(string: refresh)!;
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let json:[String: Any] = ["refresh_token": keychain.get(refreshKey)!];
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
                Spartan.authorizationToken = response["access_token"] as? String;
                self.appRemote.connectionParameters.accessToken = response["access_token"] as? String;
                self.expiration = Date(timeInterval: TimeInterval(response["expires_in"] as! Int), since: Date());
                complete?();
            }
        }
        task.resume();
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
        appRemote.connectionParameters.accessToken = session.accessToken;
        completionFunction?();
        if(!keychain.set(session.refreshToken, forKey: refreshKey)){
            print("Failed to store refresh token");
        }
        
        
        
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("Error \(error.localizedDescription)")
    }

}
