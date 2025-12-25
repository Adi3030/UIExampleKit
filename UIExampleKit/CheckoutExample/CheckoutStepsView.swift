//
//  aaa.swift
//  Delbaram
//
//  Created by Aditya Sharma on 11/12/25.
//
import UIKit

final class CheckoutStepsView: UIView {
    public enum Step: Int, CaseIterable {
        case cart = 0, address, personalize, payment
        var title: String {
            switch self {
            case .cart: return "Cart"
            case .address: return "Address"
            case .personalize: return "Personalize"
            case .payment: return "Payment"
            }
        }
    }

    // Appearance
    public var doneColor: UIColor = UIColor(red: 0.85, green: 0.06, blue: 0.39, alpha: 1)
    public var inactiveColor: UIColor = .lightGray
    public var circleSize: CGFloat = 28
    public var lineHeight: CGFloat = 2

    // Subviews / layers
    private let stackView = UIStackView()
    private var circleViews: [UIView] = []
    private var numberLabels: [UILabel] = []
    private var titleLabels: [UILabel] = []
    private var separators: [UIView] = []    // kept only for layout spacing (not drawing connector)
    private(set) var currentStep: Int = 0

    // SINGLE connector layer (dashed)
    private let pendingConnectorLayer = CAShapeLayer()

    // init
    override init(frame: CGRect) { super.init(frame: frame); commonInit() }
    required init?(coder: NSCoder) { super.init(coder: coder); commonInit() }

    private func commonInit() {
        backgroundColor = .clear

        // configure only the single dashed connector
        pendingConnectorLayer.lineWidth = lineHeight
        pendingConnectorLayer.lineDashPattern = [4, 4] as [NSNumber]
        pendingConnectorLayer.fillColor = nil
        pendingConnectorLayer.lineCap = .round
        layer.addSublayer(pendingConnectorLayer)

        setupStackView()
        configureSteps()
        updateAppearance(animated: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateConnectors()
        updateAppearance(animated: false)
    }

    private func setupStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    private func configureSteps() {
        let steps = Step.allCases
        for (index, step) in steps.enumerated() {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false

            let circle = UIView()
            circle.layer.cornerRadius = circleSize / 2
            circle.layer.borderWidth = 1
            circle.layer.borderColor = inactiveColor.cgColor
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.widthAnchor.constraint(equalToConstant: circleSize).isActive = true
            circle.heightAnchor.constraint(equalToConstant: circleSize).isActive = true

            let numberLabel = UILabel()
            numberLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            numberLabel.textAlignment = .center
            numberLabel.translatesAutoresizingMaskIntoConstraints = false
            numberLabel.text = "\(index + 1)"

            let titleLabel = UILabel()
            titleLabel.font = .systemFont(ofSize: 12)
            titleLabel.textAlignment = .center
            titleLabel.text = step.title
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.numberOfLines = 1

            let vstack = UIStackView(arrangedSubviews: [circle, titleLabel])
            vstack.axis = .vertical
            vstack.alignment = .center
            vstack.spacing = 6
            vstack.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(vstack)
            container.addSubview(numberLabel)

            NSLayoutConstraint.activate([
                vstack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                vstack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                numberLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                numberLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
                titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 110)
            ])

            circle.backgroundColor = .white
            circleViews.append(circle)
            numberLabels.append(numberLabel)
            titleLabels.append(titleLabel)

            if index < steps.count - 1 {
                // spacer view only; we will NOT draw connector on these views
                let sep = UIView()
                sep.translatesAutoresizingMaskIntoConstraints = false
                sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
                separators.append(sep)

                let wrapper = UIStackView(arrangedSubviews: [container, sep])
                wrapper.axis = .horizontal
                wrapper.alignment = .center
                wrapper.spacing = 8

                sep.setContentHuggingPriority(.defaultLow, for: .horizontal)
                container.setContentHuggingPriority(.defaultHigh, for: .horizontal)

                stackView.addArrangedSubview(wrapper)
                sep.widthAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
            } else {
                stackView.addArrangedSubview(container)
            }
        }
    }

    // draw SINGLE dashed connector across all circle centers
    private func updateConnectors() {
        guard !circleViews.isEmpty else { return }
        let centers: [CGPoint] = circleViews.compactMap { circle in
            return circle.superview?.convert(circle.center, to: self) ?? circle.center
        }

        let path = UIBezierPath()
        for (i, c) in centers.enumerated() {
            if i == 0 { path.move(to: c) } else { path.addLine(to: c) }
        }

        pendingConnectorLayer.path = path.cgPath
        pendingConnectorLayer.frame = bounds

        // single connector always uses inactive color (dashed). If you prefer a different color after completion,
        // we keep it simple: dashed line is inactiveColor; completed state is only shown by filled circles.
        pendingConnectorLayer.strokeColor = inactiveColor.cgColor
    }

    public func setStep(_ step: Step, animated: Bool) {
        currentStep = step.rawValue
        updateAppearance(animated: animated)
        setNeedsLayout()
    }

    private func updateAppearance(animated: Bool) {
        for (index, circle) in circleViews.enumerated() {
            let numberLabel = numberLabels[index]
            let titleLabel = titleLabels[index]

            let isActive = index == currentStep
            let isDone = index < currentStep

            let borderColor = (isActive || isDone) ? doneColor : inactiveColor
            let bgColor: UIColor = isDone ? doneColor : (isActive ? .white : .white)
            let numberColor: UIColor = isDone ? .white : (isActive ? doneColor : inactiveColor)
            let titleColor: UIColor = (isDone || isActive) ? doneColor : inactiveColor

            let apply = {
                circle.layer.borderColor = borderColor.cgColor
                circle.backgroundColor = bgColor
                numberLabel.textColor = numberColor
                titleLabel.textColor = titleColor

                if isDone {
                    circle.backgroundColor = self.doneColor
                    numberLabel.textColor = .white
                    numberLabel.text = "✓"
                } else {
                    numberLabel.text = "\(index + 1)"
                }
            }

            if animated {
                UIView.animate(withDuration: 0.25) { apply() }
            } else {
                apply()
            }
        }

        // redraw connector color (we keep it single dashed line)
        pendingConnectorLayer.strokeColor = inactiveColor.cgColor
    }
}

