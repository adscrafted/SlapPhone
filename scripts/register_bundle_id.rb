#!/usr/bin/env ruby
# Register Bundle ID using App Store Connect API

require 'spaceship'

KEY_ID = "49PVFZRL27"
ISSUER_ID = "5210488e-2060-4ef4-9cf7-d0b7975a92e0"
KEY_PATH = File.expand_path("~/.appstoreconnect/private_keys/AuthKey_#{KEY_ID}.p8")

BUNDLE_ID = "com.adscrafted.slapphone"
APP_NAME = "SlapPhone"

puts "Connecting to App Store Connect API..."

Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.create(
  key_id: KEY_ID,
  issuer_id: ISSUER_ID,
  filepath: KEY_PATH
)

puts "Authenticated successfully!"

# Check if Bundle ID already exists
puts "Checking for existing Bundle ID..."
existing = Spaceship::ConnectAPI::BundleId.all.find { |b| b.identifier == BUNDLE_ID }

if existing
  puts "Bundle ID '#{BUNDLE_ID}' already exists!"
else
  puts "Creating Bundle ID '#{BUNDLE_ID}'..."

  bundle_id = Spaceship::ConnectAPI::BundleId.create(
    identifier: BUNDLE_ID,
    name: APP_NAME,
    platform: Spaceship::ConnectAPI::BundleIdPlatform::IOS
  )

  puts "Created Bundle ID: #{bundle_id.identifier}"

  # Enable In-App Purchase capability
  puts "Enabling In-App Purchase capability..."
  bundle_id.create_capability(Spaceship::ConnectAPI::BundleIdCapability::Type::IN_APP_PURCHASE)
  puts "In-App Purchase capability enabled!"
end

puts "Done!"
