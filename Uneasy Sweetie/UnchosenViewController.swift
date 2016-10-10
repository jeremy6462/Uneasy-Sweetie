//
//  UnchosenViewController.swift
//  Uneasy Sweetie
//
//  Created by Jeremy Kelleher on 2/13/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class UnchosenViewController: UIViewController, ChosenViewControllerDelegate, CNContactPickerDelegate, CNContactViewControllerDelegate  {
    
    let SweetieNumberToReachKey = "BaesDigitsKey"
    let SweetieNameKey = "SweetieNameKey"
    let SweetieImageDataKey = "SweetieImageDataKey"
    
    @IBOutlet weak var addContactButton: UIButton!
    @IBOutlet weak var instructions: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let timer = Timer(fireAt: Date().addingTimeInterval(3), interval: 1, target: self, selector: #selector(UnchosenViewController.showInstructions), userInfo: nil, repeats: false)
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let unarchivedData = unarchive()
        switch unarchivedData {
        case (nil, nil, nil):
            break
        case (let name, let number, let image):
            showChosenSweetieVC(name!, contactNumber: number!, contactImage: image!)
        }
    }
    
    // MARK: - Add Contact
    
    @IBAction func addContact(_ sender: AnyObject) {
        showPicker()
    }
    
    func showPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self;
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        picker.dismiss(animated: true, completion: nil)
        self.processContact(contact)
    }
    
    func processContact(_ contact: CNContact) {
        
        let contactName = contact.givenName + " " + contact.familyName
        
        var imageToUse : UIImage?
        if contact.imageData != nil {
            imageToUse = ImageResizer.resize(UIImage(data: contact.imageData!)!, newSize: CGSize(width: 760, height: 760))
        } else {
            imageToUse = ImageResizer.resize(UIImage(named: "noPhotoFound")!, newSize: CGSize(width: 760, height: 760))
        }
        
        let numbers = contact.phoneNumbers
        switch numbers.count {
            
        case 0:
            
            let alert = UIAlertController(title: "No phone number found for this contact", message: "Uneasy Sweetie could not find any phone numbers for this contact. Add a phone number to their contact and come back to add them as your sweetie!", preferredStyle: UIAlertControllerStyle.alert)
            let cancel = UIAlertAction(title: "Okay!", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
        case 1:
            
            let contactPhoneNumber = numbers[0].value.stringValue
            archive(contactName, contactPhoneNumber: contactPhoneNumber, contactImage: imageToUse!)
            showChosenSweetieVC(contactName, contactNumber: contactPhoneNumber, contactImage: imageToUse!)
            
        default:
            
            let actionSheet = UIAlertController(title: nil , message: "What's the best way to reach your sweetie?", preferredStyle: UIAlertControllerStyle.actionSheet)
            for phoneNumber in numbers {
                let valuesToDisplay = presentableText(phoneNumber)
                actionSheet.addAction(UIAlertAction(title: "\(valuesToDisplay.0)  \(valuesToDisplay.1)" , style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                    let numberChosen = phoneNumber.value.stringValue
                    self.archive(contactName, contactPhoneNumber: numberChosen, contactImage: imageToUse!)
                    self.showChosenSweetieVC(contactName, contactNumber: numberChosen, contactImage: imageToUse!)
                }))
            }
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
            break
            
        }
        
    }
    
    // precondition - should only get phone numbers with labels of iPhone or mobile
    func presentableText(_ phoneNumber: CNLabeledValue<CNPhoneNumber>) -> (String, String) {
        var label : String
        guard let phoneNumberLabel = phoneNumber.label else { return ("", phoneNumber.value.stringValue) }
        switch phoneNumberLabel {
        case CNLabelPhoneNumberiPhone:
            label = "iPhone"
        case CNLabelPhoneNumberMobile:
            label = "Mobile"
        case CNLabelPhoneNumberMain:
            label = "Main"
        case CNLabelHome:
            label = "Home"
        case CNLabelWork:
            label = "Work"
        default:
            label = "Other"
            break
        }
        let number = phoneNumber.value.stringValue
        return (label,number)
    }
    
    // MARK: - Switch State
    
    func showChosenSweetieVC(_ contactName: String, contactNumber: String, contactImage: UIImage) {
        let vc = (self.storyboard?.instantiateViewController(withIdentifier: "ChosenSweetie") as? ChosenSweetieViewController)!
        vc.contactPhoneNumber = contactNumber
        vc.contactName = contactName
        vc.contactImage = contactImage
        vc.delegate = self
        self.present(vc, animated: false, completion: nil)
    }
    
    func dismissChosenVC() {
        self.dismiss(animated: false, completion: nil)
        self.deleteSavedData()
    }
    
    
    // MARK: - Database Stroage
    
    func archive(_ contactName: String, contactPhoneNumber: String, contactImage: UIImage) {
        let defaults = UserDefaults.standard
        defaults.setValue(contactPhoneNumber, forKey: SweetieNumberToReachKey)
        defaults.setValue(contactName, forKey: SweetieNameKey)
        defaults.setValue(UIImagePNGRepresentation(contactImage), forKey: SweetieImageDataKey)
    }
    
    func unarchive() -> (String?, String?, UIImage?) {
        let defaults = UserDefaults.standard
        let foundNumber = defaults.value(forKey: SweetieNumberToReachKey) as? String
        let foundName = defaults.value(forKey: SweetieNameKey) as? String
        let foundImageData = defaults.value(forKey: SweetieImageDataKey) as? Data
        if (foundNumber != nil && foundName != nil && foundImageData != nil) {
            return (foundName!, foundNumber!, UIImage(data: foundImageData!)!)
        } else {
            return (nil, nil, nil)
        }
    }
    
    func deleteSavedData() { 
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: SweetieNumberToReachKey)
        defaults.removeObject(forKey: SweetieNameKey)
        defaults.removeObject(forKey: SweetieImageDataKey)
    }
    
    // MARK: - Show Instructions
    
    func showInstructions() {
        UIView.animate(withDuration: 1) { () -> Void in
            self.instructions.alpha = 1.0
        }
    }
    
}

