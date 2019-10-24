//
//  Pokemon.swift
//  Pokedex
//
//  Created by Spencer Tuft on 10/22/19.
//  Copyright © 2019 Spencer Tuft. All rights reserved.
//

import UIKit

struct EvolutionChain {
    
    var evolutions: [[String: AnyObject]]?
    var evolutionIds: [Int]?
    
    init(evolutions: [[String: AnyObject]]) {
        self.evolutions = evolutions
        self.evolutionIds = setEvolutionIds()
    }
    
    func setEvolutionIds() -> [Int] {
        var results = [Int]()
        
        evolutions?.forEach({ (dictionary) in
            if let idStr = dictionary["id"] as? String {
                guard let id = Int(idStr) else { return }
                
                // Some pokemon have evolutions that are not one of the originals.
                //  We avoid a crash by limiting evolutions to the original 151.
                if id <= 151 {
                    results.append(id)
                }
            }
        })
        
        return results
    }
    
}

class Pokemon {

    var name: String?
    var imageUrl: String?
    var image: UIImage?
    var id: Int?
    var weight: Int?
    var height: Int?
    var defense: Int?
    var attack: Int?
    var description: String?
    var type: String?
    var evolutionChain: [[String: AnyObject]]?
    var evolutions: [Pokemon]?
    
    // This constructor uses an object of key-value pairs and performs
    // a "safe get" in case the information didn't come back from the API
    init(id: Int, dictionary: [String: AnyObject]) {

        self.id = id

        if let name = dictionary["name"] as? String {
            self.name = name
        }

        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }

        if let weight = dictionary["weight"] as? Int {
            self.weight = weight
        }

        if let height = dictionary["height"] as? Int {
            self.height = height
        }

        if let defense = dictionary["defense"] as? Int {
            self.defense = defense
        }

        if let attack = dictionary["attack"] as? Int {
            self.attack = attack
        }

        if let description = dictionary["description"] as? String {
            self.description = description
        }

        if let type = dictionary["type"] as? String {
            self.type = type.capitalized
        }

        if let evolutionChain = dictionary["evolutionChain"] as? [[String: AnyObject]] {
            self.evolutionChain = evolutionChain
        }
    }
}
