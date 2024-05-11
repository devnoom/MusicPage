//
//  MusicPageViewController.swift
//  MusicPage
//
//  Created by MacBook Air on 10.05.24.
//

import UIKit

final class MusicPageViewController: UIViewController {
    // MARK: - UI Components
    
    private var lastScaledButton: UIButton?
    private let favoriteStack = UIStackView()
    private let buttonsStack = UIStackView()
    private let footerStack = UIStackView()
    private let progressLineView = UIProgressView()
    
    private let musicImageView: UIImageView = {
        let musicImageView = UIImageView()
        musicImageView.contentMode = .scaleAspectFill
        musicImageView.clipsToBounds = true
        musicImageView.image = UIImage(named: "garrix")
        return musicImageView
    }()
    
    private let musicNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        label.textAlignment = .center
        label.text = "Hight on life (feat. Bonn)"
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let artist = UILabel()
        artist.textAlignment = .center
        artist.font = UIFont.systemFont(ofSize: 20)
        artist.text = "Martin Garrix"
        return artist
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play"), for: .normal)
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let nextSongButton: UIButton = {
        let nextSongButton = UIButton()
        nextSongButton.setImage(UIImage(named: "next"), for: .normal)
        return nextSongButton
    }()
    
    private let previousSongButton: UIButton = {
        let previousSongButton = UIButton()
        previousSongButton.setImage(UIImage(named: "previous"), for: .normal)
        return previousSongButton
    }()
    
    private let shuffleSongButton: UIButton = {
        let shuffleSongButton = UIButton()
        shuffleSongButton.setImage(UIImage(named: "shuffle"), for: .normal)
        return shuffleSongButton
    }()
    
    private let repeatSongButton: UIButton = {
        let repeatSongButton = UIButton()
        repeatSongButton.setImage(UIImage(named: "repeat"), for: .normal)
        return repeatSongButton
    }()
    
    private let homePageButton: UIButton = {
        let homePageButton = UIButton()
        homePageButton.addTarget(self, action: #selector(homeButtonTapped(_:)), for: .touchUpInside)
        homePageButton.setImage(UIImage(named: "home"), for: .normal)
        return homePageButton
    }()
    
    private let songPageButton: UIButton = {
        let songPageButton = UIButton()
        songPageButton.addTarget(self, action: #selector(songButtonTapped(_:)), for: .touchUpInside)
        songPageButton.setImage(UIImage(named: "song"), for: .normal)
        return songPageButton
    }()
    
    private let favoriteSongsButton: UIButton = {
        let favoriteSongsButton = UIButton()
        favoriteSongsButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        favoriteSongsButton.setImage(UIImage(named: "heart"), for: .normal)
        return favoriteSongsButton
    }()
    
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var elapsedTimeWhenPaused: CFTimeInterval = 0
    private let totalDuration: CFTimeInterval = 60.0
    private var returnImageTimer: Timer?
    private var originalImageSize: CGSize = .zero
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        setupUI()
    }
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(favoriteStack)
        view.addSubview(buttonsStack)
        view.addSubview(footerStack)
        view.addSubview(musicImageView)
        view.addSubview(musicNameLabel)
        view.addSubview(artistNameLabel)
        view.addSubview(progressLineView)
        
        
        favoriteStack.translatesAutoresizingMaskIntoConstraints = false
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        musicImageView.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        musicNameLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLineView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsStack.addArrangedSubview(shuffleSongButton)
        buttonsStack.addArrangedSubview(previousSongButton)
        buttonsStack.addArrangedSubview(playPauseButton)
        buttonsStack.addArrangedSubview(nextSongButton)
        buttonsStack.addArrangedSubview(repeatSongButton)
        
        footerStack.addArrangedSubview(homePageButton)
        footerStack.addArrangedSubview(songPageButton)
        footerStack.addArrangedSubview(favoriteSongsButton)
        
        footerStack.axis = .horizontal
        footerStack.alignment = .center
        footerStack.distribution = .equalSpacing
        footerStack.layer.cornerRadius = 25
        musicImageView.layer.cornerRadius = 25
        favoriteStack.layer.cornerRadius = 15
        
        progressLineView.progressTintColor = .white
        
        buttonsStack.axis = .horizontal
        buttonsStack.alignment = .center
        buttonsStack.distribution = .fillProportionally
        
        favoriteStack.backgroundColor = .black
        footerStack.backgroundColor = .darkGray
        progressLineView.backgroundColor = .black
        
        
        NSLayoutConstraint.activate([
            favoriteStack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            favoriteStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 90),
            favoriteStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -90),
            favoriteStack.heightAnchor.constraint(equalToConstant: 40),
            
            musicImageView.topAnchor.constraint(equalTo: self.favoriteStack.bottomAnchor, constant: 50),
            musicImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            musicImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            musicImageView.heightAnchor.constraint(equalToConstant: 300),
            
            musicNameLabel.topAnchor.constraint(equalTo: self.musicImageView.bottomAnchor, constant: 30),
            musicNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            musicNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            artistNameLabel.topAnchor.constraint(equalTo: self.musicNameLabel.bottomAnchor, constant: 20),
            artistNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            artistNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            progressLineView.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 30),
            progressLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressLineView.heightAnchor.constraint(equalToConstant: 4),
            
            
            footerStack.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 60),
            footerStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            footerStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            footerStack.heightAnchor.constraint(equalToConstant: 120),
            
            buttonsStack.bottomAnchor.constraint(equalTo: footerStack.topAnchor, constant: -30),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.heightAnchor.constraint(equalToConstant: 100),
            
            shuffleSongButton.widthAnchor.constraint(equalToConstant: 70),
            shuffleSongButton.heightAnchor.constraint(equalToConstant: 50),
            previousSongButton.widthAnchor.constraint(equalTo: shuffleSongButton.widthAnchor),
            previousSongButton.heightAnchor.constraint(equalTo: shuffleSongButton.heightAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 120),
            playPauseButton.heightAnchor.constraint(equalToConstant: 100),
            nextSongButton.widthAnchor.constraint(equalTo: shuffleSongButton.widthAnchor),
            nextSongButton.heightAnchor.constraint(equalTo: shuffleSongButton.heightAnchor),
            repeatSongButton.widthAnchor.constraint(equalTo: shuffleSongButton.widthAnchor),
            repeatSongButton.heightAnchor.constraint(equalTo: shuffleSongButton.heightAnchor),
            
            homePageButton.widthAnchor.constraint(equalToConstant: 30),
            homePageButton.heightAnchor.constraint(equalToConstant: 30),
            homePageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            songPageButton.widthAnchor.constraint(equalTo: homePageButton.widthAnchor),
            songPageButton.heightAnchor.constraint(equalTo: homePageButton.heightAnchor),
            favoriteSongsButton.widthAnchor.constraint(equalTo: homePageButton.widthAnchor),
            favoriteSongsButton.heightAnchor.constraint(equalTo: homePageButton.heightAnchor),
            favoriteSongsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
        ])
    }
    // MARK: - Buttons Func
    
    @objc private func playPauseButtonTapped(_ sender: UIButton) {
        if playPauseButton.currentImage == UIImage(named: "play") {
            // Start animation
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            startAnimation()
            returnImageTimer?.invalidate()
            returnImageTimer = nil
        } else {
            // Stop animation
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            stopAnimation()
            returnImageTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(returnImageToOriginalSize), userInfo: nil, repeats: false)
        }
    }
    
    private func startAnimation() {
        if elapsedTimeWhenPaused == 0 {
            startTime = CACurrentMediaTime()
        } else {
            startTime = CACurrentMediaTime() - elapsedTimeWhenPaused
        }
        progressLineView.progress = Float(elapsedTimeWhenPaused / totalDuration)
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgressLine))
        displayLink?.add(to: .current, forMode: .default)
        originalImageSize = musicImageView.frame.size
        UIView.animate(withDuration: 0.3) {
            self.musicImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.6)
        }
    }

    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        progressLineView.layer.removeAllAnimations()
        elapsedTimeWhenPaused = CACurrentMediaTime() - startTime
        UIView.animate(withDuration: 0.3) {
            self.musicImageView.transform = .identity
        }
    }
    
    @objc private func updateProgressLine() {
        let elapsedTime = CACurrentMediaTime() - startTime
        let progress = Float(elapsedTime / totalDuration)
        progressLineView.setProgress(progress, animated: true)
        
        if progress >= 1.0 {
            stopAnimation()
        }
    }
    
    @objc private func returnImageToOriginalSize() {
        UIView.animate(withDuration: 0.3) {
            self.musicImageView.transform = .identity
        }
    }
    
    @objc private func scaleSymbols(for button: UIButton) {
            UIView.animate(withDuration: 1) {
                if let lastButton = self.lastScaledButton, lastButton != button {
                    lastButton.transform = .identity
                }
                
                if button.transform.isIdentity {
                    button.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    self.lastScaledButton = button
                } else {
                    button.transform = .identity
                    self.lastScaledButton = nil
                }
            }
        }
        
        @objc private func homeButtonTapped(_ sender: UIButton) {
            scaleSymbols(for: sender)
        }
        
        @objc private func songButtonTapped(_ sender: UIButton) {
            scaleSymbols(for: sender)
        }
        
        @objc private func favoriteButtonTapped(_ sender: UIButton) {
            scaleSymbols(for: sender)
        }
    }
