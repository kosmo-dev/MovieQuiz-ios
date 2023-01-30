//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Вадим Кузьмин on 30.01.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String

    let completion: () -> Void
}
