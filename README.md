# stillwaitin-app
The still waitin app source code - active in the App Store from 2010-2020.

![logo](logo.jpg)

## App Description:

Keep track of your cash financials. Never forget about money that you lent to or got from friends, family, colleagues or customers. No matter the amount. Get a push reminder at the day & time of your choice or send out a formatted email about open debts to your contacts, so they don't forget either.

See [screenhots](#screenshots) below.

## Background

This app was originally written for iOS3. That's before GCD & ARC was available, which were released for iOS4 & iOS5 respectively. That's also before the first Retina display of the iPhone 4 or much newer iOS features like Dark Mode or the Dynamic Island. Let alone Swift or SwiftUI.

[@martinstolz](https://github.com/martinstolz) and me wrote it together as a side project to learn iOS development in 2010. We maintained and updated it for 10 years until we finally took it out of the AppStore in 2020.

> Disclaimer: Don't think of the code here as an exemplary app architecture, but instead as a small window into the history of iOS development.

## Source code

This repository contains the source code of two original versions of the app; from 2020 and 2012. Both still compile and run on today's Xcode 15 (as of 2024).

- [`HIGHLIGHTS.md`](HIGHLIGHTS.md) lists some highlights in the source code and the choices we made, while making the App.
- [`CHANGELOG.md`](CHANGELOG.md) shows a full list of changes between these two versions.

### Version 2.4 (from 2020) - [`/2020_v2.4/`](https://github.com/calimarkus/stillwaitin-app/tree/main/2020_v2.4)

The most recently released version. A fairly modern iOS app; at least in comparison to below version 1.5.

- It has an iOS 7 redesign, iPhone X support, dark mode and many additional features.
- Persistence is handled by a `Realm` database.
- LOC`*`: roughly ~9000 lines; notably not that much more than v1.5, even though it has many more features.
- Open source dependencies:
    - `ZoomInteractiveTransition` from https://github.com/DenTelezhkin/ZoomInteractiveTransition


### Version 1.5 (from 2012) - [`/2012_v1.5/`](https://github.com/calimarkus/stillwaitin-app/tree/main/2012_v1.5)

Pretty close to the original version from 2010. This is quite historic.

- This version still uses manual reference counting; e.g. see the 177 manual `retain`/`release` calls.
- Contains `@2x` assets - the iPhone 4 came out on `06/2010`.
- The persistence is simply based on `NSUserDefaults`.
- LOC`*`: roughly ~7500 lines.
- Open source dependencies:
    - `DDAnnotationView` from https://github.com/digdog/
    - `UIColor+ColorWithHex` from https://github.com/pixeldock/PDUtils
    - `UIView+position` from https://github.com/tylerneylon/moriarty


`*` LOC measured in the `/Classes` directory by calling: `find . -name '*.m' | xargs wc -l | sort` minus any externally pulled in dependencies.

## Screenshots

![Screenshot](app_screenshots/list.jpg)


| Data entry screen  | Entry details screen |
| ------------- | ------------- |
| ![Screenshot](app_screenshots/entry.jpg)  | ![Screenshot](app_screenshots/details.jpg)  |
