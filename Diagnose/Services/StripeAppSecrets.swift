
import Foundation

/// 🔒 SECURE KEYS STORAGE
/// In a real-world project, you NEVER commit these to Git.
/// For your Academy Presentation, put your stripe.com keys here.
struct StripeAppSecrets {
    // 🔑 Publishable Key (Safe to use in App)
    // Register at dashboard.stripe.com/register
    static let publishableKey = "pk_test_PASTE_YOUR_STRIPE_PUBLISHABLE_KEY_HERE"
    
    // 🍎 Apple Pay Merchant ID
    // Register at developer.apple.com
    static let appleMerchantID = "merchant.com.fastfix.repair"
    
    // 🌍 Backend API URL (where you charge the actual money)
    static let backendURL = "https://api.your-fast-fix-backend.com/v1"
}
