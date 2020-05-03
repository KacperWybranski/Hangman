//
//  ViewController.swift
//  Challenge3Wisielec
//
//  Created by test on 30/04/2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var currentWord: UILabel!
    var currentLetter: UITextField!
    var buttonsView: UIView!
    var loadingView: UIView!
    var letterButtons = [UIButton]()
    let wordsToGuess: [String] = ["KACZKA","PIES"]
    var activeButtons = [UIButton]() {
        didSet {
            for btn in activeButtons {
                btn.isHidden = true
            }
        }
    }
    var answer: String!
    var hiddenAnswer: String! {
        didSet {
            currentWord.text = hiddenAnswer
        }
    }
    var loadingPieces = [UIButton]()
    var redPieces: Int = 0
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        currentWord = UILabel()
        currentWord.translatesAutoresizingMaskIntoConstraints = false
        currentWord.text = "Hello"
        currentWord.font = UIFont.systemFont(ofSize: 50)
        currentWord.textAlignment = .center
        view.addSubview(currentWord)
        
        buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        loadingView = UIView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            currentWord.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            currentWord.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            
            buttonsView.heightAnchor.constraint(equalToConstant: 240),
            buttonsView.widthAnchor.constraint(equalToConstant: 360),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: currentWord.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
            
            loadingView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 150),
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.widthAnchor.constraint(equalToConstant: 350),
            loadingView.heightAnchor.constraint(equalToConstant: 80),
            
        ])
        
        createLetterButtons()
        createLoadingPieces()
        startGame()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func generateGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.systemPink.cgColor]
        return gradientLayer
    }
    
    func createLetterButton(col: Int, row: Int, startingOnX: Int) {
        let width = 36
        let height = 80
        
        let letterButton = UIButton(type: .system)
        letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        letterButton.setTitle("X", for: .normal)
         
        let frame = CGRect(x: startingOnX+col*width, y: row*height, width: width-4, height: height-4)
        letterButton.frame = frame
        letterButton.layer.cornerRadius = CGFloat(0.4*Double(width))
        letterButton.layer.backgroundColor = UIColor.systemGray6.cgColor
        
        letterButtons += [letterButton]
        letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        buttonsView.addSubview(letterButton)
    }
    
    func createLetterButtons() {
        for row in 0..<3 {
            if row == 0 {
                for col in 0..<10 {
                    createLetterButton(col: col, row: row, startingOnX: 2)
                }
            } else if row == 1 {
                for col in 0..<9 {
                    createLetterButton(col: col, row: row, startingOnX: 20)
                }
            } else {
                for col in 0..<7 {
                    createLetterButton(col: col, row: row, startingOnX: 54)
                }
            }
        }
       
        let qwerty = ["q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m"]
       
        if qwerty.count == letterButtons.count {
            for (i, btn) in letterButtons.enumerated() {
                btn.setTitle(qwerty[i], for: .normal)
            }
        }
    }
    
    func createLoadingPieces() {
        let width = 50
        let height = 80
        
        for btn in 0..<7 {
            let loadingPiece = UIButton(type: .system)
             
            let frame = CGRect(x: 2+btn*width, y: 0, width: width-4, height: height-4)
            loadingPiece.frame = frame
            loadingPiece.layer.cornerRadius = CGFloat(0.4*Double(width))
            loadingPiece.layer.backgroundColor = UIColor.systemGreen.cgColor
            loadingPiece.layer.borderWidth = 2
            loadingPiece.layer.borderColor = UIColor.systemGray.cgColor
            loadingPiece.isUserInteractionEnabled = false
            
            loadingPieces += [loadingPiece]
            loadingView.addSubview(loadingPiece)
        }
    }
    
    func startGame() {
        answer = wordsToGuess.randomElement()?.lowercased()
        hiddenAnswer = ""
        
        for _ in answer {
            hiddenAnswer += "-"
        }
        
        activeButtons.removeAll()
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        activeButtons += [sender]
        if let btn = sender.titleLabel?.text?.lowercased() {
            for (i, ltr) in answer.enumerated() {
                if ltr == Character(btn) {
                    letterGuessed(letter: ltr, index: i)
                    return
                }
            }
            letterMissed()
        }
    }
    
    func letterGuessed(letter: Character, index: Int) {
        
    }
    
    func letterMissed() {
        redPieces += 1
        if redPieces <= 7 {
        loadingPieces[redPieces-1].layer.backgroundColor = UIColor.systemRed.cgColor
        } else {
            let ac = UIAlertController(title: "THE END", message: "Postaraj sie nastepnym razem", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
        }
    }
}

