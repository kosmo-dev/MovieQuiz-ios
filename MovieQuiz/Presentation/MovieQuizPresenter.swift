//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Вадим Кузьмин on 06.03.2023.
//

import UIKit

final class MovieQuizPresenter {
    // MARK: - Private Properties
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0

    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?

    // MARK: - Initializers
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController

        statisticService = StatisticServiceImplementation()

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }

    // MARK: - Public Methods
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }

    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)

        let bestGame = statisticService.bestGame

        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")

        return resultMessage
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStepViewModel = QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                                  question: model.text,
                                                  questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return quizStepViewModel
    }

    // MARK: - Private Methods
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    private func proceedToNextQuestionOrResult() {
        if isLastQuestion() {
            let resultsViewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: resultsViewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }

    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)

        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.enableButtons(false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else {
                return
            }
            self.viewController?.makeDefaultImage()
            self.viewController?.enableButtons(true)
            self.proceedToNextQuestionOrResult()
        }
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            self.viewController?.show(quiz: viewModel)
        }
    }
}
