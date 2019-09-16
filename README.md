# AMAppRatingManager

Manage when and when to present to your users the Rating in App popup in order to increase the total rating of your App.

## Installation

In the source folder you will find the AMAppRatingManager.swift file. Just copy it in your project.

## Usage
In order to present the Rating Controller, the user must earn 100 *experience points*. A user can earn those points using your app. Just give a *point reward* to certain events:
```
AMAppRatingManager.addXPPoints(25)
```

Every time you add points in the app check if the user reached the 100 quota.
Create the **AZRatingPopupAskerModel** with *title*, *message*, *confirmation and dismission text* for the buttons and, optionally, the actions performed after the dismission of the popup. Ie: maybe tou need to track events on your Analitycs platform.
```
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
```

After that, just call the **presentStoreReviewController** function in the needed view controller:
```
AMAppRatingManager.presentStoreReviewController(with: permission, in: self)
```

Once the **presentStoreReviewController** is called, the XP points are resetted to 0 to avoit to annoy the user...

As you may know, Apple limits the presentation of the **SKStoreReviewController** to 3 times every 356 days (and it doesn't work on TestFlight), to every time you call  the **presentStoreReviewController** function, a boolean check is perfomed with the next conditions:
* the app version must be different from the version that presented the last popup
* 4 month must have passed since the last time the popup has been presented
* the user must have gained at least 100 XP points

As a debug purpose, I've added the **getLastTestedDate()** and the **getActualXPPoints()** functions.


## Example Project
An example ptoget is included in this repo. Just take a look at it.

## Author

* **Alessandro "DungeonDev78" Manilii**

## License

This project is licensed under the MIT License
