//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Вадим Кузьмин on 30.01.2023.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: AlertPresenterDelegate?

    init(delegate: AlertPresenterDelegate?) {
        self.delegate = delegate
    }

    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
        alert.addAction(action)
        delegate?.presentAlertView(alert: alert)
    }
}
