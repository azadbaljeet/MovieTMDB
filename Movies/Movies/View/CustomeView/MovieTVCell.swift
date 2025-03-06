//
//  MovieTVCell.swift
//  Movies
//
//  Created by Baljeet Singh Raghav on 04/03/25.
//

import UIKit

protocol MovieTVCellDelegate:AnyObject {
    func updateBookMArkData(indexpath:IndexPath, item:MovieListItem?)
}

class MovieTVCell: UITableViewCell {
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var imgView: UIImageView!
    @IBOutlet private weak var lblDescription: UILabel!
    @IBOutlet private weak var lblReleaseDate: UILabel!
    @IBOutlet private weak var lblVoteCount: UILabel!
    @IBOutlet private weak var lblRatingCount: UILabel!
    @IBOutlet private weak var btnBookMark: UIButton!
    var indexpath:IndexPath?
    var item:MovieListItem?
    var delegate:MovieTVCellDelegate? =  nil
    var imageUrlString: String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction private func actionBookMArk(sender:UIButton) {
        if let status = item?.isFavorit, status{
            item?.isFavorit = false
        }else{
            item?.isFavorit = true
        }
        if let index = indexpath {
            self.delegate?.updateBookMArkData(indexpath: index, item: item)
        }
    }
    
    func bindData(){
        if let data =  item {
            title.text = data.title
            lblDescription.text = data.overview
            
            if let path =  data.poster_path {
                imageUrlString = path
                
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
        }
    }
}
