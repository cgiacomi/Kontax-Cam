//
//  FXCollectionViewController.swift
//  Kontax Cam
//
//  Created by Kevin Laminto on 29/5/20.
//  Copyright © 2020 Kevin Laminto. All rights reserved.
//

import UIKit
import PanModal

private let reuseIdentifier = "fxCell"
private let headerIdentifier = "fxHeader"

class FXCollectionViewController: UICollectionViewController {
    
    private let effects: [Effect] = FilterType.allCases.map({ Effect(name: $0, icon: $0.iconName) }).filter({ $0.name != FilterType.lut })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavigationBar(tintColor: .label, title: "Effects", preferredLargeTitle: false, removeSeparator: true)
        
        // UICollectionView setup
        collectionView.collectionViewLayout = makeLayout()
        collectionView.register(ModalHeaderPresentable.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return effects.count
    }
}

// MARK: - Collectionview delegate
extension FXCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FXCollectionViewCell
        let currentFx = effects[indexPath.row]
        
        cell.titleLabel.text = currentFx.name.description
        cell.iconImageView.image = IconHelper.shared.getIconImage(iconName: currentFx.icon)
        
        if FilterEngine.shared.allowedFilters.contains(currentFx.name) { cell.toggleSelected() }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        TapticHelper.shared.mediumTaptic()
        
        // 1. Update UI
        let selectedCell = collectionView.cellForItem(at: indexPath) as! FXCollectionViewCell
        selectedCell.toggleSelected()
        
        // 2. Update datasource
        let selectedFx = effects[indexPath.row]
        smartAppend(selectedCell, selectedFx)
        
        // Save the selection to UserDefaults
        UserDefaultsHelper.shared.setData(value: try? PropertyListEncoder().encode(FilterEngine.shared.allowedFilters), key: .userFxList)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as? ModalHeaderPresentable else {
            fatalError("Could not dequeue SectionHeader")
        }
        headerView.titleLabel.text = "Tip: Long press to customise the effect."
        
        return headerView
    }
    
    /// Append the selecteed FX to the allowed filters list. If exist, simply remove it.
    /// - Parameters:
    ///   - selectedCell: The selected cell
    ///   - selectedFx: The selected Effects
    private func smartAppend(_ selectedCell: FXCollectionViewCell, _ selectedFx: Effect) {
        if selectedCell.isFxSelected {
            FilterEngine.shared.allowedFilters.append(selectedFx.name)
        } else {
            FilterEngine.shared.allowedFilters.remove(at: FilterEngine.shared.allowedFilters.firstIndex(of: selectedFx.name)!)
        }
        FilterEngine.shared.allowedFilters.sort(by: { $0.rawValue < $1.rawValue })
    }
}

extension FXCollectionViewController {
    // MARK: - Class functions
    private func createSection() -> NSCollectionLayoutSection {
        let contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = contentInsets
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.25),
            heightDimension: .fractionalWidth(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = contentInsets
        section.orthogonalScrollingBehavior = .groupPaging
        section.boundarySupplementaryItems = [makeSectionHeader()]
        
        return section
    }
    
    private func makeLayout() -> UICollectionViewLayout  {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnv: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            return self.createSection()
        }
        
        // Configure the Layout with interSectionSpacing
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        
        return layout
    }
    
    private func makeSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(40))
        
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return layoutSectionHeader
    }
}

extension FXCollectionViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return collectionView
    }
}

