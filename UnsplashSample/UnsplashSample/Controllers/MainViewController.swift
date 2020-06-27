//
//  ViewController.swift
//  UnsplashSample
//
//  Created by Gilwan Ryu on 2020/06/25.
//  Copyright © 2020 GilwanRyu. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    private var resultViewController = SearchResultViewController()
    private var searchController = UISearchController()
    
    private var page: Int = 1
    private var photos = [Photo]() {
        didSet {
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupSearchViewController()
        self.requestPhoto()
    }
}

// MARK: - Setup
extension MainViewController {
    
    func setupTableView() {
        self.mainTableView.register(UINib(nibName: "PhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "PhotoCell")
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
    }
    
    func setupSearchViewController() {
        
        self.resultViewController = SearchResultViewController.instance()
        
        self.searchController = UISearchController(searchResultsController: resultViewController)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.placeholder = "Search Photos"
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        navigationItem.searchController = self.searchController
    }
}

// MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate, UISearchResultsUpdating {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        self.resultViewController.searchKeyword = keyword
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        DispatchQueue.main.async {
            self.resultViewController.view.isHidden = false
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageWidth = self.photos[indexPath.row].width
        let imageHeight = self.photos[indexPath.row].height
        let myViewWidth = UIScreen.main.bounds.width

        let ratio = myViewWidth / CGFloat(imageWidth)
        let scaledHeight = CGFloat(imageHeight) * ratio
        
        return scaledHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoCell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoTableViewCell
        photoCell.bind(photo: self.photos[indexPath.row])
        return photoCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = PhotoDetailViewController.instance()
        
        detailViewController.modalPresentationStyle = .fullScreen
        detailViewController.delegate = self
        detailViewController.photos = self.photos
        
        self.present(detailViewController, animated: false) {
            detailViewController.currentIndex = indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = photos.count - 1
        if indexPath.row == lastElement {
            self.page += 1
            self.requestPhoto()
        }
    }
}

// MARK: - PhotoDetailViewContollerDelegate
extension MainViewController: PhotoDetailViewContollerDelegate {
    func close(indexPath: IndexPath) {
        self.mainTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
    }
}

// MARK: - Network
extension MainViewController {
    func requestPhoto() {
        let manager = NetworkManager()
        
        let headers = headersType()
        var parameters = DictionaryType()
        parameters.updateValue(page.description, forKey: "page")
        parameters.updateValue(Api.Unsplash.clientId, forKey: "client_id")
        
        manager.request(for: Api.Unsplash.Photo.allPhoto, method: .get, headers: headers, parameters: parameters, completion: { [weak self] (photoList: [Photo]?, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showError(message: error.localizedDescription, doneHandler: nil, completion: nil)
                print(error)
                return
            }
            
            guard let photoList = photoList else { return }
            
            self.photos.append(contentsOf: photoList)
        })
    }
}



