//
//  ViewController.swift
//  AMRatingManagerExample
//
//  Created by Alessandro Manilii on 05/09/2019.
//  Copyright © 2019 Akhware. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblTotalPoints: UILabel!
    @IBOutlet weak var lblAppDetail: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLabel()
    }

    @IBAction func addPointsButtonPressed(_ sender: UIButton) {
        AMAppRatingManager.addSuccessPoints(sender.tag)
        checkRatingManager()
        updateLabel()
    }

}

private extension ViewController {

    func checkRatingManager() {
        let permission = AMAppRatingManager.AZRatingPopupAskerModel
            .init(title: "AMRatingManager",
                  message: "Want to give 5 stars to this amazing App?",
                  confirmText: "Hell yea!",
                  dismissText: "Mmmm... nope",
                  onDismiss: { (result) in
                    if result {
                        print("We rock!")
                    } else {
                        print("You suck!")
                    }
                    self.updateLabel()
        })
        
        AMAppRatingManager.presentStoreReviewController(with: permission, in: self)
    }

    func updateLabel() {
        var details = ""

        if AMAppRatingManager.getLastTestedDate() < Date() &&
            AMAppRatingManager.getLastTestedDate() != Foundation.Date.distantPast {
            details += "\nRating managed showed on \(AMAppRatingManager.getLastTestedDate())\nApp version: \(AMAppRatingManager.getLastTestedAppVersion())"
        }

        lblTotalPoints.text = "Total points: \(AMAppRatingManager.getActualPoints())"
        lblAppDetail.text = details
    }
}

