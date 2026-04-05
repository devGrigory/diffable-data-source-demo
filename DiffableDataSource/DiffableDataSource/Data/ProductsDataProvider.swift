//
//  ProductsDataProvider.swift
//  DiffableDataSource
//
//  Created by Grigory G. on 31.01.25.
//

protocol ProductsDataProviding {
    func fetchProducts() async throws -> [Product]
    func fetchRandomProduct() async throws -> Product
}

struct ProductsDataProvider: ProductsDataProviding, Sendable {
    
    func fetchProducts() async throws -> [Product] {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        
        let defaultProducts: [Product] = [
            Product(id: "1", title: "📱 iPhone"),
            Product(id: "2", title: "📲 iPad"),
            Product(id: "3", title: "💻 MacBook"),
            Product(id: "4", title: "🖥 iMac"),
            Product(id: "5", title: "⌚️ Apple Watch"),
            Product(id: "6", title: "🎧 AirPods"),
            Product(id: "7", title: "🔊 HomePod"),
            Product(id: "8", title: "🖱 Magic Mouse"),
            Product(id: "9", title: "⌨️ Magic Keyboard"),
            Product(id: "10", title: "📦 Apple TV")
        ]
        
        return Dictionary(
            defaultProducts.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        .map { $0.value }
        .sorted { $0.id < $1.id }
    }
    
    func fetchRandomProduct() async throws -> Product {
        let extraProducts: [Product] = [
            Product(id: "vision_pro", title: "🕶 Vision Pro"),
            Product(id: "airtag", title: "🏷 AirTag"),
            Product(id: "mac_studio", title: "🖥 Mac Studio"),
            Product(id: "studio_display", title: "🖼 Studio Display"),
            Product(id: "beats", title: "🎧 Beats")
        ]
        
        return extraProducts.randomElement() ?? extraProducts[0]
    }
    
}
