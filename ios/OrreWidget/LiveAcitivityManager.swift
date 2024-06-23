//
//  LiveAcitivityManager.swift
//  Runner
//
//  Created by 정민호 on 5/9/24.
//

import ActivityKit
import Flutter
import Foundation

class LiveActivityManager {

    // the data variable holds jsonData coming from flutter
    func startLiveActivity(data: [String: Any]?, result: FlutterResult) {

      let attributes = OrreWidgetAttributes()

      if let info = data as? [String: Any] {
        let state = OrreWidgetAttributes.ContentState(
          elapsedTime: info["elapsedTime"] as? Int ?? 0
        )

        // the request method here is responsible for invocation of dynamic island
        stopwatchActivity = try? Activity<OrreWidgetAttributes>.request(
          attributes: attributes, contentState: state, pushType: nil)
      } else {
        result(FlutterError(code: "418", message: "Live activity didn't invoked", details: nil))
      }
    }

    func updateLiveActivity(data: [String: Any]?, result: FlutterResult) {
      if let info = data as? [String: Any] {
        let updatedState = OrreWidgetAttributes.ContentState(
          elapsedTime: info["elapsedTime"] as? Int ?? 0
        )

        Task {
          /// the request method here is responsible for updating the data
          /// of the dynamic island
          await stopwatchActivity?.update(using: updatedState)
        }
      } else {
        result(FlutterError(code: "418", message: "Live activity didn't updated", details: nil))
      }
    }

    func stopLiveActivity(result: FlutterResult) {
      do {
        Task {
          // end method simply dismisses the dynamic island
          await stopwatchActivity?.end(using: nil, dismissalPolicy: .immediate)
        }
      } catch {
        result(FlutterError(code: "418", message: error.localizedDescription, details: nil))
      }
    }
}
