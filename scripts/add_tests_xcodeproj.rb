#!/usr/bin/env ruby
# Add SlapPhoneTests target using xcodeproj gem

require 'xcodeproj'

PROJECT_PATH = '/Users/anthony/Documents/Projects/SlapPhone/SlapPhone.xcodeproj'
TESTS_PATH = '/Users/anthony/Documents/Projects/SlapPhone/SlapPhoneTests'

# Open project
project = Xcodeproj::Project.open(PROJECT_PATH)

# Check if target already exists
if project.targets.any? { |t| t.name == 'SlapPhoneTests' }
  puts "SlapPhoneTests target already exists!"
  exit 0
end

# Get main app target
app_target = project.targets.find { |t| t.name == 'SlapPhone' }

# Create unit test target
test_target = project.new_target(:unit_test_bundle, 'SlapPhoneTests', :ios, '17.0')

# Set bundle identifier
test_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.adscrafted.slapphone.tests'
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/SlapPhone.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/SlapPhone'
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
  config.build_settings['DEVELOPMENT_TEAM'] = '4BLK4KNLW2'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
end

# Add dependency on main app
test_target.add_dependency(app_target)

# Create group for test files
tests_group = project.main_group.new_group('SlapPhoneTests', TESTS_PATH)

# Add test files
test_files = [
  'StatisticsManagerTests.swift',
  'ImpactEventTests.swift',
  'VoicePackTests.swift',
  'PaywallManagerTests.swift'
]

test_files.each do |filename|
  file_path = File.join(TESTS_PATH, filename)
  if File.exist?(file_path)
    file_ref = tests_group.new_file(file_path)
    test_target.source_build_phase.add_file_reference(file_ref)
    puts "Added: #{filename}"
  else
    puts "Warning: #{filename} not found"
  end
end

# Save project
project.save

puts ""
puts "Successfully added SlapPhoneTests target!"
puts "Run tests with: xcodebuild test -scheme SlapPhone -destination 'platform=iOS Simulator,name=iPhone 16 Pro'"
