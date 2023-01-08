//
//  MainView.swift
//  MyAlbum
//
//  Created by nju on 2022/12/14.
//

import UIKit


class MainView: UIViewController {

    let manager = FileManager.default
    var photoUrl: URL? = nil
    var photocnt = 0
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    var photo: UIImage = UIImage()
    
    
    func showAlert()
    {
        let alert = UIAlertController(title: "Alert", message: "Error in using file system", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoButton.layer.cornerRadius = 10
        cameraButton.layer.cornerRadius = 10
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        guard let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first else{
            showAlert()
            return
        }
        photoUrl = url.appendingPathComponent("photos")
        let pUrl = photoUrl!
        do{
            let fileNames = try manager.contentsOfDirectory(atPath: pUrl.path)
            for f in fileNames{
                let fileUrl = pUrl.appendingPathComponent(f)
                if let imageData = manager.contents(atPath: fileUrl.path){
                    if let _image = UIImage(data: imageData){
                        PhotoView.allImages.append(_image)
                        PhotoView.allLabels.updateValue(ImageLabel(), forKey: _image)
                        self.photocnt = self.photocnt + 1
                    }
                }
            }
        }catch{
            do{
                try manager.createDirectory(at: pUrl, withIntermediateDirectories: false, attributes: [:])
            }catch{
                showAlert()
                return
            }
        }
        
        
        
    }
    
    @IBAction func takePicture(_ sender: Any) {
        presentPhotoPicker(sourceType: .camera)
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
        presentPhotoPicker(sourceType: .photoLibrary)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ToPhotoView"{
            let photoView = segue.destination as! PhotoView
            photoView.image = self.photo
            PhotoView.allImages.append(self.photo)
            PhotoView.allLabels.updateValue(ImageLabel(), forKey: self.photo)
            
            if let pUrl = self.photoUrl{
                let fileUrl = pUrl.appendingPathComponent(String("photo\(self.photocnt).jpeg"))
                if manager.createFile(atPath: fileUrl.path, contents: self.photo.jpegData(compressionQuality: 0.5), attributes: [:]){
                    self.photocnt = self.photocnt + 1
                }
            }
        }
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker:  UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)

      self.photo = info[.originalImage] as! UIImage
      self.performSegue(withIdentifier: "ToPhotoView", sender: self)
  }
}
