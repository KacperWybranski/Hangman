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
    let wordsToGuess: [String] = ["KACZKA","PIES","OKO","KOTECZEK","AUTO","ZAMEK"]
    var answer: String!
    var loadingPieces = [UIButton]()
    var redPieces: Int = 0
    
    var activeButtons = [UIButton]() {
        didSet {
            for btn in activeButtons {
                btn.isHidden = true
            }
        }
    }
    
    var hiddenAnswer: String! {
        didSet {
            currentWord.text = hiddenAnswer
            if hiddenAnswer == answer {
                gameWon()
            }
        }
    }
    
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
       
        let qwerty = ["Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M"]
       
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
        redPieces = 0
        for btn in loadingPieces {
            btn.layer.backgroundColor = UIColor.systemGreen.cgColor
        }
        answer = wordsToGuess.randomElement()
        hiddenAnswer = ""
        
        for _ in answer {
            hiddenAnswer += "-"
        }
        
        for btn in activeButtons {
            btn.isHidden = false
        }
        activeButtons.removeAll()
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        var letterFound: Bool = false
        activeButtons += [sender]
        if let btn = sender.titleLabel?.text {
            for (i, ltr) in answer.enumerated() {
                if ltr == Character(btn) {
                    letterFind(letter: ltr, index: i)
                    letterFound = true
                }
            }
            if !letterFound {
                letterMissed()
            }
        }
    }
    
    func letterFind(letter: Character, index: Int) {
        var tmpAnswer = ""
        for (i, chr) in hiddenAnswer.enumerated() {
            if i == index {
                if chr == "-" {
                    tmpAnswer += String(letter)
                }
            } else {
                tmpAnswer += String(chr)
            }
        }
        hiddenAnswer = tmpAnswer
    }
    
    func letterMissed() {
        redPieces += 1
        loadingPieces[redPieces-1].layer.backgroundColor = UIColor.systemRed.cgColor
        if redPieces < 7 {
            return
        } else {
            let ac = UIAlertController(title: "Przegrałeś!", message: "Spróbuj jeszcze raz", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel) { [weak self] action in
                self?.startGame()
                })
            present(ac, animated: true)
        }
    }
    
    func gameWon() {
        let ac = UIAlertController(title: "BRAWO :D", message: "Udało ci się odgadnąć :)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel) { [weak self] action in
            self?.startGame()
        })
        present(ac, animated: true)
    }
}

