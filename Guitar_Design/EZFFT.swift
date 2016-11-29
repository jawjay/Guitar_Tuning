//
//  ViewController.swift
//  Guitar_Design
//
//  Created by Mark Jajeh on 3/20/16.
//  Copyright © 2016 Mark Jajeh. All rights reserved.
//

import UIKit
import EZAudio
class EZFFT: UIViewController,EZMicrophoneDelegate,EZAudioFFTDelegate {
    @IBOutlet var audioPlotFreq: EZAudioPlot!
    @IBOutlet weak var audioPlotTime: EZAudioPlot!
    @IBOutlet weak var maxFrequencyLabel: UILabel!
    
    var microphone:EZMicrophone!
    var fft:EZAudioFFTRolling!
    
    let FFTViewControllerFFTWindowSize:vDSP_Length = 4096
    var filtStart:UInt32 = 100
    var filtEnd:UInt32 = 400
    var myAudio = AudioStreamBasicDescription()
    
    var Fs:Float = 4800
    var sR:UInt32 = 4800
    
    
    
    
    
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubview(toFront: audioPlotTime)
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error:NSError!
        
        //( the _=  try? )will ignore the errors thrown by method
        _ = try? session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        _ = try? session.setActive(true)
        
        self.audioPlotTime.plotType = EZPlotType.buffer
        self.maxFrequencyLabel.numberOfLines = 0
        self.audioPlotFreq.shouldFill = true
        self.audioPlotFreq.plotType = EZPlotType.buffer
        self.audioPlotFreq.shouldCenterYAxis = false
        
        
        //self.microphone = EZMicrophone(delegate: self, startsImmediately: false)
        myAudio = EZAudioUtilities.floatFormat(withNumberOfChannels: 4, sampleRate: Fs) // set custom audio format
        self.microphone = EZMicrophone(delegate: self, with: myAudio, startsImmediately: false)//set mic with custom audio layout
        
        fft = EZAudioFFTRolling.fft(withWindowSize: FFTViewControllerFFTWindowSize, sampleRate: Float(self.microphone.audioStreamBasicDescription().mSampleRate), delegate: self)
        
        print("mic")
        print(String(self.microphone.audioStreamBasicDescription().mSampleRate))
        
//        self.microphone.setAudioStreamBasicDescription()
        self.microphone.startFetchingAudio()
        
        
    }
    
    
    //------------------------------------------------------------------------------
    // MARK: EZMicrophoneDelegate
    //----------------------------------------------------------------------------
    
    func microphone(_ microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
        
        self.fft.computeFFT(withBuffer: buffer[0], withBufferSize: bufferSize)
        //self.fft.computeFFTWithBufferWithFilter(buffer[0], withBufferSize: bufferSize,filterStart:sR ,filterEnd:filtEnd)
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.audioPlotTime?.updateBuffer(buffer[0], withBufferSize: bufferSize);
            
        });
    }
    
    
    //------------------------------------------------------------------------------
    // MARK: EZMicrophoneFFTDelegate
    //------------------------------------------------------------------------------
    
    
    func fft(_ fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
    
        let maxFrequency: Float = self.fft.maxFrequency
    
        let noteName:NSString = EZAudioUtilities.noteNameString(forFrequency: maxFrequency, includeOctave: true) as NSString
       
        weak var weakSelf = self
        
        
        DispatchQueue.main.async(execute: { () -> Void in
            weakSelf!.maxFrequencyLabel.text = "Highest Note: \(noteName),\nFrequency \(maxFrequency)"
            self.audioPlotFreq.updateBuffer(fftData, withBufferSize: UInt32(bufferSize))
            //self.view.bringSubviewToFront(self.maxFrequencyLabel)
            
        });
        
       
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}

