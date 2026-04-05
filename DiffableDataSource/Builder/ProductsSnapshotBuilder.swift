//
//  ProductsSnapshotBuilder.swift
//  DiffableDataSource
//
//  Created by Grigory G. on 31.01.25.
//

import UIKit

struct ProductsSnapshotBuilder {
    typealias Snapshot = NSDiffableDataSourceSnapshot<ProductsSection, ProductsItem>

    static func build(state: State) -> Snapshot {
        var snapshot = Snapshot()

        switch state {

        case .loading:
            snapshot.appendSections([.placeholder])
            snapshot.appendItems([
                ProductsItem(id: "loading", title: "Loading...")
            ])

        case .empty:
            snapshot.appendSections([.placeholder])
            snapshot.appendItems([
                ProductsItem(id: "empty", title: "No products")
            ])

        case .data(let products):
            snapshot.appendSections([.main])
            let items = products.map {
                ProductsItem(id: $0.id, title: $0.title)
            }
            snapshot.appendItems(items, toSection: .main)
        }

        return snapshot
    }
}
