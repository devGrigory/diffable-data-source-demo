//
//  ProductsViewModel.swift
//  DiffableDataSource
//
//  Created by Grigory G. on 31.01.25.
//

import UIKit
import Combine

@MainActor
final class ProductsViewModel {
    
    // MARK: - Published State
    @Published private(set) var state: State = .loading
    
    // MARK: - Private Properties
    private let dataProvider: ProductsDataProviding
    private var products: [Product] = []
    
    // MARK: - Initializer
    init(dataProvider: ProductsDataProviding) {
        self.dataProvider = dataProvider
    }
    
    // MARK: - Public Async Actions
    func loadAsync() async {
        state = .loading
        
        do {
            products = try await dataProvider.fetchProducts()
            emit()
        } catch {
            state = .empty
        }
    }
    
    func insertAsyncRandomProduct() async {
        do {
            let random = try await dataProvider.fetchRandomProduct()
            
            let newItem = Product(
                id: UUID().uuidString,
                title: random.title
            )
            
            products.insert(newItem, at: 0)
            emit()
            
        } catch {
            state = .empty
        }
    }
    
    // MARK: - Public Sync Actions
    func deleteProduct(id: String) {
        products.removeAll { $0.id == id }
        emit()
    }
    
    func moveItem(sourceID: String, toIndex: Int) {
        guard let fromIndex = products.firstIndex(where: { $0.id == sourceID }) else {
            return
        }
        
        let item = products.remove(at: fromIndex)
        let safeIndex = min(max(toIndex, 0), products.count)
        products.insert(item, at: safeIndex)
        
        emit()
    }
    
    // MARK: - Private Helpers
    private func emit() {
        state = products.isEmpty ? .empty : .data(products)
    }
}
