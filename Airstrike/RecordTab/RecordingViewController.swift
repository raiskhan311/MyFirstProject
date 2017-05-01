//
//  RecordingViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 12/29/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var landscapeRecordingContainerView: UIView!
    @IBOutlet weak var portraitRecordingContainerView: UIView!
    
    @IBOutlet weak var gameStatusButton: UIButton!
    @IBOutlet weak var scoreViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var temporaryViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var teamOneScoreLabel: UILabel!
    @IBOutlet weak var teamTwoScoreLabel: UILabel!
    @IBOutlet weak var teamOneNameLabel: UILabel!
    @IBOutlet weak var teamTwoNameLabel: UILabel!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    
    @IBOutlet weak var landscapeRecordButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var landscapeStatsButton: UIButton!
    @IBOutlet weak var tempAddStatsButton: UIButton!
    @IBOutlet weak var tempUndoButton: UIButton!
    
    @IBOutlet weak var temporaryView: UIView!
    @IBOutlet weak var recordingPreviewView: UIView!
    
    var captureSession = AVCaptureSession()
    var movieOutput = AVCaptureMovieFileOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    var videoTimer: Timer?
    var addStatsTimer: Timer?
    var undoStatsTimer: Timer?
    var secondsCount = 0

    lazy var backCameraDevice: AVCaptureDevice? = {
        guard let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInMicrophone, .builtInTelephotoCamera, .builtInWideAngleCamera, .builtInDuoCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.unspecified) else { return .none }
        return deviceDiscoverySession.devices.filter{$0.position == .back}.first
    }()
    
    lazy var micDevice: AVCaptureDevice? = {
        return AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    }()
    
    var infoForStat: [String:String]?
    
    var previousStatInfo: [Position:Person]?
    
    var gameInfoOpt: [String:String]?
    
    var stats: [Stat]?
    
    var mediaId: String?
    
    override func viewWillAppear(_ animated: Bool) {
        configureViews()
        setLabels()
        configureCameraView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        temporaryView.alpha = 0
        setupRecording()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated(notification:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: .none)
        
        guard let gameId = infoForStat?["gameId"], let gameOpt = try? DAOGame().getGame(gameId: gameId), let game = gameOpt else { return }
        let text = self.getCurrentGameStatusText(game.gameStatus)
        gameStatusButton.setTitle(text, for: .normal)
    }
    
    func deviceRotated(notification: Notification) {
        configureCameraView()
    }
    
    private func configureCameraView() {
        if let connection =  self.previewLayer.connection  {
            
            let currentDevice: UIDevice = UIDevice.current
            
            let orientation: UIDeviceOrientation = currentDevice.orientation
            
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setLabels() {
        if let gameInfo = gameInfoOpt {
            teamOneNameLabel.text = gameInfo[GameInfo.teamOneName.rawValue]
            teamTwoNameLabel.text = gameInfo[GameInfo.teamTwoName.rawValue]
            teamOneScoreLabel.text = gameInfo[GameInfo.teamOnePoints.rawValue]
            teamTwoScoreLabel.text = gameInfo[GameInfo.teamTwoPoints.rawValue]
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in
            self.configureViews()
        }
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        
        previewLayer.frame = self.view.bounds
    }
    
    fileprivate func configureTempStatsButton() {
        startAddStatsTimer()
        tempAddStatsButton.isHidden = false
        tempUndoButton.isHidden = true
        self.statsButton.alpha = 0
        self.landscapeStatsButton.alpha = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            self.temporaryView.alpha = 1
        })
    }
    
    fileprivate func configureStatsUndoButton() {
        startUndoStatsTimer()
        tempAddStatsButton.isHidden = true
        tempUndoButton.isHidden = false
        
        UIView.animate(withDuration: 0.4, animations: {
            self.temporaryView.alpha = 1
        })
    }
    
    fileprivate func configureDurationString(totalSeconds: Double) -> String {
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
}

// MARK: Setup

extension RecordingViewController {
    
    func setupRecording() {
        guard   let b = backCameraDevice,
                let backCameraInput = try? AVCaptureDeviceInput(device: b),
                let m = micDevice,
                let micInput = try? AVCaptureDeviceInput(device: m)
                else { return }
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        captureSession.addInput(backCameraInput)
        captureSession.addInput(micInput)
        
        movieOutput.movieFragmentInterval = kCMTimeInvalid
        captureSession.addOutput(movieOutput)
        
        captureSession.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
        recordingPreviewView.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    func mediaFilePath(id: String) -> URL {
        
        let newDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("CachedMedia")
        let mediaFilePath = newDirectory.appendingPathComponent(id).appendingPathExtension("mp4")
        
        if !FileManager.default.fileExists(atPath: newDirectory.absoluteString) {
            try? FileManager.default.createDirectory(atPath: newDirectory.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        if FileManager.default.fileExists(atPath: mediaFilePath.absoluteString) {
            try? FileManager.default.removeItem(atPath: mediaFilePath.absoluteString)
        }
        return mediaFilePath
    }
    
}

// MARK: AVCaptureFileOutputRecordingDelegate

extension RecordingViewController: AVCaptureFileOutputRecordingDelegate {
    
    // Video Recording Started
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        landscapeRecordButton.setImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
        recordButton.setImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
        startTimer()
    }
    
    // Video Recording Finished
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        landscapeRecordButton.setImage(#imageLiteral(resourceName: "recordButton"), for: .normal)
        recordButton.setImage(#imageLiteral(resourceName: "recordButton"), for: .normal)
        stopTimer()
        if let e = error {
            print("ERROR recording/saving video" + e.localizedDescription)
        } else {
            let outputURL = outputFileURL.deletingPathExtension()
            let id = outputURL.lastPathComponent
            self.mediaId = id
            try? DAOCachedMedia().insert(CachedMedia(id: id, duration: configureDurationString(totalSeconds: captureOutput.recordedDuration.seconds), date: Date(), statIds: .none))
            configureTempStatsButton()
        }
    }
    
}

// MARK: Timers

extension RecordingViewController {
    
    // Video Timer
    fileprivate func startTimer() {
        videoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    fileprivate func stopTimer() {
        recordingTimeLabel.text = "00:00:00"
        secondsCount = 0
        videoTimer?.invalidate()
    }
    
    func handleTimer() {
        secondsCount += 1
        let hours = secondsCount / 3600
        let minutes = secondsCount / 60 % 60
        let seconds = secondsCount % 60
        recordingTimeLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    // Add Stats Timer
    
    fileprivate func startAddStatsTimer() {
        addStatsTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(addStatsTimerFinished), userInfo: nil, repeats: false)
    }
    
    func addStatsTimerFinished() {
        addStatsTimer?.invalidate()
        self.statsButton.alpha = 1
        self.landscapeStatsButton.alpha = 1
        
        UIView.animate(withDuration: 0.4, animations: {
            self.temporaryView.alpha = 0
        })
        mediaId = .none
    }
    
    // Undo Stats Entry Timer
    
    fileprivate func startUndoStatsTimer() {
        undoStatsTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(undoStatsTimerFinished), userInfo: nil, repeats: false)
    }
    
    func undoStatsTimerFinished() {
        undoStatsTimer?.invalidate()
        UIView.animate(withDuration: 0.4, animations: {
            self.temporaryView.alpha = 0
        })
        
        if let s = stats {
            var haveAddedPoints = false
            s.forEach { stat in
                if let json = stat.toJson() {
                    ServiceConnector.sharedInstance.createEvent(type: .stat, leagueId: stat.leagueId, jsonString: json, complete: { (success) in
                        if success {
                            do {
                                try DAOStat().insertStat(stat: stat, uploadSuccess: true)
                            } catch {
                                print("Failed to Insert into Stats Table")
                            }
                        } else {
                            try? DAOStat().insertStat(stat: stat, uploadSuccess: false)
                        }
                    })
                }
                if let gameOpt = try? DAOGame().getGame(gameId: stat.gameId), let game = gameOpt, (stat.type == .touchdown || stat.type == .pick6) && !haveAddedPoints {
                    haveAddedPoints = true
                    var team1Score = game.pointsTeam1
                    var team2Score = game.pointsTeam2
                    
                    let team1Saved = game.pointsTeam1
                    let team2Saved = game.pointsTeam2
                    
                    if stat.teamId == game.team1Id {
                        team1Score += 7
                    } else {
                        team2Score += 7
                    }
                    self.teamOneScoreLabel.text = String(team1Score)
                    self.teamTwoScoreLabel.text = String(team2Score)
                    ServiceConnector.sharedInstance.updateGameScore(gameId: stat.gameId, teamOneScore: team1Score, teamTwoScore: team2Score, complete: { (success) in
                        if !success {
                            // Failed to update score in Bubble.is
                            self.teamOneScoreLabel.text = String(team1Saved)
                            self.teamTwoScoreLabel.text = String(team2Saved)
                        }
                    })

                }
            }
            stats = .none
        }
    }
}


// MARK: - IBActions
extension RecordingViewController {
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        let size = self.view.frame.size
        if size.width > size.height {
            landscapeStatsButton.isHidden = !landscapeStatsButton.isHidden
        } else {
            statsButton.isHidden = !statsButton.isHidden
        }
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        } else {
            movieOutput.startRecording(toOutputFileURL: mediaFilePath(id: UUID().uuidString), recordingDelegate: self)
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
        self.dismiss(animated: true) { 
            guard let gameId = self.infoForStat?["gameId"], let gameOpt = try? DAOGame().getGame(gameId: gameId), let game = gameOpt else { return }
            if let winningId = game.winningTeamId, game.gameStatus == .final {
                ServiceConnector.sharedInstance.updateTeamRecords(team1Id: game.team1Id, team2Id: game.team2Id, winningTeamId: winningId, complete: { (success) in
                    if success {
                        DAOTeam().updateTeamRecords(team1Id: game.team1Id, team2Id: game.team2Id, winningTeamId: winningId)
                    }
                })
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: ServiceNotificationType.allDataRefreshed, object: self, userInfo: .none)
            }
        }
    }
    
    @IBAction func statsButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "StatsCreation", bundle: .none)
        if let newController = storyboard.instantiateViewController(withIdentifier: "StatsCreationVC") as? StatsCreationViewController {
            infoForStat?["mediaId"] = self.mediaId
            newController.infoForStat = self.infoForStat
            newController.previousStatInfo = self.previousStatInfo
            newController.delegate = self
            newController.statsEnteredDelegate = self
            addStatsTimerFinished()
            undoStatsTimerFinished()
            let navigationController = UINavigationController(rootViewController: newController)
            present(navigationController, animated: true, completion: .none)
        }
    }
    
    @IBAction func undoButtonPressed(_ sender: UIButton) {
        self.stats = .none
        undoStatsTimerFinished()
    }
    
    @IBAction func gameStatusButtonAction(_ sender: UIButton) {
        guard let gameId = infoForStat?["gameId"], let gameOpt = try? DAOGame().getGame(gameId: gameId), let game = gameOpt, game.gameStatus != .final else { return }
        self.showActionSheet()
    }
    
    fileprivate func showActionSheet() {
        let ac = UIAlertController(title: .none, message: "Change Game Status", preferredStyle: .actionSheet)
        let aNotStarted = UIAlertAction(title: "Not Started", style: .default) { (action) in
            self.updateGameStatus(to: .notStarted)
        }
        let aFirstHalf = UIAlertAction(title: "1st Half", style: .default) { (action) in
            self.updateGameStatus(to: .firstHalf)
        }
        let aHalfTime = UIAlertAction(title: "Half Time", style: .default) { (action) in
            self.updateGameStatus(to: .halfTime)
        }
        let aSecondHalf = UIAlertAction(title: "2nd Half", style: .default) { (action) in
            self.updateGameStatus(to: .secondHalf)
        }
        let aFinal = UIAlertAction(title: "Final", style: .default) { (action) in
            DispatchQueue.main.async {
                let doubleCheckAc = UIAlertController(title: "End game?", message: "Are you sure you want to end this game? This cannot be undone.", preferredStyle: .alert)
                let yesAct = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    self.updateGameStatus(to: .final)
                })
                let noAct = UIAlertAction(title: "No", style: .default, handler: .none)
                doubleCheckAc.addAction(yesAct)
                doubleCheckAc.addAction(noAct)
                self.present(doubleCheckAc, animated: true, completion: .none)
            }
        }
        let aCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: .none)
        ac.addAction(aNotStarted)
        ac.addAction(aFirstHalf)
        ac.addAction(aHalfTime)
        ac.addAction(aSecondHalf)
        ac.addAction(aFinal)
        ac.addAction(aCancel)
        self.present(ac, animated: true, completion: .none)
    }
    
    fileprivate func updateGameStatus(to status: GameStatus) {
        guard let gameId = infoForStat?["gameId"] else { return }
        let tempText = gameStatusButton.currentTitle
        gameStatusButton.setTitle(getCurrentGameStatusText(status), for: .normal)
        ServiceConnector.sharedInstance.updateGameStatus(gameId: gameId, status: status) { (success) in
            if !success {
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Unable to update", message: "We were unable to update the game status. Check your internet connection and try again.", preferredStyle: .alert)
                    let aa = UIAlertAction(title: "OK", style: .default, handler: .none)
                    ac.addAction(aa)
                    self.present(ac, animated: true, completion: .none)
                    self.gameStatusButton.setTitle(tempText ?? "", for: .normal)
                }
            }
        }
    }
    
    fileprivate func getNextGameStatus(_ current: GameStatus) -> (status: GameStatus, displayText: String) {
        var statusTuple = (status: current, displayText: "Start Game")
        switch current {
        case .notStarted:
            statusTuple = (status: .firstHalf, displayText: "1st Half")
        case .firstHalf:
            statusTuple = (status: .halfTime, displayText: "1st Half")
        case .halfTime:
            statusTuple = (status: .secondHalf, displayText: "Half Time")
        case .secondHalf:
            statusTuple = (status: .final, displayText: "2nd Half")
        case .final:
            statusTuple = (status: .notStarted, displayText: "Final")
        }
        return statusTuple
    }
    
    fileprivate func getCurrentGameStatusText(_ current: GameStatus) -> String {
        var text = ""
        switch current {
        case .notStarted:
            text = "Not Started"
        case .firstHalf:
            text = "1st Half"
        case .halfTime:
            text = "Half Time"
        case .secondHalf:
            text = "Second Half"
        case .final:
            text = "Final"
        }
        return text
    }

    
}

// MARK: - Constraint Manipulation
extension RecordingViewController {
    
    func configureViews() {
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            UIView.animate(withDuration: 0.2, animations: {
                self.landscapeRecordingContainerView.alpha = 0
                self.portraitRecordingContainerView.alpha = 1
                self.scoreViewBottomConstraint.constant = self.portraitRecordingContainerView.bounds.height
                self.temporaryViewTrailingConstraint.constant = 0
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
                self.timeViewTopConstraint.constant = 16
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.landscapeRecordingContainerView.alpha = 1
                self.portraitRecordingContainerView.alpha = 0
                self.scoreViewBottomConstraint.constant = 0
                self.temporaryViewTrailingConstraint.constant = self.landscapeRecordingContainerView.frame.size.width
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
                self.timeViewTopConstraint.constant = 0
            })
        }
    }
}

// MARK: Protocol for information from Previous Stat Entry
extension RecordingViewController: PreviousStatInfoUpdated {
    func updateStats(previousStatInfo: [Position:Person]?) {
        self.previousStatInfo = previousStatInfo
    }
}

// MARK: Protocol for stats entered

extension RecordingViewController: StatsEntered {
    func statsEntered(stats: [Stat]) {
        self.stats = stats
//        configureTempStatsButton()
        configureStatsUndoButton()
    }
}
