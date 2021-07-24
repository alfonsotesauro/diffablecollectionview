/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A basic grid described by compositional layout
*/

import Cocoa

let shouldUseImageViewInsteadOfTextView = true

class GridWindowController: NSWindowController {
    
    @objc weak var mainViewController: ViewController!
    var images: [NSImage] = [NSImage]()
    @objc var imageURLs: [URL]!
    
    enum Section {
        case main
    }

    private var dataSource: NSCollectionViewDiffableDataSource<Section, Int>! = nil
    @IBOutlet weak var collectionView: NSCollectionView!

    override func windowDidLoad() {
        super.windowDidLoad()
        configureHierarchy()
        configureDataSource()
    }
    
    deinit {
        print("Function: \(#function), line: \(#line)")
    }
}

extension GridWindowController {
    private func createLayout() -> NSCollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        let layout = NSCollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension GridWindowController {
    private func configureHierarchy() {
        
        let nibName = shouldUseImageViewInsteadOfTextView ? "ImageItem" : "TextItem"
        
        let itemNib = NSNib(nibNamed: nibName, bundle: nil)
        
        if shouldUseImageViewInsteadOfTextView {
            collectionView.register(itemNib, forItemWithIdentifier: ImageItem.reuseIdentifier)
        } else {
            collectionView.register(itemNib, forItemWithIdentifier: TextItem.reuseIdentifier)
        }
        
        collectionView.register(itemNib, forItemWithIdentifier: TextItem.reuseIdentifier)

        collectionView.collectionViewLayout = createLayout()
    }
    private func configureDataSource() {
        
        dataSource = NSCollectionViewDiffableDataSource
            <Section, Int>(collectionView: collectionView, itemProvider: { [weak self]
                (collectionView: NSCollectionView, indexPath: IndexPath, identifier: Int) -> NSCollectionViewItem? in
            guard let item = collectionView.makeItem(withIdentifier: shouldUseImageViewInsteadOfTextView ? ImageItem.reuseIdentifier : TextItem.reuseIdentifier, for: indexPath) as? ImageItem else { return nil }
            
            guard let self = self else { return nil }
           
            item.iconURL = self.imageURLs[indexPath.item]
            
            return item
        })

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(Array(0..<self.imageURLs.count), toSection: Section.main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension GridWindowController: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        
        let index = self.mainViewController.gridWindowControllers.index(of: self)
        
        self.mainViewController.gridWindowControllers.removeObject(at: index)
        
    }
    
}
