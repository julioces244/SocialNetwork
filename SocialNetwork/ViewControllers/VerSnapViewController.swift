//
//  VerSnapViewController.swift
//  SocialNetwork
//
//  Created by Julio César on 9/11/18.
//  Copyright © 2018 Tecsup. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import AVFoundation


class VerSnapViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    var snap = Snap()
    
    var audioRecorder : AVAudioRecorder?
    var audioURL : URL?
    var player : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text? = snap.descrip
        imageView.sd_setImage(with: URL(string: snap.imagenURL))
       
        

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func verplayTapped(_ sender: Any) {
        
        let pathString = snap.audioID
        let storageReference = FIRStorage.storage().reference().child("audios").child("\(pathString).mp4")
        let fileUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let fileUrl = fileUrls.first?.appendingPathComponent(pathString) else {
            return
        }
        
        let downloadTask = storageReference.write(toFile: fileUrl)
        
        downloadTask.observe(.success) { _ in
            do {
                self.player = try AVAudioPlayer(contentsOf: fileUrl)
                self.player?.prepareToPlay()
                self.player?.play()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
        
    
    
    override func viewWillDisappear(_ animated: Bool) {
        FIRDatabase.database().reference().child("usuarios").child(FIRAuth.auth()!.currentUser!.uid).child("snaps").child(snap.id).removeValue()
        
        FIRStorage.storage().reference().child("imagenes").child("\(snap.imagenID).jpg").delete{(error) in
            print("se elimino la imagen correctamente")
        }
        
        FIRStorage.storage().reference().child("audios").child("\(snap.audioID).mp4").delete{(error)
            in print("Se eliminó correctamente el audio")
        }
        
    }


}
