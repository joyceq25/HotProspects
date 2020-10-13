//
//  Prospect.swift
//  HotProspects
//
//  Created by Ping Yun on 10/11/20.
//

import SwiftUI

//class that stores one prospect
class Prospect: Identifiable, Codable {
    let id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    //isContacted can be read from other files but only written from current file 
    fileprivate(set) var isContacted = false
}

//class that stores array of Prospects 
class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    //property that contains save key to use as property for UserDefaults
    static let saveKey = "SavedData"
    
    init() {
        //loads data from UserDefaults if possible
        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode( [Prospect].self, from: data) {
                self.people = decoded
                return
            }
        }
        
        self.people = []
    }
    
    //flips isContacted boolean, sends change notification out, calls save() method 
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    //writes current data to UserDefaults, to be called when adding prospect or toggling its isContacted property
    func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: "SavedData")
        }
    }
    
    //adds prospect to people array, calls save method
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
}
