//
//  PokedexCell.swift
//  Pokedex
//
//  Created by Spencer Tuft on 10/22/19.
//  Copyright © 2019 Spencer Tuft. All rights reserved.
//

import UIKit

// Import the presentInfoView function from the pokedex controller
protocol PokedexCellDelegate {
    func presentInfoView(withPokemon pokemon: Pokemon)
}

class PokedexCell: UICollectionViewCell {

    // MARK: - Properties

    var delegate: PokedexCellDelegate?

    // Set the name label and image for the tile/cell
    var pokemon: Pokemon? {
        didSet {
            nameLabel.text = pokemon?.name?.capitalized
            imageView.image = pokemon?.image
        }
    }

    // Create the image view for the pokemon image
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .groupTableViewBackground
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // Create the pokemon name label container
    lazy var nameContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary()

        view.addSubview(nameLabel)
        nameLabel.center(inView: view)

        return view
    }()

    // Create the pokemon name label
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Unknown"
        return label
    }()

    // MARK: - Init

    // Essentially the constructor for our pokemon collection view cell
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureViewComponents()
    }

    // Not sure why XCode needs this...
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Selectors

    // This selector is used to display the quick information view after a long holding press on a pokemon tile/cell
    @objc func displayInfoView(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            guard let pokemon = self.pokemon else { return }
            delegate?.presentInfoView(withPokemon: pokemon)
        }
    }

    // MARK: - Helper Functions

    func configureViewComponents() {
        self.layer.cornerRadius = 2
        self.clipsToBounds = true

        let nameLabelOffset: CGFloat = 32 // height of name label container
        
        // Add the pokemon image to the top of the cell
        // Pin the image to the top, left, and right -- set the height so that the bottom border is effectively pinned
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: self.frame.height - nameLabelOffset)

        // Add the name label container to the bottom of the cell
        // Pin the container to the bottom, left, and right -- set the height so the top border is effectively pinned
        addSubview(nameContainerView)
        nameContainerView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: nameLabelOffset)

        // Recognize long hold on cell so that we can display the pokemon quick info view
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(displayInfoView))
        self.addGestureRecognizer(longPressGestureRecognizer)
    }

}
