//
// Master.swift
//  Guitar_Design
//
//  Created by Mark Jajeh on 3/20/16.
//  Copyright © 2016 Mark Jajeh. All rights reserved.
//

import UIKit
import EZAudio
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

//import FSK_Arduino_iOS
//import AVFoundation
//import FSK_Arduino_iOS

class Master: UIViewController,EZMicrophoneDelegate,EZAudioFFTDelegate,EZAudioPlayerDelegate {

    @IBOutlet weak var maxFrequencyLabel: UILabel!
    
    var microphone:EZMicrophone!
    var fft:EZAudioFFTRolling!
    
    @IBOutlet weak var flabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var fftPlot: EZAudioPlot!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var plots: UIView!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var tuneButton: UIButton!
    
    @IBOutlet weak var b1Button: UIButton!
    @IBOutlet weak var b2Button: UIButton!
    @IBOutlet weak var b3Button: UIButton!
    @IBOutlet weak var b4Button: UIButton!
    @IBOutlet weak var b5Button: UIButton!
    @IBOutlet weak var b6Button: UIButton!
    
    //------------------------------------------------------------------------------
    // MARK:Guitar Specifications Specifications
    //------------------------------------------------------------------------------
    let freqList:[Float] = [82.41,110,146.83,196,246.94,329.63]
    var goalF:Float = 230.0
    //------------------------------------------------------------------------------
    // MARK: Define Variables
    //------------------------------------------------------------------------------
    var audioFile:EZAudioFile!
    var directionFile:EZAudioFile! // use this for change of direction signal
    var stepFile:EZAudioFile!   // use this to send a step to a motor

    var player:EZAudioPlayer!
    var myTimer = Timer()
    var rightTimer = Timer()
    var leftTimer = Timer()
    var turnTime = 0.5
    var count = 3
    
    let FFTViewControllerFFTWindowSize:vDSP_Length = 4096
    var lowAudio = AudioStreamBasicDescription()
    var samp:Float = 3000
    
    // Get current directory path
    let path = FileManager.default.currentDirectoryPath
    let kAudioFileDefault = Bundle.main.path(forResource: "constalt", ofType: "wav")
    
    let leftAudio = Bundle.main.path(forResource: "LeftTwoPulse2", ofType: "wav")
    let rightAudio = Bundle.main.path(forResource: "RightTwoPulse", ofType: "wav")
    

    //------------------------------------------------------------------------------
    // MARK: View Functions
    //------------------------------------------------------------------------------
    @IBAction func leftClick(_ sender: AnyObject) {
        self.openFileWithFilePathURL(URL(fileURLWithPath: leftAudio!))
        self.player.play()
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Master.stopAudio), userInfo: nil, repeats: false)
    }
    
    @IBAction func rightClick(_ sender: AnyObject) {
        self.openFileWithFilePathURL(URL(fileURLWithPath: rightAudio!))
        self.player.play()
        
        rightTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Master.stopAudio), userInfo: nil, repeats: false)
        
    }
    @IBAction func tunePress(_ sender: AnyObject) {
        print("tuner clicked")
        
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Master.fromCounter), userInfo: nil, repeats: true)
        tuneButton.isHidden = true
        countdownLabel.isHidden = false
    }
    func stopAudio(){
        self.player.pause()
    }
    
    @IBOutlet var tuneButtons: [UIButton]!
    
    
    @IBAction func tuneClicked(_ sender: UIButton) { //click of specific tuner button pin
        
        for btn in tuneButtons {
            if sender == btn {
                btn.backgroundColor = UIColor.red
                let s = (btn.titleLabel?.text)!
                let st  = s.characters.index(after: s.startIndex)
                if let someInt = Int(String(s[st])){
                    //goalF =
                    goalF = freqList[someInt-1]
                    flabel.text = String(goalF)
                }
            }
            else {
                btn.backgroundColor = UIColor.clear
            }
        }
    }
    func setDesign(){
        let btn = b1Button!
        btn.backgroundColor = UIColor.red
        let s = (btn.titleLabel?.text)!
        let st  = s.characters.index(after: s.startIndex)

            goalF = freqList[0]
            flabel.text = String(goalF)
        
        tuneButton.backgroundColor = UIColor.red
        tuneButton.layer.cornerRadius = 5
        countdownLabel.isHidden = true
        countdownLabel.text = "Ready"
        self.audioPlot.color = UIColor.gray
        self.fftPlot.color = UIColor.white
        self.audioPlot.plotType = .buffer
        self.fftPlot.plotType = .buffer
        
        
        self.maxFrequencyLabel.numberOfLines = 0
        tuneButtons.sort(by: {$0.titleLabel!.text>$1.titleLabel!.text}) // sort the buttons by name
        self.view.bringSubview(toFront: b1Button)
        

        
    }
    
    func fromCounter(){ //function to run on timer init
        if(count > 0)
        {
            count-=1
            countdownLabel.text = String(count)
            
        } else {
            myTimer.invalidate() //turn off timer
//            print("GO")
            countdownLabel.text = "TUNING"
            count = 3
            motorLoop()
            
        }
    }
    
    func setTune(){ //run after go timer
        tuneButton.isHidden = false
        countdownLabel.isHidden = true
        countdownLabel.text = "Ready"
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    func goHigher(){
        self.openFileWithFilePathURL(URL(fileURLWithPath: rightAudio!))
        self.player.play()
        rightTimer = Timer.scheduledTimer(timeInterval: turnTime, target: self, selector: #selector(Master.motorLoop), userInfo: nil, repeats: false)
    }
    func goLower(){
        self.openFileWithFilePathURL(URL(fileURLWithPath: leftAudio!))
        self.player.play()
        leftTimer = Timer.scheduledTimer(timeInterval: turnTime, target: self, selector: #selector(Master.motorLoop), userInfo: nil, repeats: false)

    }
    func motorLoop(){
        self.player.pause()
        if( abs(self.fft.maxFrequency-self.goalF) > 20) {
            
            if(sign(self.fft.maxFrequency-self.goalF)==1){ goHigher();print("TOO LOW")}
            else{                                           goLower();print("TOO HIGH")}
        }
        else{
            // DONE TURNING PRINT OUT TUNE
            print("DONE")
            setTune()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setDesign()
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        let _:NSError!
        self.player = EZAudioPlayer(delegate:self)
        self.player.shouldLoop = true
        _ = try? session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        self.openFileWithFilePathURL(URL(fileURLWithPath: rightAudio!))
        //( the _=  try? )will ignore the errors thrown by method
        _ = try? session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        _ = try? session.setActive(true)
        lowAudio = EZAudioUtilities.floatFormat(withNumberOfChannels: 4, sampleRate: samp)
//        self.microphone = EZMicrophone(delegate: self, with: lowAudio, startsImmediately: false)
        self.microphone = EZMicrophone(delegate: self, startsImmediately: false)
        fft = EZAudioFFTRolling.fft(withWindowSize: FFTViewControllerFFTWindowSize, sampleRate: Float(self.microphone.audioStreamBasicDescription().mSampleRate), delegate: self)
        self.microphone.startFetchingAudio()
    }
    //------------------------------------------------------------------------------
    // MARK: EZMicrophoneDelegate
    //------------------------------------------------------------------------------
    func microphone(_ microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        //self.fft.computeFFTWithBufferHarmonic(buffer[0], withBufferSize: bufferSize)
        self.fft.computeFFT(withBuffer: buffer[0], withBufferSize: bufferSize)
        DispatchQueue.main.async(execute: { () -> Void in
            self.audioPlot?.updateBuffer(buffer[0], withBufferSize: bufferSize);
        });}
    //-----------------------------------------------------------------------------
    // MARK: EZAudioPlayerDelegate
    //------------------------------------------------------------------------------
    func audioPlayer(_ audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, in audioFile: EZAudioFile!) {
        weak var weakSelf = self    }
    func audioPlayer(_ audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, in audioFile: EZAudioFile!) {
        weak var weakSelf = self}
    func openFileWithFilePathURL(_ filePathURL:URL){
        self.audioFile = EZAudioFile(url: filePathURL)
        self.player.audioFile = self.audioFile
        
    }
    //------------------------------------------------------------------------------
    // MARK: EZMicrophoneFFTDelegate
    //------------------------------------------------------------------------------
    func fft(_ fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        let maxFrequency: Float = self.fft.maxFrequency
        let maxHarmonic: Float = self.fft.maxHarmonicFrequency
        let noteName:NSString = EZAudioUtilities.noteNameString(forFrequency: maxFrequency, includeOctave: true) as NSString
        weak var weakSelf = self
        DispatchQueue.main.async(execute: { () -> Void in
            weakSelf!.maxFrequencyLabel.text = "Note: \(noteName),\nFrequency \(maxFrequency)"
            if abs(maxFrequency-self.goalF) > 5 {
                weakSelf!.maxFrequencyLabel.textColor = UIColor.red
            }
            else {
                weakSelf!.maxFrequencyLabel.textColor = UIColor.green
                //self.player.pause()
            }
           self.fftPlot.updateBuffer(fftData, withBufferSize: UInt32(bufferSize))
        });
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func openFileWithPath(_ filePathURL:URL){
        self.audioFile = EZAudioFile(url:filePathURL)
        self.player.audioFile = self.audioFile
    }}
