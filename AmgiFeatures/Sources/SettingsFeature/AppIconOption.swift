//
//  AppIconOption.swift
//  SettingsFeature
//

#if os(iOS)
enum AppIconOption: CaseIterable, Identifiable {
    case standard, handwritten, deepTeal, midnight, celadon, persimmon
    case dojangHanzi, handwrittenHanzi, deepTealHanzi, midnightHanzi, celadonHanzi, persimmonHanzi

    var id: Self { self }

    var alternateName: String? {
        self == .standard ? nil : previewName
    }

    var previewName: String {
        switch self {
        case .standard: "Dojang"
        case .handwritten: "Handwritten"
        case .deepTeal: "DeepTeal"
        case .midnight: "Midnight"
        case .celadon: "Celadon"
        case .persimmon: "Persimmon"
        case .dojangHanzi: "DojangHanzi"
        case .handwrittenHanzi: "HandwrittenHanzi"
        case .deepTealHanzi: "DeepTealHanzi"
        case .midnightHanzi: "MidnightHanzi"
        case .celadonHanzi: "CeladonHanzi"
        case .persimmonHanzi: "PersimmonHanzi"
        }
    }

    var displayName: String {
        switch self {
        case .standard: "Dojang"
        case .handwritten: "Handwritten"
        case .deepTeal: "Deep Teal"
        case .midnight: "Midnight"
        case .celadon: "Celadon"
        case .persimmon: "Persimmon"
        case .dojangHanzi: "Red Seal"
        case .handwrittenHanzi: "Ink"
        case .deepTealHanzi: "Lagoon"
        case .midnightHanzi: "Night Gold"
        case .celadonHanzi: "Jade"
        case .persimmonHanzi: "Ember"
        }
    }

    init(alternateName: String?) {
        self = Self.allCases.first { $0.alternateName == alternateName } ?? .standard
    }
}
#endif
