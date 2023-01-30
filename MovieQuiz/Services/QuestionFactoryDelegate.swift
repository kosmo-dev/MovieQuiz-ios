//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Вадим Кузьмин on 30.01.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
