import Foundation
import Testing
@testable import StockCore

// MARK:  -  Symbol Catalog Tests  -

struct SymbolCatalogTests {
    @Test func catalogHasTwentyFiveUniqueSymbols() {
        #expect(SymbolCatalog.all.count == 25)
        #expect(Set(SymbolCatalog.all.map(\.symbol)).count == 25)
    }

    @Test func everyStockHasPositiveOpeningPrice() {
        #expect(SymbolCatalog.all.allSatisfy { $0.openingPrice > 0 })
    }
}
