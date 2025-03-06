//
//  APIs.swift
//  Movies
//
//  Created by Baljeet Singh Raghav on 05/03/25.
//

import Foundation
struct APIs {
    private static let api_key = "c92dba6359db8fd8bd0727c850b9c542"
    private static let base_url = "https://api.themoviedb.org/3/"
    private static let imag_base_url = "https://image.tmdb.org/t/p/w500/"
    
        static var apiKey: String {
            return api_key
        }
        
        static var baseURL: String {
            return base_url
        }
        
        static var imageBaseURL: String {
            return imag_base_url
        }
    
}

