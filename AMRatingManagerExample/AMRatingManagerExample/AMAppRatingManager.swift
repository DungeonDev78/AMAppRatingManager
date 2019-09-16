//
//  AZAppRatingManager.swift
//
//  Created with 💪 by Alessandro Manilii.
//  Copyright © 2019 Alessandro Manilii. All rights reserved.
//

import Foundation
import StoreKit

final class AMAppRatingManager {

    /// A model that describes the texts for question, confimation and abort actions
    struct AZRatingPopupAskerModel {
        let title: String
        let message: String
        let confirmText: String
        let dismissText: String
        let onDismiss: ((Bool) -> Void)?     // Closure needed to track the accept/dismiss action
    }

    // MARK: - Properties
    fileprivate struct AZAppRatingConstants {
        static let LastDateCheckedKey           = "LastDateCheckedKey"
        static let TestedAppVersionKey          = "TestedAppVersionKey"
        static let ActualXPPointsKey            = "ActualXPPointsKey"
        static let ShouldShowRatingManagerKey   = "ShouldShowRatingManagerKey"
    }

    static fileprivate let defaults = UserDefaults.standard
    static fileprivate let minimumXPPointsNeeded = 100       // Example: 100
    static fileprivate let minimumMonths = 4               // Set to 4 in order to show the panel max 3 times per year
    // FIXME: SET TO FALSE IN PRODUCION!!!
    static fileprivate let isTest = false                  // SET TO FALSE IN PRODUCTION!!!

    /// Show the raintg in app only if user confirms the given message AND the version number is different from the version that showed last time the rating AND if at least passed 4 months since the last time. Apple allows you to show the Rating in App only 3 times every 365 days. The 5 stars popup request is optional.
    ///
    /// **Example code**:
    ///
    ///     let permission = AMAppRatingManager.AZRatingPopupAskerModel.init(title: "My Cool App",
    ///                                                                      message: "Want to give 5 Stars?",
    ///                                                                      confirmText: "Yes",
    ///                                                                      dismissText: "No") { (allowed) in
    ///
    ///     if allowed == true {
    ///         print("*** 5 STARS GIVEN ***")
    ///     } else {
    ///         print("*** NO STARS GIVEN ***") }
    ///     }
    ///
    ///     AMAppRatingManager.presentStoreReviewController(with: permission, in: self)
    /// - Parameters:
    ///   - permission: a model with the texts for question, confimation and abort actions.
    ///   - viewController: the presenter ViewController

    static func presentStoreReviewController(with permission: AZRatingPopupAskerModel? = nil, in viewController: UIViewController) {
        guard shouldShow() else { return }
        guard let gPermission = permission else {
            showStoreReviewController(in: viewController)
            return
        }

        let alert = UIAlertController.init(title: gPermission.title, message: gPermission.message, preferredStyle: .alert)
        let confirmAction = UIAlertAction.init(title: gPermission.confirmText, style: .default) { _ in
            showStoreReviewController(in: viewController)
            if let onDismiss = gPermission.onDismiss { onDismiss(true) }
        }

        let dismissAction = UIAlertAction.init(title: gPermission.dismissText, style: .default) { _ in
             updateNewStatus()
            if let onDismiss = gPermission.onDismiss { onDismiss(false) }
        }

        alert.addAction(confirmAction)
        alert.addAction(dismissAction)
        viewController.present(alert, animated: true)
    }

    /// Add the numbers of "experience points". It's needed in order to test if the Rating should be presented or not.
    static func addXPPoints(_ points:Int) {
        let successes = getActualXPPoints()
        setActualXPPoints(successes + points)
    }

    // MARK: - "Remote" activation
    /// Update the saved value if the App should show the Rating Panel somewhere else: an event in the ViewController A decide to show the rating in ViewController B... maybe in another section of the app.
    ///
    /// - Parameter shouldShow: the needed bool
    static func updateShouldShowRatingManager(shouldShow: Bool) {
        UserDefaults.standard.set(shouldShow, forKey: AZAppRatingConstants.ShouldShowRatingManagerKey)
    }

    /// Test if it's needed to show the Rating Panel somewhere in the App
    ///
    /// - Returns: the result of the test
    static func shouldShowRatingManager() -> Bool {
        return UserDefaults.standard.bool(forKey: AZAppRatingConstants.ShouldShowRatingManagerKey)
    }
}

// MARK: - Main method
private extension AMAppRatingManager {

    /// Check all the conditions that permit to show the Rating Controller or the advice popup
    ///
    /// - Returns: the bool result of the test
    static func shouldShow() -> Bool {
        if !isTest {
            // Check if the actual App version number is different from the last tested version
            guard getLastTestedAppVersion() != Bundle.main.appCurrentVersion else { return false }

            // Check if the actual xp points are equal or bigger than what needed
            guard getActualXPPoints() >= minimumXPPointsNeeded else { return false }

            let now = Foundation.Date()
            let calendar = Calendar.current
            let componentSet: Set = [Calendar.Component.month]
            let components = calendar.dateComponents(componentSet, from: getLastTestedDate(), to: now)

            // Check if 4 month passed since the last shown popup
            if let months = components.month, months > minimumMonths {
                return true
            } else {
                return false
            }
        }
        return true
    }

    /// Show the raintg in app only if version number is different from the version that showed last time the rating AND if at least passed 4 months since the last time. Apple allows you to show the Rating in App only 3 times every 365 days.
    ///
    /// - Parameter viewController: the presenter ViewController
    static func showStoreReviewController(in viewController: UIViewController) {
        if shouldShow() {
            if #available( iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                updateNewStatus()
            }
        }
    }
}

// MARK: - Update
private extension AMAppRatingManager {

    /// Save the new values after the popup has been presented
    static func updateNewStatus() {
        setTodayAsLatestTestedDate()
        setCurrentVersionNumberAsLastTested()
        setActualXPPoints(0)
    }
}

// MARK: - Test App Version Handling
extension AMAppRatingManager {

    /// Save the app version number of the latest check
    private static func setCurrentVersionNumberAsLastTested() {
        defaults.set(Bundle.main.appCurrentVersion, forKey: AZAppRatingConstants.TestedAppVersionKey)
    }

    /// Get the app version used in the latest test
    ///
    /// - Returns: a string with the version number
    static func getLastTestedAppVersion() -> String {
        return defaults.string(forKey: AZAppRatingConstants.TestedAppVersionKey) ?? "0.0.0.0"
    }
}

// MARK: - Test Date Handling
extension AMAppRatingManager {

    /// Save now as latest date used for a test.
    private static func setTodayAsLatestTestedDate() {
        defaults.set(Foundation.Date(), forKey: AZAppRatingConstants.LastDateCheckedKey)
    }

    ///  Get the date used in the latest app-version test.
    ///
    /// - Returns: a Foundation.Date that describes the needed date.
    static func getLastTestedDate() -> Foundation.Date {
        let distantPast = Foundation.Date.distantPast
        return defaults.object(forKey: AZAppRatingConstants.LastDateCheckedKey) as? Foundation.Date ?? distantPast
    }
}

// MARK: - Success Occurrences Handling
extension AMAppRatingManager {

    /// Save the number of success occurrences of the control event needed to show the popup.
    ///
    /// - Parameter value: the Int to set
    private static func setActualXPPoints(_ value: Int) {
        defaults.set(value, forKey: AZAppRatingConstants.ActualXPPointsKey)
    }

    /// Get the earned xp points.
    ///
    /// - Returns: the actual xp points as Int
    static func getActualXPPoints() -> Int {
        return defaults.integer(forKey: AZAppRatingConstants.ActualXPPointsKey)
    }
}

// MARK: - Bundle Extension
extension Bundle {

    /// Current version of the App
    var appCurrentVersion: String {
        let appVersion = self.infoDictionary?["CFBundleShortVersionString"] ?? ""
        let buildNumber = self.infoDictionary?["CFBundleVersion"] ?? ""
        return  "\(appVersion).\(buildNumber)"
    }
}
