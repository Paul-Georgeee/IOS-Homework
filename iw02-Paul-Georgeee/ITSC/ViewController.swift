//
//  ViewController.swift
//  ITSC
//
//  Created by Chun on 2021/10/19.
//

import UIKit

class ViewController: UIViewController {

    var cached = false
    var titleStr = ""
    var dateStr = ""
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentView: UIStackView!
    var contents = [UIView]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateLabel.text = dateStr
        titleLabel.numberOfLines = 0
        dateLabel.numberOfLines = 0
        
        if cached{
            self.load()
        }
        
        
//        scrollView.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
     
    }
    
    func load()
    {
        titleLabel.text = titleStr
        for _view in self.contents{
            if let labelView = _view as? UILabel
            {
                contentView.addArrangedSubview(labelView)
            }
            else if let imageView = _view as? UIImageView
            {
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.heightAnchor.constraint(equalToConstant: CGFloat(200)).isActive = true
                contentView.addArrangedSubview(imageView)
            }
        } 
    }


}

