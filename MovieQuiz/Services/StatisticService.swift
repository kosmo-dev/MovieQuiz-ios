//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Вадим Кузьмин on 13.02.2023.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    let jsonDecoder = JSONDecoder()
    let jsonEncoder = JSONEncoder()

    private let userDefaults = UserDefaults.standard

    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }

    var totalAccuracy: Double {
        get {
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let total = try? jsonDecoder.decode(Double.self, from: data) else {
                return 0
            }
            return total
        }
        set {
            guard let data = try? jsonEncoder.encode(newValue) else {
                print("Невозможно сохранить точность")
                return
            }
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }

    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let count = try? jsonDecoder.decode(Int.self, from: data) else {
                return 0
            }
            return count
        }
        set {
            guard let data = try? jsonEncoder.encode(newValue) else {
                print("Невозможно сохранить количество игр")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Hевозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }

    func store(correct count: Int, total amount: Int) {
        let currentAccuracy: Double = Double(count) / Double(amount)
        gamesCount += 1
        totalAccuracy += currentAccuracy
        let newGame = GameRecord(correct: count, total: amount, date: Date())
        if newGame > bestGame {
            bestGame = newGame
        }
    }

    func clean() {
        totalAccuracy = 0
        gamesCount = 0
    }
}
