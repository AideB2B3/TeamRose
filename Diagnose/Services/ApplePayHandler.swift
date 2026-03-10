
import Foundation
import PassKit

class ApplePayHandler: NSObject, PKPaymentAuthorizationControllerDelegate {
    var completion: ((Bool) -> Void)?
    
    func startPayment(amount: Double, completion: @escaping (Bool) -> Void) {
        self.completion = completion
        
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = "merchant.com.fastfix.academy" // Mock ID
        paymentRequest.supportedNetworks = [.visa, .masterCard, .amex]
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = "IT"
        paymentRequest.currencyCode = "EUR"
        
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "FastFix Repair Service", amount: NSDecimalNumber(value: amount))
        ]
        
        let controller = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        controller.delegate = self
        controller.present { (presented) in
            if !presented {
                completion(false)
            }
        }
    }
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // In a real app, you would send the payment.token to your server here
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            self.completion?(true)
        }
    }
}
