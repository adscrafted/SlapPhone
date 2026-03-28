#!/usr/bin/env ruby
# Create In-App Purchase using App Store Connect API directly

require 'spaceship'
require 'json'

KEY_ID = "49PVFZRL27"
ISSUER_ID = "5210488e-2060-4ef4-9cf7-d0b7975a92e0"
KEY_PATH = File.expand_path("~/.appstoreconnect/private_keys/AuthKey_#{KEY_ID}.p8")

APP_ID = "6761312358"
IAP_PRODUCT_ID = "com.adscrafted.slapphone.fullversion"
IAP_NAME = "Full Version"
IAP_REVIEW_NOTE = "Unlocks all features including voice packs, throw detection, shake detection, USB moaner, and lifetime statistics."

puts "Connecting to App Store Connect API..."

token = Spaceship::ConnectAPI::Token.create(
  key_id: KEY_ID,
  issuer_id: ISSUER_ID,
  filepath: KEY_PATH
)

Spaceship::ConnectAPI.token = token

puts "Authenticated!"

# Create IAP using direct API request
puts "Creating In-App Purchase..."

client = Spaceship::ConnectAPI.client

body = {
  data: {
    type: "inAppPurchases",
    attributes: {
      name: IAP_NAME,
      productId: IAP_PRODUCT_ID,
      inAppPurchaseType: "NON_CONSUMABLE",
      reviewNote: IAP_REVIEW_NOTE
    },
    relationships: {
      app: {
        data: {
          type: "apps",
          id: APP_ID
        }
      }
    }
  }
}

begin
  response = client.post("inAppPurchasesV2", body)
  iap_id = response.body.dig("data", "id")
  puts "Created IAP with ID: #{iap_id}"

  # Now create the localization
  puts "Creating localization..."

  loc_body = {
    data: {
      type: "inAppPurchaseLocalizations",
      attributes: {
        name: "Unlock SlapPhone",
        description: "Unlock all features and voice packs. One-time purchase, no subscription.",
        locale: "en-US"
      },
      relationships: {
        inAppPurchaseV2: {
          data: {
            type: "inAppPurchases",
            id: iap_id
          }
        }
      }
    }
  }

  client.post("inAppPurchaseLocalizations", loc_body)
  puts "Localization created!"

  # Set the price
  puts "Setting price to $4.99 (Tier 5)..."

  # Get price points
  price_response = client.get("inAppPurchasePriceSchedules/#{iap_id}/manualPrices")

  puts "IAP created successfully!"
  puts "Product ID: #{IAP_PRODUCT_ID}"
  puts "You may need to set the price manually in App Store Connect"

rescue => e
  puts "Error: #{e.message}"
  if e.message.include?("already exists")
    puts "IAP already exists!"
  else
    puts "\nFull error details:"
    puts e.backtrace.first(5).join("\n")
  end
end

puts "Done!"
