//
//  Topic007.swift
//  SwiftUIWeeklyLayoutChallenge
//
//  Created by treastrain on 2022/08/31.
//

import SwiftUI

/// <doc:Topic007>
public struct Topic007View: View {
    public init() {}
    
    public var body: some View {
        #if os(iOS)
        if #available(iOS 15.0, *) {
            Topic007ContentView()
        } else {
            Text("Support for this platform is not considered.")
        }
        #else
        Text("Support for this platform is not considered.")
        #endif
    }
}

#if os(iOS)
@available(iOS 15.0, *)
fileprivate struct Topic007ContentView: View {
    @State var text:[String] = []
    let columns = [GridItem(),GridItem(),GridItem()]
    @State var showPopover = false
    var body: some View {
        VStack(spacing:10) {
            Text(text.joined()).textSelection(.enabled).font(.largeTitle)
            LazyVGrid (columns:columns,spacing: 20){
                ForEach(Numbers.allCases){ number in
                    CircleButton(content: {number.view}, action: {
                        text.append(number.rawValue)
                    })
                }
                CircleButton(content:{}, action: {}).hidden()
                CircleButton(content:{
                    Image(systemName: "phone")
                }, action: {})
                CircleButton(content:{Image.delete_left.foregroundColor(.black)}, action: {
                    if text.isEmpty {
                        return
                    }
                    text.removeLast()
                })
            }.padding(20)
        }
    }
}
#endif

extension Color {
    static let text = Color("Topic007TextColor")
    static let background = Color("Topic007ButtonBackgroundColor")
}

extension Image {
    static let delete_left = Image("Topic007ButtonDeleteLeft")
}


@available(iOS 15.0, *)
struct CircleButton<T:View>:View {
    @ViewBuilder var content: () -> T
    var action: ()->Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            ZStack{
                Circle().foregroundColor(.background)
                VStack {
                    content().foregroundColor(.text)
                }
            }.frame(width: 80, height: 80, alignment: .center)
        })
    }
}

enum Numbers:String, CaseIterable,Identifiable {
    var id : String {self.rawValue}
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case asterisk = "*"
    case zero = "0"
    case sharp = "#"
    var character:String? {
        switch self {
        case .one:
            return ""
        case .two:
            return "ABC"
        case .three:
            return "DEF"
        case .four:
            return "GHI"
        case .five:
            return "JKL"
        case .six:
            return "MNO"
        case .seven:
            return "PQRS"
        case .eight:
            return "TUV"
        case .nine:
            return "WXYZ"
        case .asterisk,.sharp:
            return nil
        case .zero:
            return "+"
        }
    }
    
    @ViewBuilder var view: some View {
        switch self {
        default:
            Group{
                Text(self.rawValue).font(.title)
                if let characters = self.character {
                    Text(characters).font(.caption)
                }
            }
        }
    }
    
}


@available(iOS 15.0, *)
struct Topic007View_Previews: PreviewProvider {
    static var previews: some View {
        //Topic007View()
        Group {
            Topic007ContentView()
            Topic007ContentView().preferredColorScheme(.dark)
        }
    }
}
