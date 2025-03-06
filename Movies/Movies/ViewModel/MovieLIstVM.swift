//
//  MovieLIstVM.swift
//  Movies
//
//  Created by Baljeet Singh Raghav on 04/03/25.
//

import Foundation
import CoreData

protocol ProtocolMovieLIstVM {
    func apiCallingForFetchList(pageNo:Int, completionBlock:@escaping()->()) async
    func apiCallingForSearchMovieList(byTitle title: String, completionBlock:@escaping()->()) async
    var list:[MovieListItem] {get set}
    var total_pages:Int {get set}
    func numberOfRowsInSection()->Int
    func bindCellDataVM(at indexpath:IndexPath)-> MovieListItem
    func insertMovie(model:MovieListItem)
    func updateObjectBasedOnId(id: Int, object:MovieListItem)
    var didFetchError: ((Error?) -> Void)? {get set}
    func fetchMoviesFromLocalDatabase()
    
}

class MovieLIstVM:ProtocolMovieLIstVM {
   
    var didFetchError: ((Error?) -> Void)?
    var list:[MovieListItem] = []
    var total_pages =  1
    private let networkManager:ProtocolNetworkManager?
    
    init(networkManager: ProtocolNetworkManager) {
        self.networkManager = networkManager
    }

    //MARK: -  Core data related methods
    
    
    func savebackground(){
        
    }
    func methodToSaveLOcally(){
        let context = CoreData.shared.managedObjectContext
        print("Documents Directory: ", FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last ?? "Not Found!")
       context.perform {
           if self.list.count > 0 {
               for item in self.list {
                   if let id =  item.id {
                       let fetchRequest: NSFetchRequest<Movies> = Movies.fetchRequest()
                       fetchRequest.predicate = NSPredicate(format: "id == %d", id)
                       do {
                           // Perform the fetch request
                           let results = try context.fetch(fetchRequest)
                           
                           // If there are no results, it's safe to insert
                           if results.isEmpty {
                               debugPrint("Movie id going to Save", item.id)
                               self.insertMovie(model: item)
                           }
                       }catch{
                           print("Error checking for duplicate: \(error)")
                       }
                   }else{
                       debugPrint("Movie id going to Save", item.id)
                       self.insertMovie(model: item)
                   }
               }
           }
        }
    }
    
    
    
    func insertMovie(model:MovieListItem) {
        // Get the context from the shared CoreDataStack
        let context = CoreData.shared.managedObjectContext

        // Create a new Movie entity object
        let movie = Movies(context: context)
        movie.adult = model.adult ??  false
        movie.backdrop_path = model.backdrop_path
   
        if let arrIds =  model.id {
            movie.id = Int64(arrIds)
        }
        
        movie.original_language = model.original_language
        movie.original_title = model.original_title
        movie.overview = model.overview
        if let popularity =  model.popularity {
            movie.setValue(popularity, forKey: "popularity")
        }
        
        movie.poster_path = model.poster_path
        movie.release_date = model.release_date
        movie.title = model.title
      //  movie.video = model.video
        
        if let video =  model.video {
            movie.setValue(video, forKey: "video")
        }
        if let vote_average =  model.vote_average {
            movie.setValue(vote_average, forKey: "vote_average")
        }
        if let isFavorit =  model.isFavorit {
            movie.setValue(isFavorit, forKey: "isFavorit")
        }
     
        // Save the context
        CoreData.shared.saveContext()
    }
    
    func updateObjectBasedOnId(id: Int, object:MovieListItem) {
        // Create a fetch request to find the object based on the id
        let context = CoreData.shared.managedObjectContext
        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
        debugPrint("Movie id is going to Update", id)
        let fetchRequest: NSFetchRequest<Movies> = Movies.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            // Perform the fetch request
            let results = try context.fetch(fetchRequest)
            if let objectToUpdate = results.first {
                if let status =  object.isFavorit {
                    objectToUpdate.isFavorit = status
                }
                try context.save()
                print("Object updated successfully.")
            } else {
                print("No object found with id \(id).")
            }
        } catch {
            print("Failed to fetch or save object: \(error)")
        }
    }
    
    func fetchMoviesFromLocalDatabase() {
        var listData = [MovieListItem]()
        let context = CoreData.shared.managedObjectContext
        
        // Create a fetch request for the Movies entity
        let fetchRequest: NSFetchRequest<Movies> = Movies.fetchRequest()
       
        do {
            // Perform the fetch request to get all the movies
            let movies = try context.fetch(fetchRequest)
            
            // Iterate through the fetched movies
            for movie in movies {

                let item =  MovieListItem(adult: movie.adult, backdrop_path: movie.backdrop_path, genre_ids:[], id: Int(movie.id), original_language: movie.original_language, overview:movie.overview, popularity:movie.popularity, poster_path:movie.poster_path,  release_date: movie.release_date, title:movie.title, video:movie.video, vote_average: movie.vote_average,vote_count:Int(movie.vote_count),  isFavorit:movie.isFavorit )
               
                listData.append(item)
            }
            self.list = listData
        } catch {
            print("Error fetching movies: \(error)")
        }
    }
    //MARK: - API Methods
    
    
    func apiCallingForFetchList(pageNo:Int, completionBlock:@escaping()->()) async {
       
        let urlStr = "\(APIs.baseURL)movie/popular?api_key=" + "\(APIs.apiKey)&language=en-US&page=" + "\(pageNo)"
        debugPrint("URL is", urlStr)
       
        guard let url = URL(string: urlStr) else{return}
        
        networkManager?.fetchData(url: url, params: nil, method: .GET) { (result: Result<MovieListResponseModel, Error>) in
            switch result {
            case .success(let fetchedData):
                if self.list.count > 0 {
                    if let records = fetchedData.results {
                        self.list.append(contentsOf: records)
                    }
                }else{
                    self.list = fetchedData.results ?? []
                }
                debugPrint("*****Received response from api******", fetchedData)
                self.methodToSaveLOcally()
                self.total_pages = fetchedData.total_pages ?? 0
                // Pass data back to ViewController
                completionBlock()
             case .failure(let fetchError):
             self.didFetchError?(fetchError)  // Pass error back to ViewController
            }
        }
    }
    
    func apiCallingForSearchMovieList(byTitle title: String, completionBlock:@escaping()->()) async {
      
        let urlStr = "\(APIs.baseURL)search/movie?api_key=" + "\(APIs.apiKey)&language=en-US&query=" + "\(title)"
        guard let url = URL(string: urlStr) else{return}
        networkManager?.fetchData(url: url, params: nil, method: .GET) { (result: Result<MovieListResponseModel, Error>) in
            switch result {
            case .success(let fetchedData):
                self.list = fetchedData.results ?? []
                self.total_pages = fetchedData.total_pages ?? 0
                // Pass data back to ViewController
                completionBlock()
             case .failure(let fetchError):
             self.didFetchError?(fetchError)  // Pass error back to ViewController
            }
        }
    }
    
    
    func numberOfRowsInSection()->Int {
        self.list.count
    }
    
    func bindCellDataVM(at indexpath:IndexPath)-> MovieListItem {
        return self.list[indexpath.row]
    }
}
