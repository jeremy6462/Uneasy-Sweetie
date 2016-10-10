//
//  ChosenSweetieViewController.swift
//  Uneasy Sweetie
//
//  Created by Jeremy Kelleher on 2/13/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class ChosenSweetieViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    var contactPhoneNumber: String?
    var contactImage : UIImage?
    var contactName : String?
        
    var delegate : protocol<ChosenViewControllerDelegate>?
    
    @IBOutlet weak var circularSweetiePictureView: UIImageView!
    @IBOutlet weak var contactSweetieButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        self.showSweetieImage()
    }
    
    func setUpViews() {
        contactSweetieButton.layer.cornerRadius = 10
        
        resetButton.layer.cornerRadius = 10
        
        circularSweetiePictureView.layer.cornerRadius = circularSweetiePictureView.frame.size.width/2
        circularSweetiePictureView.layer.borderColor = UIColor.white.cgColor
        circularSweetiePictureView.layer.borderWidth = 5
        
        nameLabel.text = contactName
    }
    
    // MARK: - View Set Up
    
    func showSweetieImage() {  
        circularSweetiePictureView.image = contactImage
    }
    
    @IBAction func reset(_ sender: AnyObject) {
        delegate?.dismissChosenVC()
    }
    
    // MARK: - Send Sweetie a Message
    
    @IBAction func contactSweetie(_ sender: AnyObject) {
        if ((contactPhoneNumber) != nil) {
            let composer = MFMessageComposeViewController()
            composer.messageComposeDelegate = self
            composer.body = "Sweetie, I need you"
            composer.recipients = [contactPhoneNumber!]
            self.present(composer, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

protocol ChosenViewControllerDelegate {
    func dismissChosenVC()
}

