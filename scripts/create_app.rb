#!/usr/bin/env ruby
# Create App in App Store Connect

require 'spaceship'

KEY_ID = "49PVFZRL27"
ISSUER_ID = "5210488e-2060-4ef4-9cf7-d0b7975a92e0"
KEY_PATH = File.expand_path("~/.appstoreconnect/private_keys/AuthKey_#{KEY_ID}.p8")

BUNDLE_ID = "com.adscrafted.slapphone"
APP_NAME = "SlapPhone"
SKU = "slapphone"

puts "Connecting to App Store Connect API..."

Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.create(
  key_id: KEY_ID,
  issuer_id: ISSUER_ID,
  filepath: KEY_PATH
)

puts "Authenticated successfully!"

# Check if app already exists
puts "Checking for existing app..."
existing_app = Spaceship::ConnectAPI::App.find(BUNDLE_ID)

if existing_app
  puts "App '#{APP_NAME}' already exists with bundle ID #{BUNDLE_ID}!"
  puts "App ID: #{existing_app.id}"
else
  puts "Creating app '#{APP_NAME}'..."

  # Get the bundle ID object
  bundle_id = Spaceship::ConnectAPI::BundleId.all.find { |b| b.identifier == BUNDLE_ID }

  if bundle_id.nil?
    puts "ERROR: Bundle ID #{BUNDLE_ID} not found. Run register_bundle_id.rb first."
    exit 1
  end

  app = Spaceship::ConnectAPI::App.create(
    name: APP_NAME,
    version_string: "1.0",
    sku: SKU,
    primary_locale: "en-US",
    bundle_id: bundle_id.id,
    platforms: [Spaceship::ConnectAPI::Platform::IOS]
  )

  puts "Created app: #{app.name} (#{app.bundle_id})"
  puts "App ID: #{app.id}"
end

puts "Done!"
