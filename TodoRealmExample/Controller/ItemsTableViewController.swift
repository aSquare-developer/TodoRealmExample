//
//  ItemsTableViewController.swift
//  TodoRealmExample
//
//  Created by Artur Anissimov on 17.01.2024.
//

import UIKit
import RealmSwift

class ItemsTableViewController: UITableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            load()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedCategory?.name
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        if let item = todoItems?[indexPath.row] {
            content.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            content.text = "No Items Added"
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status: \(error)")
            }
        }
        
        tableView.reloadData()
        
//        tableView.deselectRow(at: indexPath, animated: true) ?????
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Create new item", message: "", preferredStyle: .alert)
        
        alert.addTextField { input in
            input.placeholder = "Type item name..."
            textfield = input
        }
        
        let save = UIAlertAction(title: "Save", style: .default) { action in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textfield.text ?? "nil"
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new item: \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addAction(save)
        
        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if let item = todoItems?[indexPath.row] {
                do {
                    try realm.write {
                        realm.delete(item)
                    }
                } catch {
                    print("Error deleting data: \(error)")
                }
            }
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func load() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

extension ItemsTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchBarText = searchBar.text else { return }
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBarText).sorted(byKeyPath: "dateCreated", ascending: true)
        
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
