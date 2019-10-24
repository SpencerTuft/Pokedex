//
//  Service.swift
//  Pokedex
//
//  Created by Spencer Tuft on 10/22/19.
//  Copyright © 2019 Spencer Tuft. All rights reserved.
//

import UIKit

class Service {

    static let shared = Service()
    let pokemonUrl = "https://pokedex-bb36f.firebaseio.com/pokemon.json"
    
    // To successfully import the JSON, add an entry to the Info.plist
    //  for App Transport Securtity: Arbitrary Loads = YES

    func fetchPokemon(resolve: @escaping ([Pokemon]) -> Void) {
        var pokemons = [Pokemon]()

        guard let url = URL(string: pokemonUrl) else { return }

        URLSession.shared.dataTask(with: url) { (data, _, error) in

            // Handle errors
            if let error = error {
                print("Failed to fetch data with error: ", error.localizedDescription)
                return
            }

            guard let data = data else { return }

            do {
                // Parse JSON (Hands down this is the best way to parse JSON data because decodables can be avoided!)
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyObject] else { return }

                // Format Pokemon data
                for (key, result) in json.enumerated() {
                    if let dictionary = result as? [String: AnyObject] {
                        
                        // Create the Pokemon using the pokemon class.
                        //  Notice how we pass in a dictionary. That is because we can perform a "safe get" on that
                        //  dictionary to set Pokemon attributes only if they exist.
                        let pokemon = Pokemon(id: key, dictionary: dictionary)
                        
                        
                        guard let imageUrl = pokemon.imageUrl else { return }
                        self.fetchImage(withUrlString: imageUrl, resolve: { (image) in
                            pokemon.image = image
                            pokemons.append(pokemon)

                            // Guaruntee the same sore order evertime the API is called
                            pokemons.sort(by: { (poke1, poke2) -> Bool in
                                return poke1.id! < poke2.id!
                            })

                            resolve(pokemons)
                        })
                    }
                }

            } catch let error {
                print("Failed to parse JSON: ", error.localizedDescription)
            }

        }.resume()
    }

    private func fetchImage(withUrlString urlString: String, resolve: @escaping(UIImage) -> Void) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { (data, _, error) in

            if let error = error {
                print("Failed to fetch image: ", error.localizedDescription)
                return
            }

            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            resolve(image)

        }.resume()
    }
}
