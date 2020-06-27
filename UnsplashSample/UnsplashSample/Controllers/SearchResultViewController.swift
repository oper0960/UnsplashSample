//
//  SearchResultViewController.swift
//  UnsplashSample
//
//  Created by Gilwan Ryu on 2020/06/26.
//  Copyright © 2020 GilwanRyu. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController {
    static func instance() -> SearchResultViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultViewController") as! SearchResultViewController
    }
    
    private struct SearchConfig {
        enum orderBy: String {
            case latest = "latest"
            case relevant = "relevant"
        }
        
        enum orientation: String {
            case portrait = "portrait"
        }
    }
    
    @IBOutlet weak var searchResultTableView: UITableView!
    
    var searchKeyword: String = "" {
        didSet {
            self.page = 1
            self.photos.removeAll()
            self.requestPhotoForSearchKeyword()
        }
    }
    
    private var maxPages: Int?
    private var page: Int = 1
    private var photos = [Photo]() {
        didSet {
            DispatchQueue.main.async {
                self.searchResultTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
    }
}

// MARK: - Setup
extension SearchResultViewController {
    func setupTableView() {
        self.searchResultTableView.register(UINib(nibName: "PhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "PhotoCell")
        self.searchResultTableView.delegate = self
        self.searchResultTableView.dataSource = self
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoCell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoTableViewCell
        photoCell.bind(photo: self.photos[indexPath.row])
        return photoCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageWidth = self.photos[indexPath.row].width
        let imageHeight = self.photos[indexPath.row].height
        let myViewWidth = UIScreen.main.bounds.width

        let ratio = myViewWidth / CGFloat(imageWidth)
        let scaledHeight = CGFloat(imageHeight) * ratio
        
        return scaledHeight
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
            
            guard let maxPages = self.maxPages else { return }
            
            if self.page < maxPages {
                self.page += 1
                self.requestPhotoForSearchKeyword()
            }
        }
    }
}

// MARK: - PhotoDetailViewContollerDelegate
extension SearchResultViewController: PhotoDetailViewContollerDelegate {
    func close(indexPath: IndexPath) {
        self.searchResultTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
    }
}

// MARK: - Network
extension SearchResultViewController {
    func requestPhotoForSearchKeyword() {
        let manager = NetworkManager()
        
        let headers = headersType()
        var parameters = DictionaryType()
        parameters.updateValue(searchKeyword, forKey: "query")
        parameters.updateValue(page.description, forKey: "page")
        parameters.updateValue(SearchConfig.orderBy.latest.rawValue, forKey: "order_by")
        parameters.updateValue(SearchConfig.orientation.portrait.rawValue, forKey: "orientation")
        parameters.updateValue(Api.Unsplash.clientId, forKey: "client_id")
        
        manager.request(for: Api.Unsplash.Photo.searchPhoto, method: .get, headers: headers, parameters: parameters, completion: { [weak self] (photoList: SearchPhoto?, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showError(message: error.localizedDescription, doneHandler: nil, completion: nil)
                print(error)
                return
            }
            
            guard let photoList = photoList else { return }
            self.maxPages = photoList.totalPages
            self.photos.append(contentsOf: photoList.results)
        })
    }
}

