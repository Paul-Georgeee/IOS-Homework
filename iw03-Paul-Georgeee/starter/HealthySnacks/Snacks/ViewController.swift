/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Vision

class ViewController: UIViewController {
  
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var photoLibraryButton: UIButton!
    @IBOutlet var classifyResultView: UIView!
    @IBOutlet var classifyResultLabel: UILabel!
    @IBOutlet var classifyConstraint: NSLayoutConstraint!

    @IBOutlet var healthyResultLabel: UILabel!
    @IBOutlet var healthyResultView: UIVisualEffectView!
    var firstTime = true

  //TODO: define a VNCoreMLRequest
    lazy var classifyRequest: VNCoreMLRequest = {
        do{
            let snackeClassify = try SnackClassify(configuration: MLModelConfiguration())
            let model = try VNCoreMLModel(for: snackeClassify.model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request, error in
                self?.processObservations(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        }catch{
            fatalError()
        }
    }()
    
    lazy var healthyRequest: VNCoreMLRequest = {
        do{
            let HealthyClassify = try HealthyClassify(configuration: MLModelConfiguration())
            let model = try VNCoreMLModel(for: snackeClassify.model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request, error in
                self?.processObservations(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        }catch{
            fatalError()
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        classifyResultView.alpha = 0
        classifyResultLabel.text = "choose or take a photo"
        healthyResultView.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Show the "choose or take a photo" hint when the app is opened.
        if firstTime {
            showResultsView(delay: 0.5, resultView: self.classifyResultView, resultConstrain: self.classifyConstraint)
            firstTime = false
        }
    }

    @IBAction func takePicture() {
        presentPhotoPicker(sourceType: .camera)
    }

    @IBAction func choosePhoto() {
        presentPhotoPicker(sourceType: .photoLibrary)
    }

    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
        hideResultsView()
    }

    func showResultsView(delay: TimeInterval = 0.1, resultView: UIView, resultConstrain: NSLayoutConstraint) {
        resultConstrain.constant = 100
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.5,
                       delay: delay,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.6,
                       options: .beginFromCurrentState,
                       animations: {
          resultView.alpha = 1
          resultConstrain.constant = -10
          self.view.layoutIfNeeded()
        },
        completion: nil)
    }

    func hideResultsView() {
        UIView.animate(withDuration: 0.3) {
          self.classifyResultView.alpha = 0
        }
    }

                                          
    func classify(image: UIImage) {
        //TODO: use VNImageRequestHandler to perform a classification request
        if let ciImage = CIImage(image: image){
          let orientation = CGImagePropertyOrientation(image.imageOrientation)
          DispatchQueue.global(qos: .userInitiated).async {
            let handle = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do{
              try handle.perform([self.classifyRequest])
            } catch{
              
            } 

          }
        }
    }

                            
    
    func processObservations(for request: VNRequest, error: Error?)
    {
        DispatchQueue.main.async {
            if let results = request.results as? [VNClassificationObservation]{
                if results.isEmpty{
                    self.classifyResultLabel.text = "Nothing Found"
                }else if results[0].confidence < 0.8{
                    self.classifyResultLabel.text = "Not Sure"
                }else{
                    self.classifyResultLabel.text = String(format: "%@ %.1f%%", results[0].identifier, results[0].confidence * 100)
                }
            }else{
                self.classifyResultLabel.text = "Error in MLModel"
            }
            self.showResultsView(resultView: self.classifyResultView, resultConstrain: self.classifyConstraint)
        }
    }
                                        
}
  //TODO: define a function like func processObservations(for request: VNRequest, error: Error?)  to process the results from the classification model

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)

	let image = info[.originalImage] as! UIImage
    imageView.image = image

    classify(image: image)
  }
}
