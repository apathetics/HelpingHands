//
//  SearchTabViewController.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/1/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit

class SearchTabViewController: UITableViewController, UISearchResultsUpdating {
    
    
    let unfilteredNFLTeams = ["Bengals", "Ravens", "Browns", "Steelers", "Bears", "Lions", "Packers", "Vikings",
                              "Texans", "Colts", "Jaguars", "Titans", "Falcons", "Panthers", "Saints", "Buccaneers",
                              "Bills", "Dolphins", "Patriots", "Jets", "Cowboys", "Giants", "Eagles", "Redskins",
                              "Broncos", "Chiefs", "Raiders", "Chargers", "Cardinals", "Rams", "49ers", "Seahawks"].sorted()
    var filteredNFLTeams: [String]?
    let searchController = UISearchController(searchResultsController: nil)
    
    
    
    override func viewDidLoad() {
        filteredNFLTeams = unfilteredNFLTeams
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let nflTeams = filteredNFLTeams else {
            return 0
        }
        return nflTeams.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        
        if let nflTeams = filteredNFLTeams {
            let team = nflTeams[indexPath.row]
            cell.textLabel!.text = team
        }
        
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredNFLTeams = unfilteredNFLTeams.filter { team in
                return team.lowercased().contains(searchText.lowercased())
            }
            
        } else {
            filteredNFLTeams = unfilteredNFLTeams
        }
        tableView.reloadData()
    }

}
