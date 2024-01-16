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
    
    var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        
        content.text = categories[indexPath.row].name
        
        cell.contentConfiguration = content

        return cell
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
            let newCategory = Category()
            newCategory.name = textField.text ?? "nil"
            
            self.categories.append(newCategory)
            self.save(category: newCategory)
        }
        
        alert.addAction(create)
        
        present(alert, animated: true)
    }
    
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
    
}
