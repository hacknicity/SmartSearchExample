//
//  ViewController.swift
//  SmartSearchExample
//
//  Created by Geoff Hackworth on 23/01/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private lazy var dataSource = makeDataSource()

    private var sfSymbolNames = SFSymbolNames.all {
        didSet {
            applySnapshot()
        }
    }

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none

        return searchController
    }()
}

// MARK: - View Lifecycle
extension ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        createLayout()
        initialiseNavigationBar()
        applySnapshot()
    }
}

// MARK: - UI Initialisation
extension ViewController {

    private func initialiseNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

// MARK: - Collection View Helpers
extension ViewController {

    private enum Section: Int, CaseIterable {
        case all
    }

    private func createLayout() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
        collectionView.dataSource = dataSource
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, SFSymbolName> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SFSymbolName> { cell, _, sfSymbolName in
            var content = cell.defaultContentConfiguration()

            content.image = UIImage(systemName: sfSymbolName.value)
            content.imageProperties.tintColor = .label

            content.text = sfSymbolName.value

            cell.contentConfiguration = content
        }

        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, sfSymbolName -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: sfSymbolName)
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SFSymbolName>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(sfSymbolNames, toSection: .all)

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }

        // Strip leading/trailing whitespace from `searchText`
        let spaceStrippedSearchText = searchText.trimmingCharacters(in: .whitespaces)

        // Show all the symbols when `spaceStrippedSearchText` is empty
        guard !spaceStrippedSearchText.isEmpty else {
            sfSymbolNames = SFSymbolNames.all
            return
        }

        // Naïve search algorithm using a simple substring test
        sfSymbolNames = SFSymbolNames.all
            .filter { sfSymbolName in
                sfSymbolName.value.contains(spaceStrippedSearchText)
            }
    }
}
