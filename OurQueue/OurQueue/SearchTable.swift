//
//  SearchTable.swift
//  OurQueue
//
//  Created by Brendan DeMilt on 4/10/20.
//  Copyright © 2020 Brendan DeMilt. All rights reserved.
//

import Foundation
import Spartan;


class resultsCell: UITableViewCell {
    
    @IBOutlet weak var trackArt: UIImageView!
    
    @IBOutlet weak var trackTitle: UILabel!
    
    @IBOutlet weak var trackArtist: UILabel!
    
    var trackID = "";
    
    @IBOutlet weak var queueButton: StyledButton!
    var queueAction: ((String) -> ())?;
    
    
    
    @IBAction func didPressQueue(_ sender: StyledButton) {
        
        queueAction?(self.trackID);
        self.queueButton.titleLabel?.text = "Queued";
        self.queueButton.backgroundColor = UIColor.red;
    }
    
    
    
    
}



struct TableTrack {
    var title:String;
    var artist:String;
    var art: UIImage?;
    var spotID: String;
    
}



class SearchTable: UITableView, UITableViewDataSource {
    var results: [TableTrack]?
    var action: ((String) -> ())?;
    
    
    func updateResults(input: PagingObject<Track>) {
        results = [];
        for i in input.items {
            var t = TableTrack(title: i.name, artist: i.artists[0].name, spotID: i.spotifyID);
            if let imgURL = URL(string: i.album.images[i.album.images.count-1].url){
                    if let d = try? Data(contentsOf: imgURL) {
                        t.art = UIImage(data: d);
                    }
            }
            results?.append(t);
        }
        self.reloadData();
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = results![indexPath.row];
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell") as! resultsCell;
        cell.tag = indexPath.row;
        cell.queueButton.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.7254901961, blue: 0.3294117647, alpha: 1);
        cell.queueButton.titleLabel?.text = "Queue";
        cell.trackArtist.text = item.artist;
        cell.trackTitle.text = item.title;
        cell.trackArt.contentMode = .scaleAspectFit;
        cell.trackArt.image = item.art;
        cell.trackArt.sizeToFit();
        cell.trackTitle.adjustsFontSizeToFitWidth = true;
        cell.trackArtist.adjustsFontSizeToFitWidth = true;
        cell.queueAction = self.action;
        cell.queueButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        cell.trackID = item.spotID;
        return cell;
    }
    
    
}
