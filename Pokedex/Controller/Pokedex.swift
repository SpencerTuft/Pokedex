//
//  PokdexController.swift
//  Pokedex
//
//  Created by Spencer Tuft on 10/22/19.
//  Copyright © 2019 Spencer Tuft. All rights reserved.
//

import UIKit

private let id = "PokedexCell"

class PokedexController: UICollectionViewController {

    // MARK: - Properties

    var pokemon = [Pokemon]()
    var filteredPokemon = [Pokemon]()
    var inSearchMode = false
    var searchBar: UISearchBar!

    let infoView: InfoView = {
        let view = InfoView()
        view.layer.cornerRadius = 5
        return view
    }()

    // Blurred view background
    let visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewComponents()
        fetchPokemon()
    }

    // MARK: - Selectors

    @objc func showSearchBar() {
        configureSearchBar(show: true)
    }

    @objc func handleDismissal() {
        dismissInfoView(pokemon: nil)
    }

    // MARK: - API

    func fetchPokemon() {
        Service.shared.fetchPokemon { (pokemon) in
            DispatchQueue.main.async {
                self.pokemon = pokemon // Store pokemon for this controller to move it around.
                self.collectionView.reloadData() // Reload the view after fetching the pokemon.
            }
        }
    }

    // MARK: - Helper Functions
    
    func showPokemonInfoController(pokemon: Pokemon) {
        let controller = PokemonInfoController() // Setup arbitrary controller
        controller.pokemon = pokemon // Add pokemon data to controller
        self.navigationController?.pushViewController(controller, animated: true) // Push controller to navigation
    }

    func configureSearchBar(show: Bool) {
        if (show) {
            searchBar = UISearchBar()
            searchBar.delegate = self
            searchBar.sizeToFit()
            searchBar.showsCancelButton = true
            searchBar.becomeFirstResponder()
            searchBar.tintColor = .white

            navigationItem.rightBarButtonItem = nil
            navigationItem.titleView = searchBar
        } else {
            navigationItem.titleView = nil
            configureSearchBarButton()
            inSearchMode = false
            collectionView.reloadData()
        }
    }

    func configureSearchBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchBar))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }

    func dismissInfoView(pokemon: Pokemon?) {
        UIView.animate(withDuration: 0.5, animations: {
            self.visualEffectView.alpha = 0
            self.infoView.alpha = 0
            self.infoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (_) in // Closure for doing some action after the modal animation ends
            self.infoView.removeFromSuperview() // Removes the modal
            self.navigationItem.rightBarButtonItem?.isEnabled = true // Re-enable the search button
            guard let pokemon = pokemon else { return } // Get our pokemon data or don't navigate to info page if its not there
            self.showPokemonInfoController(pokemon: pokemon)
        }
    }

    func configureViewComponents() {
        collectionView.backgroundColor = .white

        navigationController?.navigationBar.barTintColor = .primary()
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false // Setting this to true messes with the info view layout

        navigationItem.title = "Pokedex"

        configureSearchBarButton()

        collectionView.register(PokedexCell.self, forCellWithReuseIdentifier: id)

        // Add quick info view and add constraints.
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        visualEffectView.alpha = 0

        // Allow tap outside of modal to dismiss the modal
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        visualEffectView.addGestureRecognizer(gesture)
    }
}

// MARK: - UISearchBarDelegate

extension PokedexController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        configureSearchBar(show: false)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText == "" || searchBar.text == nil {
            inSearchMode = false
            collectionView.reloadData()
            view.endEditing(true)
        } else {
            inSearchMode = true
            filteredPokemon = pokemon.filter({ $0.name?.range(of: searchText.lowercased()) != nil })
            collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource/Delegate

extension PokedexController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inSearchMode ? filteredPokemon.count : pokemon.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Grab a cell and populate it with the pokemon data (Note to self: don't try to mix the model and view in the controller)
        //  Just hand the model data to the view and let the logic for displaying the data be in the view. This pattern works
        //  best when your JSON structure is structured efficiently and optimized for easy access.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! PokedexCell

        // Get the pokemon using the cell index to access the stored list of pokemon by its index.
        cell.pokemon = inSearchMode ? filteredPokemon[indexPath.row] : pokemon[indexPath.row]

        cell.delegate = self

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Get pokemon data
        let currentPokemon = inSearchMode ? filteredPokemon[indexPath.row] : pokemon[indexPath.row]
        
        // Configure the evolution chain data now (no need to cause extra overhead at the beginning)
        
        if let evoChain = currentPokemon.evolutionChain {
            let evolutionChain = EvolutionChain(evolutions: evoChain)
            
            guard let evoIds = evolutionChain.evolutionIds else { return }
            
            var pokemonEvolutions = [Pokemon]()
            evoIds.forEach { (id) in
                pokemonEvolutions.append(pokemon[id - 1]) // Ids are one-indexed but they are in an array which is zero-indexed
            }
            
            currentPokemon.evolutions = pokemonEvolutions
        }
        
        // Push info controller to navigation system
        showPokemonInfoController(pokemon: currentPokemon)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PokedexController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 32, left: 8, bottom: 8, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (view.frame.width - 36) / 3
        return CGSize(width: width, height: width)
    }
}

// MARK: - PokedexCellDelegate

extension PokedexController: PokedexCellDelegate {

    // Create a overlay view (with a blurred background) for displaying a summary of the pokemon info
    func presentInfoView(withPokemon pokemon: Pokemon) {
        
        configureSearchBar(show: false) // The search bar conflicts with the modal for some reason. Hiding it fixes the issue.
        navigationItem.rightBarButtonItem?.isEnabled = false // Disable the search button while showing modal

        view.addSubview(infoView)
        infoView.configureViewComponents()
        infoView.delegate = self
        infoView.pokemon = pokemon
        infoView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width - 64, height: 350)
        infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -44).isActive = true

        infoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        infoView.alpha = 0

        // Dissolve into view animation
        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.alpha = 1
            self.infoView.alpha = 1
            self.infoView.transform = .identity
        }
    }
}

// MARK: - InfoViewDelegate

extension PokedexController: InfoViewDelegate {

    func dismissInfoView(withPokemon pokemon: Pokemon?) {
        dismissInfoView(pokemon: pokemon)
    }
}
