//
//  ViewController.swift
//  carNavigationSystem
//
//  Created by K I on 2023/07/26.
//

import UIKit

class ViewController: UIViewController {
    
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        
        let flickButton = FlickButton()
        view.addSubview(flickButton)
        flickButton.delegate = self
        flickButton.defaultColor = .darkGray
        flickButton.activeColor = .cyan
        flickButton.setTitle("CENTER", for: .normal)
        flickButton.setTitleColor(.white, for: .normal)
        flickButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        flickButton.addTarget(self, action: #selector(handleFlickButtonTouchUpInsideEvent(_:)), for: .touchUpInside)
        flickButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            flickButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            flickButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            flickButton.widthAnchor.constraint(equalToConstant: 128),
            flickButton.heightAnchor.constraint(equalTo: flickButton.widthAnchor),
        ])
        
        let topView = UILabel()
        flickButton.topView = topView
        topView.text = "TOP"
        topView.textColor = .white
        topView.textAlignment = .center
        topView.font = .boldSystemFont(ofSize: 18)
        let bottomView = UILabel()
        flickButton.bottomView = bottomView
        bottomView.text = "BOTTOM"
        bottomView.textColor = .white
        bottomView.textAlignment = .center
        bottomView.font = .boldSystemFont(ofSize: 18)
        let leftView = UILabel()
        flickButton.leftView = leftView
        leftView.text = "LEFT"
        leftView.textColor = .white
        leftView.textAlignment = .center
        leftView.font = .boldSystemFont(ofSize: 18)
        let rightView = UILabel()
        flickButton.rightView = rightView
        rightView.text = "RIGHT"
        rightView.textColor = .white
        rightView.textAlignment = .center
        rightView.font = .boldSystemFont(ofSize: 18)
        
        view.addSubview(label)
        label.backgroundColor = .darkGray
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            label.heightAnchor.constraint(equalToConstant: 64),
        ])
    }
    
    @objc
    private func handleFlickButtonTouchUpInsideEvent(_ sender: FlickButton) {
        label.text = sender.title(for: .normal)
    }
    
}

extension ViewController: FlickButtonDelegate {
    
    func flickButton(_ flickButton: FlickButton, didFlick activatedView: UIView) {
        if let flickButton = activatedView as? FlickButton {
            label.text = flickButton.title(for: .normal)
        } else {
            label.text = (activatedView as? UILabel)?.text
        }
    }
    
}

