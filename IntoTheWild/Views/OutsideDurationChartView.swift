//  Created by Dominik Hauser on 19.06.22.
//  Copyright © 2022 dasdom. All rights reserved.
//

import SwiftUI
import Charts

struct OutsideDurationChartView: View {

  @EnvironmentObject private var locationProvider: LocationProvider
  @State private var selectedTimeFrame = 0
  @State private var selectedElement: DayEntry? = nil

  var body: some View {
    VStack(alignment: .leading) {
      Picker("Time Frame", selection: $selectedTimeFrame) {
        Text("7 days").tag(0)
        Text("30 days").tag(1)
      }
      .pickerStyle(.segmented)

      VStack(alignment: .leading) {
        VStack(alignment: .leading) {
          Text("Total time spend away from home")
            .font(.callout)
            .foregroundStyle(.secondary)
          Text("\(locationProvider.last28DaysTotal, format: .time(pattern: .hourMinute)) hours")
            .font(.title2.bold())
        }
        .opacity(selectedElement == nil ? 1 : 0)

        DurationChart(selectedElement: $selectedElement)
      }
      .chartBackground { proxy in
        LollipopView(selectedElement: selectedElement, proxy: proxy)
      }
    }
    .padding()
    .onChange(of: selectedTimeFrame) { newValue in
      switch newValue {
        case 0:
          locationProvider.numberOfDays = 7
        case 1:
          locationProvider.numberOfDays = 30
        default:
          locationProvider.numberOfDays = 7
      }
    }
  }
}

struct LollipopView: View {

  var selectedElement: DayEntry? = nil
  var proxy: ChartProxy
  @Environment(\.layoutDirection) var layoutDirection

  var body: some View {
    ZStack(alignment: .topLeading) {
      GeometryReader { nthGeoItem in
        if let selectedElement = selectedElement {
          let dateInterval = Calendar.current.dateInterval(of: .day, for: selectedElement.weekday)!
          let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0
          let startPositionX2 = proxy.position(forX: dateInterval.end) ?? 0
          let midStartPositionX = (startPositionX1 + startPositionX2) / 2 + nthGeoItem[proxy.plotAreaFrame].origin.x

          let lineX = layoutDirection == .rightToLeft ? nthGeoItem.size.width - midStartPositionX : midStartPositionX
          let lineHeight = nthGeoItem[proxy.plotAreaFrame].maxY
          let boxWidth: CGFloat = 150
          let boxOffset = max(0, min(nthGeoItem.size.width - boxWidth, lineX - boxWidth / 2))

          Rectangle()
            .fill(.quaternary)
            .frame(width: 2, height: lineHeight)
            .position(x: lineX, y: lineHeight / 2)

          VStack(alignment: .leading) {
            Text("\(selectedElement.weekday, format: .dateTime.year().month().day())")
              .font(.callout)
              .foregroundStyle(.secondary)
            Text("\(Duration.seconds(selectedElement.duration), format: .time(pattern: .hourMinute)) hours")
              .font(.title2.bold())
              .foregroundColor(.primary)
          }
          .frame(width: boxWidth, alignment: .leading)
          .background {
            ZStack {
              RoundedRectangle(cornerRadius: 8)
                .fill(.background)
              RoundedRectangle(cornerRadius: 8)
                .fill(.quaternary.opacity(0.7))
            }
            .padding([.leading, .trailing], -8)
            .padding([.top, .bottom], -4)
          }
          .offset(x: boxOffset)
        }
      }
    }
  }
}