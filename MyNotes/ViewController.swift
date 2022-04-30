import RealmSwift
import UIKit


class Contact: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var phoneNumber: String = ""

}



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var list: UITableView!

    private let database = try! Realm()
    private var contacts = [Contact]()
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
        list.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        list.delegate = self
        list.dataSource = self
        
        contacts = database.objects(Contact.self).map({ $0 })
        
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return contacts.count
       }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = list.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
           cell.textLabel?.text = contacts[indexPath.row].name
           return cell
       }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          list.deselectRow(at: indexPath, animated: true)
            
          let item = contacts[indexPath.row]
          self.performSegue(withIdentifier: "edit", sender: item)

      }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? EditController, let item = sender as? Contact, segue.identifier == "edit" {
            print(segue)
            vc.id = item.id
            vc.onEdit = { [weak self] in self?.refresh()}
            vc.title = item.name
            }
        
    }
    
    func refresh() {
        contacts = database.objects(Contact.self).map({ $0 })
        list.reloadData()
        }
    
    @IBAction func newContact() {
    
        let alert = UIAlertController(title: "New contact", message: "Enter name and phone number", preferredStyle: .alert)

        alert.addTextField { field in field.placeholder = "Enter name..."}
        
        alert.addTextField { field in field.placeholder = "Enter phone number..."}
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (_) in
            let textFields = alert.textFields
            if (textFields != nil) {
                
                let name = alert.textFields?.first?.text
                let phoneNumber = alert.textFields?[1].text
              
                if !name!.isEmpty && !phoneNumber!.isEmpty
                {
                
                    self.database.beginWrite()
                    let newContact = Contact()
                    newContact.id = NSUUID().uuidString
                    newContact.name = name!
                    newContact.phoneNumber = phoneNumber!
                    self.database.add(newContact)
                    try!  self.database.commitWrite()
                    self.refresh()
            }}}
            ))

       present(alert, animated: true)
           }

}

