//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Вадим Кузьмин on 30.01.2023.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func presentAlertView(alert: UIAlertController)
}
