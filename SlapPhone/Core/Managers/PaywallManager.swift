import Foundation
import StoreKit

@MainActor
class PaywallManager: ObservableObject {
    static let productID = "com.slapphone.fullversion"

    @Published var isPurchased: Bool = false
    @Published var product: Product?
    @Published var purchaseState: PurchaseState = .idle
    @Published var errorMessage: String?

    enum PurchaseState {
        case idle
        case loading
        case purchasing
        case purchased
        case failed
    }

    init() {
        Task {
            await loadPurchaseState()
            await loadProduct()
        }
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
        } catch {
            print("Failed to load product: \(error)")
        }
    }

    func loadPurchaseState() async {
        // Check for existing purchase
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.productID {
                    isPurchased = true
                    purchaseState = .purchased
                    return
                }
            }
        }

        // Check UserDefaults as backup (for testing)
        isPurchased = UserDefaults.standard.bool(forKey: "isPurchased")
    }

    func purchase() async {
        guard let product = product else {
            errorMessage = "Product not available"
            return
        }

        purchaseState = .purchasing

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    isPurchased = true
                    purchaseState = .purchased
                    UserDefaults.standard.set(true, forKey: "isPurchased")

                case .unverified(_, let error):
                    purchaseState = .failed
                    errorMessage = "Purchase verification failed: \(error.localizedDescription)"
                }

            case .userCancelled:
                purchaseState = .idle

            case .pending:
                purchaseState = .idle
                errorMessage = "Purchase is pending approval"

            @unknown default:
                purchaseState = .failed
            }
        } catch {
            purchaseState = .failed
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        purchaseState = .loading

        do {
            try await AppStore.sync()
            await loadPurchaseState()

            if !isPurchased {
                purchaseState = .idle
                errorMessage = "No purchases to restore"
            }
        } catch {
            purchaseState = .failed
            errorMessage = "Failed to restore: \(error.localizedDescription)"
        }
    }

    // For testing in simulator
    func simulatePurchase() {
        isPurchased = true
        purchaseState = .purchased
        UserDefaults.standard.set(true, forKey: "isPurchased")
    }

    func resetPurchase() {
        isPurchased = false
        purchaseState = .idle
        UserDefaults.standard.set(false, forKey: "isPurchased")
    }
}
