//
//  PhotoView.swift
//  MyAlbum
//
//  Created by nju on 2022/12/14.
//

import Vision
import UIKit

class PhotoView: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var showBoxButton: UIButton!
    static var allLabels = [UIImage:ImageLabel]()
    static var allImages = [UIImage]()
    static var classify: [String: [UIImage]] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        showBoxButton.layer.cornerRadius = 10
        imageView.image = image
        if let label = PhotoView.allLabels[image!]{
            if label.marked{
                if label.label != "Not Sure"{
                    resultLabel.text! = String(format: "%@ %.1f%%", label.label, label.confident * 100)
                }else{
                    resultLabel.text! = "Not Sure"
                }
            }
            else{
                classify(image: image!)
            }
        }
        setUpBoundingBoxViews()
        for box in self.boundingBoxViews {
            box.addToLayer(self.view.layer)
        }
        resultLabel.textAlignment = .center
        // Do any additional setup after loading the view.
    }
    
    var image: UIImage? = nil
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var classifyRequest :VNCoreMLRequest = {
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
    func classify(image: UIImage) {
        //TODO: use VNImageRequestHandler to perform a classification request
        if let ciImage = CIImage(image: image){
          let orientation = CGImagePropertyOrientation(image.imageOrientation)
          DispatchQueue.global(qos: .userInitiated).async {
            let handle = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do{
                try handle.perform([self.classifyRequest])
            } catch{
                fatalError()
            }
          }
        }
    }

    func processObservations(for request: VNRequest, error: Error?)
    {
       
        DispatchQueue.main.async {
            let label = PhotoView.allLabels[self.image!]
            label?.marked = true
            if let results = request.results as? [VNClassificationObservation]{
                if results.isEmpty{
                    self.resultLabel!.text = "Nothing Found"
                    label?.label = "Nothing Found"
                }else if results[0].confidence < 0.75{
                    self.resultLabel!.text = "Not Sure"
                    label?.label = "Not Sure"
                    if PhotoView.classify["Not Sure"] != nil{
                        PhotoView.classify["Not Sure"]?.append(self.image!)
                    }else{
                        PhotoView.classify.updateValue([self.image!], forKey: "Not Sure")
                    }
                }else{
                    self.resultLabel!.text = String(format: "%@ %.1f%%", results[0].identifier, results[0].confidence * 100)
                    label?.label = results[0].identifier
                    label?.confident = Double(results[0].confidence)
                    if PhotoView.classify[results[0].identifier] != nil {
                        PhotoView.classify[results[0].identifier]?.append(self.image!)
                    }else{
                        PhotoView.classify.updateValue([self.image!], forKey: results[0].identifier)
                    }
                }
            }else{
                self.resultLabel!.text = "Error in MLModel"
            }
            
            
        }
    }
    
    // MARK: - OBJ Detect
    
    
    @IBAction func doDetect(_ sender: Any) {
        if let ciImage = CIImage(image: self.image!){
          DispatchQueue.global(qos: .userInitiated).async {
              let handle = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
            do{
                try handle.perform([self.visionRequest])
            } catch{
                fatalError()
            }
          }
        }
    }
    
    lazy var visionModel: VNCoreMLModel = {
        do {
    //        let coreMLWrapper = SnackLocalizationModel()
          let coreMLWrapper = SnackDetector()
          let visionModel = try VNCoreMLModel(for: coreMLWrapper.model)

          if #available(iOS 13.0, *) {
            visionModel.inputImageFeatureName = "image"
            visionModel.featureProvider = try MLDictionaryFeatureProvider(dictionary: [
                "iouThreshold": MLFeatureValue(double: 0.45),
                "confidenceThreshold": MLFeatureValue(double: 0.25),
            ])
          }

          return visionModel
        } catch {
          fatalError("Failed to create VNCoreMLModel: \(error)")
        }
    }()

    lazy var visionRequest: VNCoreMLRequest = {
      
        let request = VNCoreMLRequest(model: visionModel, completionHandler: {
          [weak self] request, error in
          self?.showObjResult(for: request, error: error)
        })

        // NOTE: If you choose another crop/scale option, then you must also
        // change how the BoundingBoxView objects get scaled when they are drawn.
        // Currently they assume the full input image is used.
        request.imageCropAndScaleOption = .scaleFill
        return request
    }()
    
    func showObjResult(for request: VNRequest, error: Error?)
    {
        DispatchQueue.main.async {
            if let result = request.results as? [VNRecognizedObjectObservation] {
                self.show(predictions: result)
            }else{
                self.show(predictions: [])
            }
        }
    }
    func show(predictions: [VNRecognizedObjectObservation]) {
     //process the results, call show function in BoundingBoxView
        for (i, box) in self.boundingBoxViews.enumerated(){
            if i < predictions.count{
                
                let imageWidth = self.imageView.image?.size.width
                let imageHeight = self.imageView.image?.size.height
                let width = self.view.bounds.width
                let height = width * imageHeight! / imageWidth!
                let diff = (self.view.bounds.height - height) / 2
                
                let scale = CGAffineTransform.identity.scaledBy(x: width, y: height)
                let move = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -(height + diff))
                let rect = predictions[i].boundingBox.applying(scale).applying(move)
                //show the most confident result
                let labelStr = String(format: "%@ %.1f", predictions[i].labels[0].identifier, predictions[i].labels[0].confidence * 100)
                box.show(frame: rect, label: labelStr, color: self.colors[predictions[i].labels[0].identifier] ?? UIColor.purple)
                
            }else{
                box.hide()
            }
        }
    }
    
    let maxBoundingBoxViews = 10
    var boundingBoxViews = [BoundingBoxView]()
    var colors: [String: UIColor] = [:]
    
    func setUpBoundingBoxViews() {
        for _ in 0..<maxBoundingBoxViews {
          boundingBoxViews.append(BoundingBoxView())
        }

        let labels = [
          "apple",
          "banana",
          "cake",
          "candy",
          "carrot",
          "cookie",
          "doughnut",
          "grape",
          "hot dog",
          "ice cream",
          "juice",
          "muffin",
          "orange",
          "pineapple",
          "popcorn",
          "pretzel",
          "salad",
          "strawberry",
          "waffle",
          "watermelon",
        ]

        // Make colors for the bounding boxes. There is one color for
        // each class, 20 classes in total.
        var i = 0
        for r: CGFloat in [0.5, 0.6, 0.75, 0.8, 1.0] {
          for g: CGFloat in [0.5, 0.8] {
            for b: CGFloat in [0.5, 0.8] {
                colors[labels[i]] = UIColor(red: r, green: g, blue: b, alpha: 1)
                i += 1
                }
            }
        }
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

class ImageLabel {
    var label: String
    var marked = false
    var confident = 0.0
    init(){
        self.label = ""
    }
    
}
