#!/usr/bin/env ruby
# List Bundle IDs using App Store Connect API

require 'spaceship'

KEY_ID = "49PVFZRL27"
ISSUER_ID = "5210488e-2060-4ef4-9cf7-d0b7975a92e0"
KEY_PATH = File.expand_path("~/.appstoreconnect/private_keys/AuthKey_#{KEY_ID}.p8")

puts "Connecting to App Store Connect API..."

Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.create(
  key_id: KEY_ID,
  issuer_id: ISSUER_ID,
  filepath: KEY_PATH
)

puts "Authenticated! Fetching Bundle IDs...\n\n"

bundle_ids = Spaceship::ConnectAPI::BundleId.all
bundle_ids.each do |bid|
  puts "#{bid.identifier} - #{bid.name}"
end

puts "\nTotal: #{bundle_ids.count} Bundle IDs"

# Check specifically for slapphone
puts "\n--- Searching for 'slapphone' ---"
slapphone = bundle_ids.find { |b| b.identifier.include?('slapphone') }
if slapphone
  puts "Found: #{slapphone.identifier} (#{slapphone.name})"
else
  puts "No Bundle ID containing 'slapphone' found"
end
