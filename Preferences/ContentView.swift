//
//  ContentView.swift
//  Preferences
//
//  Created by Joshua Homann on 3/7/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI

struct Squares: Equatable {
  var id: Int
  var rect: CGRect
}

struct SquarePreferenceKey: PreferenceKey {
  static var defaultValue: [Squares] = []

  static func reduce(value: inout [Squares], nextValue: () -> [Squares]) {
    value = value + nextValue()
  }
}

struct ContentView: View {
  @State var squares: [Squares] = []
  @State var highlighted: Set<Int> = []
  private enum Constant {
    static let spacing: CGFloat = 4
    static let gridCount = 8
  }
  private enum Space: Int {
    case stack
  }
  var body: some View {
    GeometryReader { outer in
      VStack(spacing: Constant.spacing) {
        ForEach (0..<Constant.gridCount) { y in
          HStack(spacing: Constant.spacing) {
            ForEach (0..<Constant.gridCount) { x in
              GeometryReader { geometry in
                Rectangle()
                  .fill( self.color(x: x, y: y))
                  .animation(.linear)
                  .cornerRadius(Constant.spacing)
                  .preference(
                    key: SquarePreferenceKey.self,
                    value: [.init(
                      id: x + y * Constant.gridCount,
                      rect: geometry.frame(in: CoordinateSpace.named(Space.stack))
                      )
                    ]
                )
              }
            }
          }
        }
      }
      .frame(width: min(outer.size.width, outer.size.height), height: min(outer.size.width, outer.size.height))
    }
    .coordinateSpace(name: Space.stack)
    .onPreferenceChange(SquarePreferenceKey.self) { squares in
      self.squares = squares
    }
    .gesture(DragGesture()
    .onChanged { value in
      let point = value.location
      if let square = self.squares.first(where: { $0.rect.contains(point)}) {
        self.highlighted.insert(square.id)
      }
    }.onEnded { value in
      self.highlighted = []
      }
    )
  }

  func color(x: Int, y: Int) -> Color {
    if self.highlighted.contains(where: { $0 == x + y * Constant.gridCount }) {
      return Color.yellow
    }
    return (x + y).isMultiple(of: 2) ? Color.green : Color.blue
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
