//
//  ViewController.swift
//  Guitar_Design
//
//  Created by Mark Jajeh on 3/20/16.
//  Copyright © 2016 Mark Jajeh. All rights reserved.
//

import UIKit
import EZAudio
class Master: UIViewController,EZMicrophoneDelegate,EZAudioFFTDelegate,EZAudioPlayerDelegate {

    @IBOutlet weak var maxFrequencyLabel: UILabel!
    
    var microphone:EZMicrophone!
    var fft:EZAudioFFTRolling!
    
    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var tuneButton: UIButton!
    
    @IBOutlet weak var b1Button: UIButton!
    @IBOutlet weak var b2Button: UIButton!
    @IBOutlet weak var b3Button: UIButton!
    @IBOutlet weak var b4Button: UIButton!
    @IBOutlet weak var b5Button: UIButton!
    @IBOutlet weak var b6Button: UIButton!

    //------------------------------------------------------------------------------
    // MARK: View Functions
    //------------------------------------------------------------------------------
    @IBAction func tunePress(sender: AnyObject) {
        print("tuner clicked")
    }
    
    @IBOutlet var tuneButtons: [UIButton]!
    
    
    @IBAction func tuneClicked(sender: UIButton) {
        
        for btn in tuneButtons {
            if sender == btn {
                btn.backgroundColor = UIColor.redColor()
            }
            else {
                btn.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    
    let FFTViewControllerFFTWindowSize:vDSP_Length = 4096
    

    func setDesign(){
        
        tuneButton.backgroundColor = UIColor.redColor()
        tuneButton.layer.cornerRadius = 5
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDesign()
        
        self.view.bringSubviewToFront(b1Button)
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        let error:NSError!
        
        //( the _=  try? )will ignore the errors thrown by method
        _ = try? session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        _ = try? session.setActive(true)
        
        self.maxFrequencyLabel.numberOfLines = 0
        
        self.microphone = EZMicrophone(delegate: self, startsImmediately: false)
        
        //problem with this line
        fft = EZAudioFFTRolling.fftWithWindowSize(FFTViewControllerFFTWindowSize, sampleRate: Float(self.microphone.audioStreamBasicDescription().mSampleRate), delegate: self)
        
        
        self.microphone.startFetchingAudio()
        
        
    }
    
    
    //------------------------------------------------------------------------------
    // MARK: EZMicrophoneDelegate
    //------------------------------------------------------------------------------
    
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
        
        self.fft.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
        /*
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.audioPlotTime?.updateBuffer(buffer[0], withBufferSize: bufferSize);
        });
        */
    }
    
    
    //-----------------------------------------------------------------------------
    // MARK: EZAudioPlayerDelegate
    //------------------------------------------------------------------------------
    
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
        weak var weakSelf = self
        
    }
    func audioPlayer(audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, inAudioFile audioFile: EZAudioFile!) {
        weak var weakSelf = self
    }

    
    
    //------------------------------------------------------------------------------
    // MARK: EZMicrophoneFFTDelegate
    //------------------------------------------------------------------------------
    
    
    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        
        let maxFrequency: Float = self.fft.maxFrequency
        
        let noteName:NSString = EZAudioUtilities.noteNameStringForFrequency(maxFrequency, includeOctave: true)
        
        weak var weakSelf = self
        
        
        dispatch_async(dispatch_get_main_queue(),{ () -> Void in
            weakSelf!.maxFrequencyLabel.text = "Highest Note: \(noteName),\nFrequency \(maxFrequency)"
           //self.audioPlotFreq.updateBuffer(fftData, withBufferSize: UInt32(bufferSize))
            //self.view.bringSubviewToFront(self.maxFrequencyLabel)
            
        });
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

