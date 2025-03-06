//
//  NetworkManager.swift
//  Movies
//
//  Created by Baljeet Singh Raghav on 04/03/25.
//

import Foundation
import Combine

protocol ProtocolNetworkManager {
    func fetchData<T: Decodable>(url: URL, params:[String:Any]?, method:HTTPMethod, completion:@escaping(Result<T, Error>)-> Void)
    
}
class NetworkManager:ProtocolNetworkManager {
    
    
    private let session:URLSession
    private var cancellables = Set<AnyCancellable>()
        
    init(session: URLSession) {
        self.session = session
    }


func fetchData<T: Decodable>(url: URL, params:[String:Any]?, method:HTTPMethod, completion:@escaping(Result<T, Error>)-> Void) {
    
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            
            // Handle POST method by adding parameters to the body
            if method == .POST, let parameters = params {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    completion(.failure(error))
                    return
                }
            }
            
            // Perform the network request
            let task = session.dataTask(with: request) { data, response, error in
                let httpResponse = response as? HTTPURLResponse
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "NetworkError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received."])))
                    return
                }
                
                // Decode the response data into the expected model
                do {
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
//MARK: - Methods

enum HTTPMethod:String{
    case GET
    case POST
}
