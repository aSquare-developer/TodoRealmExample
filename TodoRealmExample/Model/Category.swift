//
//  Category.swift
//  TodoRealmExample
//
//  Created by Artur Anissimov on 15.01.2024.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
