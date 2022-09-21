//
//  ViewController.swift
//  Project7
//
//  Created by Grant Watson on 9/21/22.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var searchText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(creditsButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterButtonTapped))
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        dataTask?.cancel()
        
        dataTask = defaultSession.dataTask(with: url, completionHandler: { data, response, error in
            
            if let data = data {
                self.parse(json: data)
                return
            }
            self.showError()
        })
        
        dataTask?.resume()
    }
    
    func showError() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed. Please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filteredPetitions = petitions
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func creditsButtonTapped() {
        let ac = UIAlertController(title: "Credits", message: "This data was retrieved from the 'We The People' API of the Whitehouse.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func filterButtonTapped() {
        let ac = UIAlertController(title: "Filter results", message: "Search petitions for keywords", preferredStyle: .alert)
        ac.addTextField()
        
        let filterPetition = UIAlertAction(title: "OK", style: .default) { _ in
            guard let filter = ac.textFields?[0].text else { return }
            self.filterResults(text: filter)
        }
        
        let resetResults = UIAlertAction(title: "Reset", style: .destructive) { _ in
            self.filteredPetitions = self.petitions
            self.tableView.reloadData()
        }
        
        ac.addAction(resetResults)
        ac.addAction(filterPetition)
        present(ac, animated: true)
    }
    
    func filterResults(text: String) {
        filteredPetitions = []
        
        for petition in petitions {
            if petition.title.lowercased().contains(text.lowercased()) {
                filteredPetitions.append(petition)
            }
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let petition = filteredPetitions[indexPath.row]
        content.textProperties.numberOfLines = 1
        content.secondaryTextProperties.numberOfLines = 1
        content.text = petition.title
        content.secondaryText = petition.body
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailVC()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

