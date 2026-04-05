//
//  Product.swift
//  DiffableDataSource
//
//  Created by Grigory G. on 31.01.25.
//

// MARK: - Models

// MARK: Sections
nonisolated enum ProductsSection: Hashable, Sendable {
    case main
    case placeholder
}

// MARK: Items
nonisolated struct ProductsItem: Hashable, Sendable {
    let id: String
    let title: String
}

// MARK: State
enum State: Sendable {
    case loading
    case data([Product])
    case empty
}

// MARK: Domain Model
struct Product: Hashable, Sendable {
    let id: String
    let title: String
}
