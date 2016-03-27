//
//  EZPlayFile.swift
//  Guitar_Design
//
//  Created by Mark Jajeh on 3/20/16.
//  Copyright © 2016 Mark Jajeh. All rights reserved.
//

import UIKit
import EZAudio

class EZPlayFile: UIViewController,EZAudioPlayerDelegate{
//////  .h file in Obj-C
    @IBOutlet weak var audioPlot: EZAudioPlotGL!
    @IBOutlet weak var filePathLabel: UILabel!
    @IBOutlet weak var positionSlider: UISlider!
    @IBOutlet weak var rollingHistorySlider: UISlider!
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBAction func changePlotType(sender: AnyObject) {
        let selectedSegment = sender.selectedSegmentIndex
        switch(selectedSegment){
        case 0:
            self.drawBufferPlot()
            break
        case 1:
            self.drawRollingPlot()
            break
        default:
            break
            
        }
    }
    @IBAction func changeRollingHistoryLength(sender: AnyObject) {
        //on Rolling History Slider change
        let value:Float = sender.value
        self.audioPlot.setRollingHistoryLength(Int32(value))
    }
    
    @IBAction func changeVolume(sender: AnyObject) {
        // on volume slider
        let value:Float = sender.value
        //UNCOMMENTself.player.setVolume = value
    }
    
    @IBAction func play(sender: AnyObject) {
        // on play button
        if(self.player.isPlaying)
        {
            self.player.pause()
        }
        else{
            if(self.audioPlot.shouldMirror && (self.audioPlot.plotType == EZPlotType.Buffer))
            {
             self.audioPlot.shouldMirror = false
             self.audioPlot.shouldFill = false
            }
            self.player.play()
        }
    }
    
    @IBAction func seekToFrame(sender: AnyObject) {
        // on position slider
        self.player.seekToFrame(Int64((sender as! UISlider).value))
        
    }
    
    
    //------------------------------------------------------------------------------
    // MARK: DEFINE variables
    //------------------------------------------------------------------------------

    //let kAudioFileDefault = NSBundle.mainBundle().pathForResource("simple-drum-beat", ofType: "wav")
    var audioFile:EZAudioFile!
    var player:EZAudioPlayer!
    // Create a FileManager instance
    
    // Get current directory path
    let path = NSFileManager.defaultManager().currentDirectoryPath
   
    
    let kAudioFileDefault = NSBundle.mainBundle().pathForResource("simple-drum-beat", ofType: "wav")
    

    
    
///// .m File in Obj-C
    
    //------------------------------------------------------------------------------
    // MARK: Dealloc
    //------------------------------------------------------------------------------

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)

    }
    //------------------------------------------------------------------------------
    // MARK: Status Bar Style
    //------------------------------------------------------------------------------
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //------------------------------------------------------------------------------
    // MARK: Setup
    //------------------------------------------------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      /*
        //
        // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
        // if you don't do this!
        //
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        let error:NSError!
        
        _ = try? session.setCategory(AVAudioSessionCategoryPlayback)
        _ = try? session.setActive(true)
        
        //
        // Customizing the audio plot's look
        //
        self.audioPlot.backgroundColor = UIColor(red: 0.816, green: 0.349, blue: 0.255, alpha: 1)
        
        self.audioPlot.color           = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.audioPlot.plotType        = EZPlotType.Buffer
        self.audioPlot.shouldFill      = true
        self.audioPlot.shouldMirror    = true
        
        print("outputs: \(EZAudioDevice.outputDevices)")
        
        //
        // Create the audio player
        //
        
        self.player = EZAudioPlayer(delegate:self)
        self.player.shouldLoop = false
        
        //
        // Override the output to the speaker
        //
        
        _ = try? session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        
        //
        // Customize UI components
        //
       
        self.rollingHistorySlider.value = Float(self.audioPlot.rollingHistoryLength())
        //
        // Listen for EZAudioPlayer notifications
        //
        
        self.setupNotifications()
        
        
        /*
        Try opening the sample file
        */
        //[self openFileWithFilePathURL:[NSURL fileURLWithPath:kAudioFileDefault]];
        self.openFileWithFilePathURL(NSURL.fileURLWithPath(kAudioFileDefault!))
        
        */
        
    }
    
    //------------------------------------------------------------------------------
    // MARK: Notifications
    //------------------------------------------------------------------------------
    
    func setupNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioPlayerDidChangeAudioFile:", name: EZAudioPlayerDidChangeAudioFileNotification, object: self.player)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioPlayerDidChangeOutputDevice:", name: EZAudioPlayerDidChangeOutputDeviceNotification, object: self.player)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioPlayerDidChangePlayState:", name: EZAudioPlayerDidChangePlayStateNotification, object: self.player)
    }
    
    func audioPlayerDidChangeAudioFile(notification:NSNotification){
        let player:EZAudioPlayer = notification.object as! EZAudioPlayer
        NSLog("Player changed audio file: %@", player.audioFile)
    }
    func audioPlayerDidChangeOutputDevice(notification:NSNotification){
        let player:EZAudioPlayer = notification.object as! EZAudioPlayer
        NSLog("Player changed output device: %@", player.device)
    }
    func audioPlayerDidChangePlayState(notification:NSNotification){
        let player:EZAudioPlayer = notification.object as! EZAudioPlayer
        NSLog("Player changed state,isPlaying:%i", player.isPlaying)
    }
    //-----------------------------------------------------------------------------
    // MARK: Utility
    //------------------------------------------------------------------------------
    
    func drawBufferPlot(){
        self.audioPlot.plotType = EZPlotType.Buffer
        self.audioPlot.shouldMirror = false
        self.audioPlot.shouldFill = false
    }

    func drawRollingPlot(){
        self.audioPlot.plotType = EZPlotType.Rolling
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = false
    }
    
    
    func openFileWithFilePathURL(filePathURL:NSURL){
        self.audioFile = EZAudioFile(URL: filePathURL)
        
        //
        // Update the UI
        //
        self.filePathLabel.text = filePathURL.lastPathComponent
        self.positionSlider.maximumValue = Float(self.audioFile.totalFrames)
        self.volumeSlider.value = self.player.volume
        
        //
        // Plot the whole waveform
        //
        
        /*
        self.audioPlot.plotType = EZPlotType.Buffer
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        */
        
        // Can not get plot to work, xcode crashes just writing the code
        /*
        [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,int length)
            {
            [weakSelf.audioPlot updateBuffer:waveformData[0]
            withBufferSize:length];
            }];
        */
        
        //weak var weakSelf = self
        
  
        
        
        // Play the audio file
        //
        self.player.audioFile = self.audioFile
        

    }
    
    
    //------------------------------------------------------------------------------
    // see IBoutlets above for play function
    //------------------------------------------------------------------------------

    
    //-----------------------------------------------------------------------------
    // MARK: EZAudioPlayerDelegate
    //------------------------------------------------------------------------------
    
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
        weak var weakSelf = self
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            weakSelf!.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        })
    }
    func audioPlayer(audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, inAudioFile audioFile: EZAudioFile!) {
        weak var weakSelf = self
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            if !weakSelf!.positionSlider.touchInside {
                weakSelf!.positionSlider.value = Float(framePosition)
            }
        })
    }
    
    //-----------------------------------------------------------------------------
    // MARK: Utility
    //------------------------------------------------------------------------------
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

