//
//  MovieLIstVC.swift
//  Movies
//
//  Created by Baljeet Singh Raghav on 04/03/25.
//

import UIKit

class MovieLIstVC: UIViewController {
    @IBOutlet private weak var table: UITableView!
    @IBOutlet private weak var searchBar:UISearchBar!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    
    private var dispacthWorkItem: DispatchWorkItem?
    var viewModel:ProtocolMovieLIstVM?
    
    var pageNo:Int = 1
    
    //MARK: -  View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let urlSession =  URLSession(configuration: .default)
        let networkManager = NetworkManager(session: urlSession)  // Dependency injection
        viewModel = MovieLIstVM(networkManager: networkManager)
        apiCallingForFetchList()
    }
    
    //MARK:  Private View
    
    private func setupUI() {
        
        self.table.register(UINib(nibName: "MovieTVCell", bundle: nil), forCellReuseIdentifier: "MovieTVCell")
        
        viewModel?.didFetchError = { [weak self] error in
            guard let self =  self else{return}
            if let error = error {
                let alert =  UIAlertController.init(title: "Alert", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }
    
    func searchMoviesWithDelay(query: String) {
        // Cancel previous search if still pending
        dispacthWorkItem?.cancel()
        
        // Create a new DispatchWorkItem to handle the search after a delay
        let workItem = DispatchWorkItem { [weak self] in
            guard let self =  self else{return}
            self.apiCallingForSearchMoview(text: query)
        }
        
        // Set a delay before search api calling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
        
        // Store the work item so that it can be cancelled if needed
        dispacthWorkItem = workItem
    }
    
    //MARK: -  API Calling
    
    func apiCallingForFetchList(){
        
        Task {
            indicator.startAnimating()
            await viewModel?.apiCallingForFetchList(pageNo:pageNo, completionBlock: { [weak self] in
                guard let self = self else{return}
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            })
            indicator.stopAnimating()
        }
    }
    
    func apiCallingForSearchMoview(text:String){
        
        Task {
            indicator.startAnimating()
            await viewModel?.apiCallingForSearchMovieList(byTitle: text, completionBlock: { [weak self] in
                guard let self = self else{return}
                DispatchQueue.main.async {
                    self.table.reloadData()
                    if self.viewModel?.list.count == 0 {
                        let alert =  UIAlertController.init(title: "Alert", message: "No Record Found", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(alert, animated: true)
                    }
                }
            })
            indicator.stopAnimating()
        }
    }
}


//MARK: - UItableView Delegate and Datasource

extension MovieLIstVC:UITableViewDelegate, UITableViewDataSource,MovieTVCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRowsInSection() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell  = tableView.dequeueReusableCell(withIdentifier: "MovieTVCell", for: indexPath) as? MovieTVCell {
            cell.delegate =  self
            cell.indexpath = indexPath
            cell.item =  viewModel?.bindCellDataVM(at: indexPath)
            cell.bindData()
            cell.selectionStyle =  .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace with your actual storyboard name if needed
        
        if let movieDetailsVC = storyboard.instantiateViewController(withIdentifier: "MovieDetailsVC") as? MovieDetailsVC {
            if let item = viewModel?.list[indexPath.row] {
                movieDetailsVC.item = item
            }
            movieDetailsVC.indexpath = indexPath
            movieDetailsVC.delegate =  self
            navigationController?.pushViewController(movieDetailsVC, animated: true)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            // Trigger lazy loading (fetch more data)
            pageNo += 1
            if pageNo < viewModel?.total_pages ?? 0 {
                self.apiCallingForFetchList()
            }
        }
    }
    
    func updateBookMArkData(indexpath:IndexPath, item:MovieListItem?) {
        if let updatedItemData = item {
            viewModel?.list[indexpath.row] = updatedItemData
            if let id = updatedItemData.id {
                viewModel?.updateObjectBasedOnId(id: id, object: updatedItemData)
            }
            table.reloadRows(at: [indexpath], with: .automatic)
        }
    }
}

extension MovieLIstVC:UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Call the searchMoviesWithDelay method when the user types in the search bar
        if searchText.count == 0 {
            //pageNo =  1
            self.viewModel?.fetchMoviesFromLocalDatabase()
            self.table.reloadData()
            
        }else{
            searchMoviesWithDelay(query: searchText)
        }
    }
}
