//
//  ViewController.swift
//  mylittlemonster
//
//  Created by Nikema Prophet on 3/12/16.
//  Copyright © 2016 Nikema Prophet. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var monsterImg: MonsterImg!
    @IBOutlet weak var foodImg: DragImg!
    @IBOutlet weak var heartImg: DragImg!
    @IBOutlet weak var whistleImg: DragImg!
    @IBOutlet weak var penalty1Img: UIImageView!
    @IBOutlet weak var penalty2Img: UIImageView!
    @IBOutlet weak var penalty3Img: UIImageView!
    @IBOutlet weak var restartBtn: UIButton!
    
    let DIM_ALPHA: CGFloat = 0.2
    let OPAQUE: CGFloat = 1.0
    let MAX_PENALTIES = 3
    
    var penalties = 0
    var timer: NSTimer!
    var monsterHappy = false
    var currentItem: UInt32 = 0
    var isGameOver: Bool = false
    
    var musicPlayer: AVAudioPlayer!
    var sfxBite: AVAudioPlayer!
    var sfxHeart: AVAudioPlayer!
    var sfxDeath: AVAudioPlayer!
    var sfxSkull: AVAudioPlayer!
    var sfxWhistle: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodImg.dropTarget = monsterImg
        heartImg.dropTarget = monsterImg
        whistleImg.dropTarget = monsterImg
        
        penalty1Img.alpha = DIM_ALPHA
        penalty2Img.alpha = DIM_ALPHA
        penalty3Img.alpha = DIM_ALPHA
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.itemDroppedOnCharacter(_:)), name: "onTargetDropped", object: nil)

        do {
            let resourcePath = NSBundle.mainBundle().pathForResource("cave-music", ofType: "mp3")!
            let url = NSURL(fileURLWithPath: resourcePath)
            try musicPlayer = AVAudioPlayer(contentsOfURL: url)
            
            try sfxBite = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bite", ofType: "wav")!))
            try sfxHeart = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("heart", ofType: "wav")!))
            try sfxDeath = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("death", ofType: "wav")!))
            try sfxSkull = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("skull", ofType: "wav")!))
            try sfxWhistle = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("whistle", ofType: "mp3")!))


            musicPlayer.prepareToPlay()
            musicPlayer.play()
            
            sfxBite.prepareToPlay()
            sfxDeath.prepareToPlay()
            sfxHeart.prepareToPlay()
            sfxSkull.prepareToPlay()
            sfxWhistle.prepareToPlay()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        disableNeedsItems()
        startTimer()
        monsterHappy = true
        
    }

    func itemDroppedOnCharacter(notif: AnyObject) {
        monsterHappy = true
        disableNeedsItems()
        
        startTimer()
        
        if currentItem == 0 {
            sfxHeart.play()
        } else if currentItem == 1 {
            sfxBite.play()
        } else {
            sfxWhistle.play()
        }
    }
    
    func startTimer() {
        if timer != nil {
            timer.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(ViewController.changeGameState), userInfo: nil, repeats: true)
    }
    
    func changeGameState() {
        
        if !monsterHappy {
            penalties += 1
            
            sfxSkull.play()
            
            if penalties == 1 {
                penalty1Img.alpha = OPAQUE
                penalty2Img.alpha = DIM_ALPHA
                
            }else if penalties == 2 {
                penalty2Img.alpha = OPAQUE
                penalty3Img.alpha = DIM_ALPHA
            } else if penalties >= 3 {
                penalty3Img.alpha = OPAQUE
            } else {
                dimPenaltyAlpha()
            }
            
            if penalties >= MAX_PENALTIES {
                gameOver()
            }
        }
        
        if !isGameOver {
            let rand = arc4random_uniform(3)
            
            if rand == 0 {
                foodImg.alpha = DIM_ALPHA
                foodImg.userInteractionEnabled = false
                
                whistleImg.alpha = DIM_ALPHA
                whistleImg.userInteractionEnabled = false
                
                heartImg.alpha = OPAQUE
                heartImg.userInteractionEnabled = true
            } else if rand == 1 {
                heartImg.alpha = DIM_ALPHA
                heartImg.userInteractionEnabled = false
                
                whistleImg.alpha = DIM_ALPHA
                whistleImg.userInteractionEnabled = false
                
                foodImg.alpha = OPAQUE
                foodImg.userInteractionEnabled = true
            } else {
                foodImg.alpha = DIM_ALPHA
                foodImg.userInteractionEnabled = false
                
                heartImg.alpha = DIM_ALPHA
                heartImg.userInteractionEnabled = false
                
                whistleImg.alpha = OPAQUE
                whistleImg.userInteractionEnabled = true
                
            }
            
            currentItem = rand
            monsterHappy = false
        }
    }
    
    func gameOver() {
        isGameOver = true
        disableNeedsItems()
        timer.invalidate()
        monsterImg.playDeathAnimation()
        sfxDeath.play()
        restartBtn.hidden = false
    }
    
    @IBAction func onRestartPressed(sender: AnyObject) {
        restartGame()
    }
    
    func restartGame() {
        isGameOver = false
        penalties = 0
        monsterHappy = true
        dimPenaltyAlpha()
        startTimer()
        restartBtn.hidden = true
        monsterImg.playIdleAnimation()
        
    }
    
    func disableNeedsItems() {
        foodImg.alpha = DIM_ALPHA
        foodImg.userInteractionEnabled = false
        
        heartImg.alpha = DIM_ALPHA
        heartImg.userInteractionEnabled = false
        
        whistleImg.alpha = DIM_ALPHA
        whistleImg.userInteractionEnabled = false
    }

    func dimPenaltyAlpha() {
        penalty1Img.alpha = DIM_ALPHA
        penalty2Img.alpha = DIM_ALPHA
        penalty3Img.alpha = DIM_ALPHA
    }
}

