#!/usr/bin/env ruby
# Create In-App Purchase using direct HTTP API calls

require 'jwt'
require 'net/http'
require 'json'
require 'openssl'

KEY_ID = "49PVFZRL27"
ISSUER_ID = "5210488e-2060-4ef4-9cf7-d0b7975a92e0"
KEY_PATH = File.expand_path("~/.appstoreconnect/private_keys/AuthKey_#{KEY_ID}.p8")

APP_ID = "6761312358"
IAP_PRODUCT_ID = "com.adscrafted.slapphone.fullversion"
IAP_NAME = "Full Version"

# Generate JWT token
private_key = OpenSSL::PKey::EC.new(File.read(KEY_PATH))

payload = {
  iss: ISSUER_ID,
  iat: Time.now.to_i,
  exp: Time.now.to_i + 20 * 60,
  aud: "appstoreconnect-v1"
}

token = JWT.encode(payload, private_key, 'ES256', { kid: KEY_ID, typ: 'JWT' })

puts "Generated JWT token"

# API base URL
BASE_URL = "https://api.appstoreconnect.apple.com/v1"

def make_request(method, path, token, body = nil, version = 1)
  uri = URI("https://api.appstoreconnect.apple.com/v#{version}/#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  case method
  when :get
    request = Net::HTTP::Get.new(uri)
  when :post
    request = Net::HTTP::Post.new(uri)
    request.body = body.to_json if body
  end

  request['Authorization'] = "Bearer #{token}"
  request['Content-Type'] = 'application/json'

  response = http.request(request)
  parsed = begin
    JSON.parse(response.body)
  rescue
    response.body
  end
  [response.code.to_i, parsed]
end

# Create the IAP
puts "Creating In-App Purchase '#{IAP_PRODUCT_ID}'..."

iap_body = {
  data: {
    type: "inAppPurchases",
    attributes: {
      name: IAP_NAME,
      productId: IAP_PRODUCT_ID,
      inAppPurchaseType: "NON_CONSUMABLE",
      reviewNote: "Unlocks all features including voice packs and lifetime statistics."
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

status, result = make_request(:post, "inAppPurchases", token, iap_body, 2)

if status == 201
  iap_id = result.dig("data", "id")
  puts "Created IAP! ID: #{iap_id}"

  # Create localization
  puts "Creating localization..."

  loc_body = {
    data: {
      type: "inAppPurchaseLocalizations",
      attributes: {
        name: "Unlock SlapPhone",
        description: "Unlock all features and voice packs including slap detection, throw detection, shake detection, USB moaner, and lifetime statistics. One-time purchase.",
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

  status2, result2 = make_request(:post, "inAppPurchaseLocalizations", token, loc_body)

  if status2 == 201
    puts "Localization created!"
  else
    puts "Localization error: #{result2}"
  end

  puts "\nIAP Created Successfully!"
  puts "Product ID: #{IAP_PRODUCT_ID}"
  puts "NOTE: You still need to set the price in App Store Connect"
  puts "Go to: Monetization > In-App Purchases > Full Version > Pricing"

elsif status == 409
  puts "IAP already exists!"
elsif status == 403
  puts "Permission denied. Your API key may not have IAP creation permissions."
  puts "Response: #{result}"
else
  puts "Error (#{status}): #{result}"
end
