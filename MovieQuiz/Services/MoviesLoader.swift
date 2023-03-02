//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Вадим Кузьмин on 02.03.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {

    private let networkClient = NetworkClient()

    private var mostPopularMoviesURL: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_wo1d3xx6") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesURL) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            }
        }
    }
}
