//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Вадим Кузьмин on 06.03.2023.
//

import UIKit

final class MovieQuizPresenter {
    let questionsAmount = 10
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestion?

    weak var viewController: MovieQuizViewController?

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStepViewModel = QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                                  question: model.text,
                                                  questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return quizStepViewModel
    }

    func yesButtonClicked() {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    func noButtonClicked() {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
