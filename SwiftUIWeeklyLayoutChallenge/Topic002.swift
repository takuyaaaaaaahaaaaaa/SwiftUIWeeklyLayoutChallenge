//
//  Topic002View.swift
//  SwiftUIWeeklyLayoutChallenge
//
//  Created by treastrain on 2022/07/20.
//

import SwiftUI

// MARK: - Entities
private struct Vital: Identifiable {
    let id = UUID()
    let title: LocalizedStringKey
    let value: Value
    let date: Date
    let iconSystemName: String
    let color: Color

    enum Value {
        case number(value: Double, style: NumberFormatter.Style, customUnit: String? = nil)
        case dateComponents(_ dateComponents: DateComponents)
        case measurement(value: Double, unit: Dimension, formattedUnit: Dimension? = nil)
    }
}

extension Vital.Value {
    @ViewBuilder
    var valueView: some View {
        switch self {
        case .number(let value, let style, let customUnit):
            HStack {
                if let customUnit {
                    Text(String(Int(value))).valueModifier()
                    Text(customUnit).unitModifier()
                } else if style == .percent {
                    Text(String(Int(value * 100))).valueModifier()
                    Text("%").unitModifier()
                } else {
                    Text(String(Int(value))).valueModifier()
                }
                Spacer()
            }
        case .dateComponents(let dateComponents):
            HStack {
                if let minute = dateComponents.minute {
                    if let hour = minute / 60, hour >= 1 {
                        Text("\(hour)").valueModifier()
                        Text("時間").unitModifier()
                    }
                    Text("\(minute % 60)").valueModifier()
                    Text("分").unitModifier()
                } else {
                    Text("記録なし")
                }
                Spacer()
            }
        case .measurement(value: let value, unit: let unit, formattedUnit: _):
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(String(format: "%.1f", value))
                    .valueModifier()
                switch unit as! UnitTemperature {
                case .celsius:
                    Text("℃")
                        .unitModifier()
                default:
                    Text("")
                }
                Spacer()
            }
        }
    }
}

// MARK: - Sample Data
private let vitalData: [Vital] = [
    .init(title: "取り込まれた酸素のレベル", value: .number(value: 0.99, style: .percent), date: Date(timeIntervalSinceNow: -300), iconSystemName: "o.circle.fill", color: .blue),
    .init(title: "心拍数", value: .number(value: 61, style: .decimal, customUnit: "拍/分"), date: Date(timeIntervalSinceNow: -5400), iconSystemName: "heart.fill", color: .red),
    .init(title: "睡眠", value: .dateComponents(.init(minute: 451)), date: Date(timeIntervalSinceNow: -87000), iconSystemName: "bed.double.fill", color: .green),
    .init(title: "体温", value: .measurement(value: 36.4, unit: UnitTemperature.celsius), date: Date(timeIntervalSinceNow: -172800), iconSystemName: "thermometer", color: .red),
]

/// お題 002
@available(tvOS 14.0, *)
@available(iOS 14.0, *)
@available(watchOS 7.0, *)
public struct Topic002View: View {
    public init() {}

    public var body: some View {
        NavigationView {
            List(vitalData) { vital in
                    VStack(spacing: 12.0) {
                        NavigationLink(destination: {}) {
                            HStack {
                                Group {
                                    Image(systemName: vital.iconSystemName)
                                    Text(vital.title)
                                }
                                .font(.headline)
                                .foregroundColor(vital.color)
                                Spacer()
                                Text(vital.date.agoText)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        HStack {
                            Spacer()
                        }
                        vital.value.valueView
                    }
            }.navigationTitle("バイタルデータ")
            #if os(tvOS)
                .listStyle(GroupedListStyle())
            #endif
        }
    }
}

// MARK: - Date formatter
extension Date {
    var text: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd(E)"
        return dateFormatter.string(from: self)
    }

    var agoText: String {
        let now = Date()
        let (earliest, latest) = self < now ? (self, now) : (now, self)
        let components = Calendar.current.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second],
                                                         from: earliest, to: latest)
        if let year = components.year, year > 0 {
            return self.text
        }
        if let month = components.month, month > 0 {
            return self.text
        }
        if let weekOfYear = components.weekOfYear, weekOfYear > 0 {
            return self.text
        }
        if let day = components.day, day > 0 {
            switch day {
            case 1: return "昨日"
            case 2: return "一昨日"
            default: return "\(day)日前"
            }
        }
        if let hour = components.hour, hour > 0 {
            return "\(hour)時間前"
        }
        if let minute = components.minute, minute > 0 {
            return "\(minute)分前"
        }
        if let second = components.second, second > 0 {
            return "\(second)秒前"
        }
        return "たった今"
    }
}

// 値のModifier
struct ValueModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title.monospacedDigit())
    }
}

// 単位のModifier
struct UnitModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.gray)
    }
}

// カスタムModifierの設定
extension View {
    func valueModifier() -> some View {
        self.modifier(ValueModifier())
    }

    func unitModifier() -> some View {
        self.modifier(UnitModifier())
    }
}

@available(tvOS 14.0, *)
@available(iOS 14.0, *)
@available(watchOS 7.0, *)
struct Topic002View_Previews: PreviewProvider {
    static var previews: some View {
        Topic002View()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
        Topic002View()
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 45mm"))
        Topic002View()
            .previewDevice(PreviewDevice(rawValue: "Apple TV 4K"))
    }
}

