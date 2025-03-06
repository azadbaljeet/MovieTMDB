//
//  MovieDetailsVC.swift
//  Movies
//
//  Created by Baljeet Singh Raghav on 05/03/25.
//

import UIKit

class MovieDetailsVC: UIViewController {
    
    @IBOutlet private weak var lblTitle: UILabel!
    @IBOutlet private weak var imgView: UIImageView!
    @IBOutlet private weak var lblDescription: UILabel!
    @IBOutlet private weak var lblReleaseDate: UILabel!
    @IBOutlet private weak var lblVoteCount: UILabel!
    @IBOutlet private weak var lblVoteAverage: UILabel!
    @IBOutlet private weak var btnBookMark: UIButton!
    var item:MovieListItem?
    var indexpath:IndexPath?
    var delegate:MovieTVCellDelegate? =  nil
    
    //MARK: -  View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: -  Setup UI
    
    func setupUI(){
        if let data =  item {
            lblTitle.text = data.title
            lblDescription.text = data.overview
            
            if let path =  data.poster_path {
               
                // Check if the image is already cached
                if let cachedImage = imageCache.object(forKey: path as NSString) {
                    // Use the cached image if available
                    imgView.image = cachedImage
                }else{
                    imgView.loadImage(from: path)
                }
                imgView.layer.cornerRadius =  10
            }
            if let status =  data.isFavorit {
                if status {
                    btnBookMark.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                }else{
                    btnBookMark.setImage(UIImage(systemName: "bookmark"), for: .normal)
                }
            }
            
            if let date =  data.release_date {
                lblReleaseDate.text = date
            }
            if let vote_count =  data.vote_count {
                lblVoteCount.text = "\(vote_count)"
            }
            if let vote_average =  data.vote_average {
                lblVoteAverage.text = "\(vote_average)"
            }
            
        }
    }
    
    //MARK: -  Button Action
    
    @IBAction private func actionBookMArk(sender:UIButton) {
        if let status = item?.isFavorit, status{
            item?.isFavorit = false
        }else{
            item?.isFavorit = true
        }
        if let index = indexpath {
            self.delegate?.updateBookMArkData(indexpath: index, item: item)
        }
        setupUI()
    }
}
