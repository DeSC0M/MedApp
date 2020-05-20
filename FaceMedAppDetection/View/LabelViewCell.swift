//
//  LabelViewCell.swift
//  FaceMedAppDetection
//
//  Created by Pavel Murzinov on 13.05.2020.
//  Copyright © 2020 Pavel Murzinov. All rights reserved.
//

import UIKit

enum CellType {
    case Head, Middle, Tail
}

class LabelViewCell: UITableViewCell {
    
    let view = UIView()
    let mainLabel = UILabel()
    let avatar = UIImageView()
    
    var type: CellType! {
        didSet {
            settingUI()
            setupConstraint()
        }
    }

    var constraintArray: [NSLayoutConstraint] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = .clear
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        addSomeView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func addSomeView() {
        contentView.addSubview(view)
        view.addSubview(mainLabel)
        view.addSubview(avatar)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraint() {
        constraintArray.forEach {$0.isActive = false}
        constraintArray.removeAll()
        
        avatar.isHidden = true
        
        switch type {
        case .Head:
            avatar.isHidden = false
            constraintArray += [
                                
                avatar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                avatar.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 20),
                avatar.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20),
                avatar.widthAnchor.constraint(equalToConstant: 40),
                avatar.heightAnchor.constraint(equalToConstant: 40),
                avatar.trailingAnchor.constraint(equalTo: mainLabel.leadingAnchor, constant: -10),
                avatar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
                mainLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),
                view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ]
        case .Middle:
            constraintArray += [
                mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            
                view.topAnchor.constraint(equalTo: contentView.topAnchor),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ]
        case .Tail:
            constraintArray += [
                mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                
                view.topAnchor.constraint(equalTo: contentView.topAnchor),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
            ]
        case .none:
            break
        }
        
        constraintArray += [
            mainLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            mainLabel.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 10),
            mainLabel.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: -10),
            mainLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ]
        
        constraintArray.forEach { $0.isActive = true }
    }
    
    private func settingUI() {
        mainLabel.numberOfLines = 0
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 15
        view.layer.shadowOpacity = 0.5
        view.backgroundColor = #colorLiteral(red: 0.9463019967, green: 0.8449216485, blue: 0.6859424114, alpha: 1)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        
        switch type {
        case .Head:
            view.layer.cornerRadius = 5
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            
            avatar.contentMode = .scaleAspectFill
            avatar.clipsToBounds = true
            avatar.layer.borderColor = UIColor.black.cgColor
            avatar.layer.borderWidth = 1
            
            avatar.layer.cornerRadius = 20
            avatar.layer.shadowColor = UIColor.black.cgColor
            avatar.layer.shadowOffset = .zero
            avatar.layer.shadowRadius = 3
            avatar.layer.shadowOpacity = 0.5
        case .Tail:
            view.layer.cornerRadius = 5
            view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .Middle:
            break
        case .none:
            break
        }
    }
    
    func setData(_ labelText: String, _ image: UIImage? = nil) {
        mainLabel.text = labelText
        
        if let img = image {
            avatar.image =  img
        }
    }
    
}
