//
//  Topic003.swift
//  SwiftUIWeeklyLayoutChallenge
//
//  Created by treastrain on 2022/07/27.
//

import SwiftUI

/// <doc:Topic003>
public struct Topic003View: View {
    public init() {}

    public var body: some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            #if os(macOS)
            DepartureSignal()
                .navigationTitle("出発信号機")
                .padding()
            #else
            if #available(watchOS 7.0, *) {
                NavigationView {
                    DepartureSignal()
                        .navigationTitle("出発信号機")
                }
            } else {
                DepartureSignal()
                    .navigationTitle("出発信号機")
            }
            #endif
        } else {
            Text("Support for this platform is not considered.")
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct DepartureSignal: View {
    @StateObject var viewModel = SignalViewModel()

    var body: some View {
        List {
            // 円形信号表示
            Section {
                VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        LightCircleImage<Light_1>(selectLight: $viewModel.light_1)
                        Spacer()
                    }
                    LightCircleImage<Light_2>(selectLight: $viewModel.light_2)
                    LightCircleImage<Light_3>(selectLight: $viewModel.light_3)
                    LightCircleImage<Light_4>(selectLight: $viewModel.light_4)
                }.padding([.top, .bottom], 15)
            }

            // テキスト信号表示
            Section {
                HStack {
                    Spacer()
                    Menu {
                        Picker(selection: $viewModel.selectedSignal) {
                            ForEach(Signal.allCases) {
                                signal in
                                Text(signal.rawValue)
                                    .tag(signal)
                                    .font(.title)
                                    .foregroundColor(.black)
                            }
                        } label: {}
                    } label: {
                        Text(viewModel.signal)
                            .font(.title)
                            .foregroundColor(.black)
                            .bold()
                            .fixedSize()
                    }
                    Spacer()
                }
            }
            
            // ライト選択表示
            Section {
                LightSelectCell<Light_1>(selectLight: $viewModel.light_1, allCases: Light_1.allCases)
                LightSelectCell<Light_2>(selectLight: $viewModel.light_2, allCases: Light_2.allCases)
                LightSelectCell<Light_3>(selectLight: $viewModel.light_3, allCases: Light_3.allCases)
                LightSelectCell<Light_4>(selectLight: $viewModel.light_4, allCases: Light_4.allCases)
            }
        }
    }

    var light: some View {
        Image(systemName: "circle.fill")
            .font(.largeTitle)
            .foregroundColor(.green)
    }
}

// 円形画像
struct LightCircleImage<S: SignalPickerPattern>: View {
    @Binding var selectLight: S

    var body: some View {
        Image(systemName: "circle.fill")
            .font(.largeTitle)
            .foregroundColor(selectLight.color)
    }
}

// ライト選択セル
struct LightSelectCell<S: SignalPickerPattern>: View {
    @Binding var selectLight: S
    var allCases: [S]

    var body: some View {
        HStack {
            Text(S.title)
            Spacer()
            Picker("", selection: $selectLight) {
                ForEach(allCases, id: \.id) {
                    lightColor in
                    Text(lightColor.text).tag(lightColor)
                }
            }.pickerStyle(.segmented).fixedSize()
        }
    }
}

// ライトピッカーパターンのプロトコル
protocol SignalPickerPattern: CaseIterable, Identifiable, Hashable {
    static var title: String { get }
    var text: String { get }
    var color: Color { get }
}

// 各ライトの選択パターン
enum Light_1: String, SignalPickerPattern {
    static var title: String { "灯1" }

    case yellowOn = "黄"
    case off = "消"

    var text: String { self.rawValue }
    var color: Color {
        switch self {
        case .yellowOn:
            return .yellow
        case .off:
            return .black
        }
    }

    var id: String { rawValue }
}

enum Light_2: String, SignalPickerPattern {
    static var title: String { "灯2" }

    case redOn = "赤"
    case off = "消"

    var text: String { self.rawValue }
    var color: Color {
        switch self {
        case .redOn:
            return .red
        case .off:
            return .black
        }
    }

    var id: String { rawValue }
}

enum Light_3: String, SignalPickerPattern {
    static var title: String { "灯3" }

    case greenOn = "緑"
    case off = "消"

    var text: String { self.rawValue }
    var color: Color {
        switch self {
        case .greenOn:
            return .green
        case .off:
            return .black
        }
    }

    var id: String { rawValue }
}

enum Light_4: String, SignalPickerPattern {
    static var title: String { "灯4" }

    case greenOn = "緑"
    case yellowOn = "黄"
    case off = "消"

    var text: String { self.rawValue }
    var color: Color {
        switch self {
        case .greenOn:
            return .green
        case .yellowOn:
            return .yellow
        case .off:
            return .black
        }
    }

    var id: String { rawValue }
}

// MARK: Model

// 信号パターン
enum Signal: String, CaseIterable, Identifiable {
    /// 上の灯火から順に 消・消・緑・消 で進行信号を現示。
    case 出発進行
    /// 上の灯火から順に 黄・消・消・緑 で減速信号を現示。
    case 出発減速
    /// 上の灯火から順に 消・消・消・黄 で注意信号を現示。
    case 出発注意
    /// 上の灯火から順に 黄・消・消・黄 で警戒信号を現示。
    case 出発警戒
    /// 上の灯火から順に 消・赤・消・消 で停止信号を現示。
    case 出発停止

    var id: String { rawValue }
}

// MARK: ViewModel

class SignalViewModel: ObservableObject {
    @Published var light_1: Light_1 = .off
    @Published var light_2: Light_2 = .off
    @Published var light_3: Light_3 = .off
    @Published var light_4: Light_4 = .off
    @Published var selectedSignal: Signal = .出発進行 {
        didSet {
            changeLight()
        }
    }

    var signal: String {
        switch (light_1, light_2, light_3, light_4) {
        case (.off, .off, .greenOn, .off):
            return Signal.出発進行.rawValue
        case (.yellowOn, .off, .off, .greenOn):
            return Signal.出発減速.rawValue
        case (.off, .off, .off, .yellowOn):
            return Signal.出発注意.rawValue
        case (.yellowOn, .off, .off, .yellowOn):
            return Signal.出発警戒.rawValue
        case (.off, .redOn, .off, .off):
            return Signal.出発警戒.rawValue
        default:
            return "--------"
        }
    }

    func changeLight() {
        switch selectedSignal {
        case .出発進行:
            (light_1, light_2, light_3, light_4) = (.off, .off, .greenOn, .off)
        case .出発減速:
            (light_1, light_2, light_3, light_4) = (.yellowOn, .off, .off, .greenOn)
        case .出発注意:
            (light_1, light_2, light_3, light_4) = (.off, .off, .off, .yellowOn)
        case .出発警戒:
            (light_1, light_2, light_3, light_4) = (.yellowOn, .off, .off, .yellowOn)
        case .出発停止:
            (light_1, light_2, light_3, light_4) = (.off, .redOn, .off, .off)
        }
    }
}

struct Topic003View_Previews: PreviewProvider {
    static var previews: some View {
        Topic003View()
    }
}
