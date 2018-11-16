//
//  ImagenViewController.swift
//  SocialNetwork
//
//  Created by Julio César on 31/10/18.
//  Copyright © 2018 Tecsup. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var descripcionTextField: UITextField!
    
    @IBOutlet weak var elegirContactoBoton: UIButton!
    
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    
    var imagePicker = UIImagePickerController()
    var imagenID = NSUUID().uuidString
    var audioID = NSUUID().uuidString
    var URLaudio = ""
    
    var audioRecorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    var audioURL : URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecorder()
        playButton.isEnabled = false
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = true

        // Do any additional setup after loading the view.
    }
    
    //AUDIO
    
    func setupRecorder(){
        do{
            //creando una sesión de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //Creando una dirección para el archivo de audio
            let basePath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents : pathComponents)
            
            print("**************************")
            print(audioURL)
            print("**************************")
            
            //Crear opciones para el grabador de audio
            var settings : [String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //Crear el objeto de grabacion de audio
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder!.prepareToRecord()
            
        } catch let error as NSError{
            print (error)
        }
    }
    
    
    
    @IBAction func recordTapped(_ sender: Any) {
        if audioRecorder!.isRecording{
            //Detener grabación
            audioRecorder?.stop()
            //Cambiar el texto del boton grabar
            recordButton.setTitle("Record", for: .normal)
            playButton.isEnabled = true
            //addButton.isEnabled = true
        }else{
            //Empezar a grabar
            audioRecorder?.record()
            //Cambiar el titulo del boton a detener
            recordButton.setTitle("Stop", for: .normal)
        }
    }
    
    
    @IBAction func playTapped(_ sender: Any) {
        do{
            try audioPlayer = AVAudioPlayer(contentsOf : audioURL!)
            audioPlayer!.play()
        }
        catch{}
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        imageView.backgroundColor = UIColor.clear
        elegirContactoBoton.isEnabled = true
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func camaraTapped(_ sender: Any) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        //imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    var imagenDownloadURL = ""
    var audioDownloadURL = ""
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        //performSegue(withIdentifier: "seleccionarContactoSegue", sender: nil)
        
        elegirContactoBoton.isEnabled = false
        let imagenesFolder = FIRStorage.storage().reference().child("imagenes")
        //Audio
        let audiosFolder = FIRStorage.storage().reference().child("audios")
        let imagenData = UIImagePNGRepresentation(imageView.image!)!
        //let audioData = audioPlayer as NSData!
        //let audioData = audioPlayer as NSData
        //NSDate audioData = [NSData dataWithContentsOfFile:audioURL]
        
        let audioData = NSData(contentsOf: audioURL!)! as Data
        
        
        //let audioData =  try NSData(contentsOf: audioURL!)
        
       
        
        imagenesFolder.child("\(imagenID).jpg").put(imagenData, metadata: nil, completion: {(metadata, error) in
            print("Intentando subir la imagen")
            if(error != nil){
                print("Ocurrio un error:\(error)")
            }
            else{
                print("Imagen subida correctamente!")
                self.imagenDownloadURL = (metadata?.downloadURL()?.absoluteString)!
                self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: metadata?.downloadURL()!.absoluteString)
            }
        })
        
        //elegirContactoBoton.isEnabled = true
        
       audiosFolder.child("\(audioID).mp4").put(audioData, metadata: nil, completion: {(metadata, error) in
            print("Intentando subir el audio")
            if (error != nil){
                print("Error : \(String(describing: error))")
            }else{
                print("Audio subido correctamente!")
                self.audioDownloadURL = (metadata?.downloadURL()?.absoluteString)!
            }
        })
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let siguienteVC = segue.destination as! ElegirUsuarioViewController
        siguienteVC.imagenURL = sender as! String
        siguienteVC.descrip = descripcionTextField.text!
        siguienteVC.imagenID = imagenID
        siguienteVC.audioID = audioID
        siguienteVC.URLaudio = audioDownloadURL as String
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
