import Foundation

// MARK:  -  Price Format  -

/// Text for prices and changes. The same formatting is used on the list and detail screens.
enum PriceFormat {
    static func price(_ value: Decimal) -> String {
        value.formatted(.currency(code: "USD"))
    }

    static func change(_ value: Decimal) -> String {
        value.formatted(.number.precision(.fractionLength(2)).sign(strategy: .always()))
    }

    static func percent(_ value: Decimal) -> String {
        value.formatted(.number.precision(.fractionLength(2)).sign(strategy: .always())) + "%"
    }
}
