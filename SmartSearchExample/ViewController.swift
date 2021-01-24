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
        collectionView.allowsSelection = false
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, SFSymbolName> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SFSymbolName> { cell, _, sfSymbolName in
            var content = cell.defaultContentConfiguration()

            content.image = UIImage(systemName: sfSymbolName.rawValue)
            content.imageProperties.tintColor = .label

            content.text = sfSymbolName.rawValue

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

        // Filter all symbol names using a smart matching algorithm based on token prefixes
        let smartSearchMatcher = SmartSearchMatcher(searchString: spaceStrippedSearchText)

        sfSymbolNames = SFSymbolNames.all
            .filter { sfSymbolName in
                // If the search text only has one token then we try to match a prefix of the full symbol name.
                //
                // For eaxmple, searching for "square." will match all symbol names beginning with "square." but
                // won't match any symbol names which contain "square." within the name.
                if smartSearchMatcher.searchTokens.count == 1 && smartSearchMatcher.matches(sfSymbolName.rawValue) {
                    return true
                }

                // Break the symbol name into tokens by replacing periods with spaces and try to match that.
                //
                // This treats the individual components of the symbol name as separate tokens and requires a
                // prefix match against each of the tokens in `spaceStrippedSearchString`.
                //
                // For example, searching for "fi dr" will match "cloud.drizzle.fill", "drop.fill",
                // "drop.triangle.fill", and "hand.draw.fill".
                let sfSymbolNameWithSpaces = sfSymbolName.rawValue.replacingOccurrences(of: ".", with: " ")
                return smartSearchMatcher.matches(sfSymbolNameWithSpaces)
            }
    }
}
