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
    var scoreLabel: UILabel!
    let wordsToGuess: [String] = ["KWADRAT","MYSZ","KWIATUSZEK","STRONA","HERBATA","MAKARON"]
    var wordsToGuessWithoutAlreadyGuessed = [String]()
    var answer: String!
    var loadingPieces = [UIButton]()
    var redPieces: Int = 0
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Wynik: \(score)"
        }
    }
    
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
                wordFound()
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
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "Wynik: \(score)"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        scoreLabel.textAlignment = .right
        view.addSubview(scoreLabel)
        
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
            
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
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
        wordsToGuessWithoutAlreadyGuessed = wordsToGuess
        score = 0
        
        continueGame()
    }
    
    func continueGame() {
        redPieces = 0
        for btn in loadingPieces {
            btn.layer.backgroundColor = UIColor.systemGreen.cgColor
        }
        
        if !wordsToGuessWithoutAlreadyGuessed.isEmpty {
            let numbers: Range<Int> = 0..<wordsToGuessWithoutAlreadyGuessed.count
            guard let randomNumber = numbers.randomElement() else { return }
            answer = wordsToGuessWithoutAlreadyGuessed.remove(at: randomNumber)
            hiddenAnswer = ""
            
            for _ in answer {
                hiddenAnswer += "-"
            }
            
            for btn in activeButtons {
                btn.isHidden = false
            }
            activeButtons.removeAll()
        } else {
            gameEnded()
        }
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
            let message = """
            Hasło to \(answer ?? "hasło")
            Spróbuj jeszcze raz :)
            """
            let ac = UIAlertController(title: "Nie odgadłeś!", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel) { [weak self] action in
                self?.continueGame()
                })
            present(ac, animated: true)
        }
    }
    
    func wordFound() {
        score += 1
        let ac = UIAlertController(title: "BRAWO :D", message: "Udało ci się odgadnąć :)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel) { [weak self] action in
            self?.continueGame()
        })
        present(ac, animated: true)
    }
    
    func gameEnded() {
        var pronounce = String()
        switch score {
        case 1:
            pronounce = "słowo"
        case 2...4:
            pronounce = "słowa"
        default:
            pronounce = "słów"
        }
        let ac = UIAlertController(title: "Koniec gry!", message: "Odgadłeś \(score) \(pronounce) z \(wordsToGuess.count) :)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Gram od nowa!", style: .cancel) { [weak self] action in
            self?.startGame()
        })
        present(ac, animated: true)
    }
}

