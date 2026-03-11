# TeamRose
# Fixo – Intelligent Tech Repairs 📱🛠️
**Fixo** is a premium iOS application designed to bridge the gap between users with broken devices and expert repair shops. It combines high-end hardware diagnostics with a seamless repair booking marketplace.
---
## 🌟 Key Features
### 🔍 Intelligent Diagnostics
*   **Hardware Check**: Run a suite of 8+ automated tests (Touch, Camera, Audio, Dead Pixels, Battery, Buttons, Haptics, Flashlight) to pinpoint the exact issue.
*   **Automatic Match**: The app automatically detects the fault and suggests the specific repair type needed.
### 🏪 Repair Marketplace
*   **Smart Matching**: Find shops specifically listed as experts for your exact device model and problem.
*   **Real-time Pricing**: Get instant quotes from nearby or specialized mail-in shops.
*   **Verified Shops**: Badges for verified, high-quality service providers.
### 📦 Seamless Booking
*   **Direct & Mail-in**: Choose between visiting a shop in person or using a simulated "Mail-in" service for maximum convenience.
*   **Order Tracking**: Real-time status updates from "Pending" to "Ready for Pickup."
### ⭐ Review System
*   **Customer Feedback**: Leave ratings and comments for completed repairs.
*   **Dashboard Integration**: Shop owners receive instant feedback to maintain high service standards.
---
## 🛠️ Technology Stack
*   **Frontend**: Native iOS development using **SwiftUI**.
*   **Backend**: **Supabase** (PostgreSQL, Realtime, and Authentication).
*   **Architecture**: MVVM (Model-View-ViewModel) for clean, maintainable code.
*   **Navigation**: Advanced `NavigationPath` for deep-linking and complex flows.
---
## 🚀 Getting Started
### Prerequisites
*   macOS with **Xcode 15+** installed.
*   **CocoaPods** or **Swift Package Manager** (dependencies are pre-configured).
### Setup
1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-username/fixo-ios.git
    cd fixo-ios
    ```
2.  **Open in Xcode**:
    Open `Diagnose.xcodeproj`.
3.  **Configuration**:
    The project is pre-configured with a Supabase public key for demonstration. For production use, update `SupabaseManager.swift` with your own credentials:
    ```swift
    let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
    let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
    ```
4.  **Run**:
    Select an iOS Simulator (iPhone 15 or newer recommended) and press `Cmd + R`.
---
## 📸 Preview
| Home Screen | Diagnostic Test | Shop List |
| :---: | :---: | :---: |
| ![Home](https://via.placeholder.com/200x400?text=Home+Screen) | ![Test](https://via.placeholder.com/200x400?text=Diagnostic+Test) | ![Shops](https://via.placeholder.com/200x400?text=Shop+List) |
---
## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.
---
## 🤝 Contact
Project Link: [https://github.com/your-username/fixo-ios](https://github.com/your-username/fixo-ios)
Developed with ❤️ for the Tech Repair Community.
