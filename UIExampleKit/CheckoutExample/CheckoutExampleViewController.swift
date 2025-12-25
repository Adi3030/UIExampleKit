import UIKit

// CheckoutStepsView.swift
// Single-file UIKit example that recreates the top checkout steps row (Cart -> Address -> Personalize -> Payment)

 

// MARK: - Example of usage in a ViewController

final class CheckoutExampleViewController: UIViewController {
    private let stepsView = CheckoutStepsView()
    private let nextButton = UIButton(type: .system)
    private let prevButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Container to mimic the screenshot's pale background and rounded top bar
        let topContainer = UIView()
        topContainer.backgroundColor = .appDark
        topContainer.layer.cornerRadius = 8
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topContainer)

        // Add steps view inside top container
        stepsView.translatesAutoresizingMaskIntoConstraints = false
        topContainer.addSubview(stepsView)
        


        // Controls to test step change
        nextButton.setTitle("Next", for: .normal)
        prevButton.setTitle("Prev", for: .normal)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        let controls = UIStackView(arrangedSubviews: [prevButton, nextButton])
        controls.axis = .horizontal
        controls.spacing = 12
        controls.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controls)

        NSLayoutConstraint.activate([
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            topContainer.heightAnchor.constraint(equalToConstant: 88),

            stepsView.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 8),
            stepsView.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -8),
            stepsView.topAnchor.constraint(equalTo: topContainer.topAnchor, constant: 12),
            stepsView.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -12),

            controls.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: 20),
            controls.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // initial step
        stepsView.setStep(.cart, animated: false)
    }

    @objc private func nextTapped() {
        let next = min(CheckoutStepsView.Step.allCases.count - 1, stepsView.currentStep + 1)
        guard let step = CheckoutStepsView.Step(rawValue: next) else { return }
        stepsView.setStep(step, animated: true)
    }

    @objc private func prevTapped() {
        let prev = max(0, stepsView.currentStep - 1)
        guard let step = CheckoutStepsView.Step(rawValue: prev) else { return }
        stepsView.setStep(step, animated: true)
    }
}

