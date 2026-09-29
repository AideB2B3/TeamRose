*During my time as a supervisor and manager at the Apple Developer Academy, I led Team Rose through the Foundation program and supervised the project from start to finish. Everything in this repository was designed and built by the members of Team Rose.*

# Fixo

> An iOS app that guides users from diagnosing a faulty device to booking a repair at a service center.

![Swift](https://img.shields.io/badge/Swift-5-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0D96F6?logo=swift&logoColor=white)
![Platform](https://img.shields.io/badge/iOS-26.2%2B-000000?logo=apple&logoColor=white)
![Backend](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white)

## Overview

People with a broken device often don't know what the fault is or who to turn to. Fixo tackles both problems in a single app with two profiles: the **customer**, who runs a guided diagnosis, finds compatible repair shops and books a repair; and the **repair shop**, which publishes its services with prices, manages incoming orders and reads reviews.

The project was built by the members of Team Rose as part of the Foundation program at the Apple Developer Academy, under the supervision of Davide Bellobuono. It is a working demo: some parts (payments, shipping, some hardware tests) are simulated, as detailed below.

## Key Features

**Customer side**
- **Guided device selection** (type → brand → model) with data loaded from Supabase; in the current version only the Apple brand can be selected.
- **Hardware diagnostics** (for smartphones) with 8 tests: touch, camera, audio, dead pixels, battery, buttons, haptic feedback, flashlight. From the failed tests, the app infers the type of repair needed.
- **Repair shop search** with three-tier logic: exact match (model + problem), partial match (brand + problem), then recommendations among top-rated shops. Results are shown as a list and on a map (MapKit).
- **"Mail-in" service**: shipping form, booking saved to Supabase, confirmation and shipping label.
- **Google Sign-In accounts**, order history in the profile and reviews for shops.

**Repair shop side**
- Google sign-in and initial profile setup (address, phone, opening hours).
- **Dashboard** tracking orders by status (Pending, In Progress, Waiting Parts, Ready, Completed) and showing recent reviews.
- **Service management**: create and remove services per device/problem, with price.

### Simulated Parts (demo)

For transparency, the following are simulated in the code: card tokenization and charging (`PaymentService.swift`, no Stripe SDK), shipment and tracking code creation (`ShippingManager.swift`, no EasyPost calls), the battery test (fixed value), the camera test preview, the microphone test (random animated bars) and card scanning. The Apple Pay button uses PassKit with a test merchant ID.

## Tech Stack

| Area | Technology |
| --- | --- |
| Language | Swift 5 |
| UI | SwiftUI (`NavigationStack` with `NavigationPath`, `TabView`, `Canvas`) |
| Architecture | MVVM (`ObservableObject` / `@Observable`) with singleton managers (`AuthManager`, `SupabaseManager`) |
| Backend | [Supabase](https://github.com/supabase/supabase-swift) (Auth and PostgreSQL database) |
| Authentication | Google Sign-In (`GoogleSignIn-iOS`) with token exchange to Supabase |
| Apple frameworks | MapKit, AVFoundation, PassKit, MessageUI, VisionKit |
| Dependencies | Swift Package Manager |
| Target | iOS 26.2+, iPhone and iPad |

## Installation and Usage

**Requirements:** macOS with an Xcode version that supports iOS 26.2 and an Internet connection (Swift packages and Supabase backend).

```bash
git clone https://github.com/AideB2B3/TeamRose.git
cd TeamRose
open Diagnose.xcodeproj
```

1. Wait for Xcode to automatically resolve the Swift Package Manager dependencies (Supabase, GoogleSignIn).
2. Select the **Diagnose** scheme and a simulator or device running iOS 26.2+.
3. Press `Cmd + R`.

**Backend configuration (for your own environment).** The connection credentials are defined in `Diagnose/Models/SupabaseManager.swift` (`supabaseURL`, `supabaseKey`, `googleClientID`), and the Google client ID also appears in `Diagnose/Info.plist`. To use your own project:

1. Create a Supabase project and enable the Google provider under *Authentication*.
2. Create the tables used by the app: `shops`, `customers`, `devices`, `problems`, `shop_services`, `bookings`, `reviews`. The `setup_database.sql` script only adds the missing columns to the `shops` table (`address`, `phone_number`, `business_hours`, `latitude`, `longitude`, `verified`); the full schema is not included in the repository.
3. Replace the URL, public key and Google client ID in `SupabaseManager.swift` and `Info.plist`, also updating the Google Sign-In URL scheme.

## Project Structure

```text
TeamRose/
├── Diagnose.xcodeproj             # Main project (Fixo app)
├── Diagnose/
│   ├── DiagnoseApp.swift          # Entry point + Google Sign-In URL handling
│   ├── RoleSelectionRootView.swift# Routing between customer / repair shop
│   ├── ContentView.swift          # Customer flow: device selection, tests, shop search
│   ├── Models/                    # AuthManager, SupabaseManager, data models
│   ├── ViewModels/                # Customer orders, shipping, shops
│   ├── Views/                     # Login, profile, reviews, Mail-in, onboarding
│   ├── Services/                  # Payments (simulated) and Apple Pay
│   ├── Components/                # Theme and reusable UI components
│   └── ShopDashboard/             # Repair shop dashboard (Models, ViewModels, Views, Components)
├── Fixo.xcodeproj / Fixo/         # Placeholder target
├── setup_database.sql             # Column migration for the shops table
├── *.rb                           # Utility scripts for the Xcode project
├── FIXO KEYNOTE.pdf               # Project presentation
└── poster.jpeg
```

## Future Improvements

- Truly integrate Stripe/Apple Pay with a payment backend, and EasyPost for labels and tracking.
- Replace the simulations with real measurements (for example camera and microphone with AVFoundation).
- Extend the catalog beyond Apple and the diagnostics to other device types.
- Move credentials out of the source code (`.xcconfig` configuration files) and version the database schema with Row Level Security.
- Add automated tests and real-time order updates (not present in the current code).

## Author and Contacts

- **Team:** Team Rose, Apple Developer Academy (Foundation)
- **Development:** Team Rose members
- **Supervision and management:** Davide Bellobuono
- **LinkedIn:** _to be added_
- **GitHub:** https://github.com/AideB2B3/TeamRose
- **Email:** _to be added_

## License

The code is released under the MIT License (see the `LICENSE` file).
