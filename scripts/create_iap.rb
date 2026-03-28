#!/usr/bin/env ruby
# Create In-App Purchase in App Store Connect

require 'spaceship'

KEY_ID = "49PVFZRL27"
ISSUER_ID = "5210488e-2060-4ef4-9cf7-d0b7975a92e0"
KEY_PATH = File.expand_path("~/.appstoreconnect/private_keys/AuthKey_#{KEY_ID}.p8")

BUNDLE_ID = "com.adscrafted.slapphone"
IAP_PRODUCT_ID = "com.adscrafted.slapphone.fullversion"
IAP_NAME = "Full Version"
IAP_REVIEW_NOTE = "Unlocks all features including all voice packs, throw detection, shake detection, USB moaner, and lifetime statistics tracking."

puts "Connecting to App Store Connect API..."

Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.create(
  key_id: KEY_ID,
  issuer_id: ISSUER_ID,
  filepath: KEY_PATH
)

puts "Authenticated successfully!"

# Find the app
puts "Finding app..."
app = Spaceship::ConnectAPI::App.find(BUNDLE_ID)

if app.nil?
  puts "ERROR: App not found with bundle ID #{BUNDLE_ID}"
  exit 1
end

puts "Found app: #{app.name} (ID: #{app.id})"

# Create IAP using direct API call
puts "Creating In-App Purchase '#{IAP_PRODUCT_ID}'..."

begin
  # Use the Tunes client directly for IAP creation
  result = Spaceship::ConnectAPI.post_in_app_purchase(
    app_id: app.id,
    name: IAP_NAME,
    product_id: IAP_PRODUCT_ID,
    in_app_purchase_type: "NON_CONSUMABLE"
  )
  puts "Created IAP successfully!"
rescue => e
  if e.message.include?("ENTITY_ERROR") || e.message.include?("already exists")
    puts "IAP may already exist or there was a conflict - check App Store Connect"
  else
    puts "Note: #{e.message}"
    puts "You may need to create the IAP manually in App Store Connect"
  end
end

puts "Done!"
