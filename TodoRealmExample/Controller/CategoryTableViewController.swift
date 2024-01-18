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

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        load()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        
        content.text = categories?[indexPath.row].name ?? "No Categories added yet"
        
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
            let newCategory = Category()
            newCategory.name = textField.text ?? "nil"
            
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
    
    func load() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
}
