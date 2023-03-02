//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Вадим Кузьмин on 27.01.2023.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {

    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?

//    private var questions: [QuizQuestion] = [
//        QuizQuestion(image: "The Godfather",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: true),
//        QuizQuestion(image: "The Dark Knight",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: true),
//        QuizQuestion(image: "Kill Bill",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: true),
//        QuizQuestion(image: "The Avengers",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: true),
//        QuizQuestion(image: "Deadpool",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: true),
//        QuizQuestion(image: "The Green Knight",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: true),
//        QuizQuestion(image: "Old",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: false),
//        QuizQuestion(image: "The Ice Age Adventures of Buck Wild",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: false),
//        QuizQuestion(image: "Tesla",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: false),
//        QuizQuestion(image: "Vivarium",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: false)
//    ]
    private var movies: [MostPopularMovie] = []

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else {
                return
            }
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else {
                return
            }
            var imageData = Data()

            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }

            let rating = Float(movie.rating) ?? 0

            let randomRating = Int.random(in: 6...9)
            let text = "Рейтинг фильма больше, чем \(randomRating)?"
            let correctAnswer = rating > Float(randomRating)

            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)

            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else {
                    return

                }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
