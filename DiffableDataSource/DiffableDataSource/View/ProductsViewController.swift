//
//  ProductsViewController.swift
//  DiffableDataSource
//
//  Created by Grigory G. on 31.01.25.
//

import UIKit
import Combine

final class ProductsViewController: UIViewController {
    
    // MARK: - UI
    private var tableView = UITableView()
    
    // MARK: - Diffable Data Source
    private var dataSource: UITableViewDiffableDataSource<
        ProductsSection,
        ProductsItem
    >?
    
    // MARK: - Dependencies
    private let viewModel = ProductsViewModel(
        dataProvider: ProductsDataProvider()
    )
    
    // MARK: - State / Tasks
    private var cancellables = Set<AnyCancellable>()
    private var loadTask: Task<Void, Never>?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Products"
        
        setupAddButton()
        setupTable()
        configureDataSource()
        bindViewModel()
        
        load()
    }
    
    // MARK: - Data Loading
    func load() {
        loadTask?.cancel()
        loadTask = Task {
            await viewModel.loadAsync()
        }
    }
    
    // MARK: - Actions
    @objc private func addTapped() {
        loadTask?.cancel()
        loadTask = Task {
            await viewModel.insertAsyncRandomProduct()
        }
    }
    
    // MARK: - Setup UI
    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )
    }
    
    private func setupTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        tableView.dragInteractionEnabled = true
        tableView.allowsSelectionDuringEditing = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Source
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<ProductsSection, ProductsItem>(
            tableView: tableView
        ) { (tableView: UITableView, indexPath: IndexPath, item: ProductsItem) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.textProperties.font = .systemFont(ofSize: 20)
            
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            return cell
        }
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.$state
            .sink { [weak self] state in
                guard let self = self else { return }
                let snapshot = ProductsSnapshotBuilder.build(state: state)
                self.dataSource?.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDelegate
extension ProductsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            
            guard let self,
                  let item = self.dataSource?.itemIdentifier(for: indexPath) else {
                completionHandler(false)
                return
            }
            
            self.viewModel.deleteProduct(id: item.id)
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView,
                   dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?)
    -> UITableViewDropProposal {
        
        return UITableViewDropProposal(
            operation: .move,
            intent: .insertAtDestinationIndexPath
        )
    }
}

// MARK: - UITableViewDragDelegate
extension ProductsViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView,
                   itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem] {
        
        let item = dataSource?.itemIdentifier(for: indexPath)
        
        guard let item else { return [] }
        
        let provider = NSItemProvider(object: item.title as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = item
        
        return [dragItem]
    }
}

// MARK: - UITableViewDropDelegate
extension ProductsViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView,
                   performDropWith coordinator: UITableViewDropCoordinator) {
        
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        coordinator.items.forEach { dropItem in
            guard
                let sourceItem = dropItem.dragItem.localObject as? ProductsItem,
                case let .data(products) = viewModel.state
            else { return }
            
            let destinationIndex = min(destinationIndexPath.row, products.count)
            
            viewModel.moveItem(
                sourceID: sourceItem.id,
                toIndex: destinationIndex
            )
        }
    }
}
