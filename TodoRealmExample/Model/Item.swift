//
//  Item.swift
//  TodoRealmExample
//
//  Created by Artur Anissimov on 15.01.2024.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
