import RealmSwift
import UIKit
import SwiftUI

class EditController: UIViewController & UINavigationControllerDelegate {
    public var id: String!
    public var onEdit: (() -> Void)?
    public var item:Contact!

    private let database = try! Realm()
   
    @IBOutlet var name: UITextField!
    @IBOutlet var phoneNumber: UITextField!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        item = database.objects(Contact.self).where {
            $0.id == id}.first!
        name.text = item?.name
        phoneNumber.text = item?.phoneNumber

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(save))

    }
    
    @objc func save() {
        if let currentName = name.text, !currentName.isEmpty, let currentPhoneNumber = phoneNumber.text, !currentPhoneNumber.isEmpty
        {
            try! database.write {
                item.name = currentName
                item.phoneNumber = currentPhoneNumber
            }
            onEdit?()
            navigationController?.popToRootViewController(animated: true)
        }
       else {
            return
            }
    }
    
    @IBAction func delete() {

        database.beginWrite()
        database.delete(item)
        try! database.commitWrite()
        onEdit?()
        navigationController?.popToRootViewController(animated: true)

            }
    
    @IBAction func pickImage() {
     let vc = UIImagePickerController()
     vc.sourceType = .photoLibrary
     vc.delegate = self
     vc.allowsEditing = true
     present(vc, animated: true)
    }
    
    
    @IBAction func shareContact() {
        
        let name = item.name
        let phoneNumber = item.phoneNumber
        let shareAll =  [name, phoneNumber]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
           
    }
}
    
  
 
extension EditController: UIImagePickerControllerDelegate
    {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage
        {
            
            imageView?.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

