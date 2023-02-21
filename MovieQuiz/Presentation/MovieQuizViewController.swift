import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!


    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory?.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
    }


    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }


    // MARK: - Private Methods
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func show(quiz result: QuizResultsViewModel) {
        guard let statisticService else {
            return
        }
        statisticService.store(correct: correctAnswers, total: questionAmount)

        let quizCountText = "Количество сыгранных квизов \(statisticService.gamesCount)"
        let recordText = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100 / Double(statisticService.gamesCount)))%"
        let message = "\(result.text)\n \(quizCountText)\n \(recordText)\n \(accuracyText)"

        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText) { [weak self] in
                guard let self else {return}
                self.currentQuestionIndex = 0
                self.correctAnswers = 0

                self.questionFactory?.requestNextQuestion()
            }
        alertPresenter?.show(alertModel: alertModel)
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        enableButtons(false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else {return}
            self.showNextQuestionOrResult()
            self.imageView.layer.borderWidth = 0
            self.enableButtons(true)
        }
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStepViewModel = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return quizStepViewModel
    }

    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionAmount - 1 {
            let resultsViewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionAmount)",
                buttonText: "Сыграть ещё раз")
            show(quiz: resultsViewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    private func enableButtons(_ enable: Bool) {
        noButton.isEnabled = enable
        yesButton.isEnabled = enable
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}

// MARK: - AlertPresenterDelegate
extension MovieQuizViewController: AlertPresenterDelegate {
    func presentAlertView(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
}
