//
//  ViewController.swift
//  Guitar_Design
//
//  Created by Mark Jajeh on 3/20/16.
//  Copyright © 2016 Mark Jajeh. All rights reserved.
//

import UIKit
import EZAudio
class Master: UIViewController,EZMicrophoneDelegate,EZAudioFFTDelegate {

    @IBOutlet weak var maxFrequencyLabel: UILabel!
    
    var microphone:EZMicrophone!
    var fft:EZAudioFFTRolling!
    
    let FFTViewControllerFFTWindowSize:vDSP_Length = 4096
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var session:AVAudioSession = AVAudioSession.sharedInstance()
        var error:NSError!
        
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

