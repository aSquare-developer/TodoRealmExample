//
//  CategoryTableViewController.swift
//  TodoRealmExample
//
//  Created by Artur Anissimov on 14.01.2024.
//

import UIKit
import RealmSwift

class CategoryTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?

    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let randomColor: UIColor = .random
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist")
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = randomColor
        appearance.shadowColor = .clear
        navBar.standardAppearance = appearance;
        navBar.scrollEdgeAppearance = navBar.standardAppearance
        navBar.tintColor = .black
        
        searchBar.barTintColor = randomColor
        searchBar.tintColor = randomColor
        searchBar.searchTextField.backgroundColor = .white
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = randomColor.cgColor
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        
        content.text = categories?[indexPath.row].name ?? "No Categories added yet"
        
//      cell.backgroundColor = UIColor(hexString: categories[indexPath.row].color)
        
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if let category = categories?[indexPath.row] {
                do {
                    try realm.write {
                        realm.delete(category.items)
                        realm.delete(category)
                    }
                } catch {
                    print("Error deleting data: \(error)")
                }
            }
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemsTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

    // MARK: - IBAction's
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Create Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { field in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        let create = UIAlertAction(title: "Create", style: .default) { action in
            
            guard let
                    categoryName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                    !categoryName.isEmpty
            else {
                return
            }
            
            let newCategory = Category()
            newCategory.name = categoryName
            
            self.save(category: newCategory)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { action in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(create)
        
        present(alert, animated: true)
    }
    
    // MARK: - Manipulation Methods
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
            
        } catch {
            print("Error saving category: \(error)")
        }
        tableView.reloadData()
    }
    
    func load() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
}

// MARK: - SearchBar Delegate Methods
extension CategoryTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchBarText = searchBar.text else { return }
        
        categories = categories?.filter("name CONTAINS[cd] %@", searchBarText)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard let searchBarText = searchBar.text else { return }
        
        if searchBarText.count == 0 {
            load()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

// MARK: - UIColor Extensions
extension UIColor {

    // Get Random color
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0 ... 1),
            green: .random(in: 0 ... 1),
            blue: .random(in: 0 ... 1),
            alpha: 1)
    }
    
    // Create from HEX String the UIColor object
    convenience init(hexString: String) {
            let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int = UInt64()
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
            }
            self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        }
    
    static func color(withCodedString string: String) -> UIColor?{
         guard let data = Data(base64Encoded: string) else{
             return nil
         }

         return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)

     }
}


// MARK: - UISearchBar Extension
extension UISearchBar {
    func setTextFieldColor(_ color: UIColor) {
        for subView in self.subviews {
            for subSubView in subView.subviews {
                let view = subSubView as? UITextInputTraits
                if view != nil {
                    let textField = view as? UITextField
                    textField?.backgroundColor = color
                    break
                }
            }
        }
    }
}
