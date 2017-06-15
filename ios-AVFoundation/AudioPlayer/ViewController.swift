
import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var currentTrack: UITextField!

    var audioPlayer = AVAudioPlayer()
    var tracks = [String]()
    var currentTrackIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAudioPlayer()
    }
    
    func setUpAudioPlayer() {
        tracks = readFiles()
        queueTrack()
        nextSong(songFinished: true)
    }
    
    @IBAction func actionNextTrack(_ sender: Any) {
        audioPlayer.pause()
        audioPlayer.currentTime = audioPlayer.duration - 0.1
        audioPlayer.play()
    }
    
    @IBAction func actionPlay(_ sender: Any) {
        audioPlayer.play()
    }
    
    @IBAction func actionPause(_ sender: Any) {
        audioPlayer.pause()
    }
 
    @IBAction func actionStop(_ sender: Any) {
        if(audioPlayer.isPlaying) {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        } else {
            
        }
    }

    @IBAction func actionRestart(_ sender: Any) {
        if(audioPlayer.isPlaying) {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
            audioPlayer.play()
        } else {
            
        }
    }
    
    func queueTrack() {
        do {
            let url = URL.init(fileURLWithPath: tracks[currentTrackIndex])
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func nextSong(songFinished: Bool) {
        currentTrackIndex += 1
        if (currentTrackIndex >= tracks.count) {
            currentTrackIndex = 0
        }
        queueTrack()
        if (songFinished) {
            audioPlayer.play()
        }
    }
    
    func readFiles() -> [String] {
        return Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Player finish")
    }
        
}

