#!/usr/bin/env ruby
require 'xcodeproj'

project = Xcodeproj::Project.open('SlapPhone.xcodeproj')
test_target = project.targets.find { |t| t.name == 'SlapPhoneTests' }

scheme_path = 'SlapPhone.xcodeproj/xcshareddata/xcschemes/SlapPhone.xcscheme'

if File.exist?(scheme_path)
  scheme = Xcodeproj::XCScheme.new(scheme_path)

  # Check if already added
  existing = scheme.test_action.testables.any? { |t| t.buildable_references.any? { |b| b.target_name == 'SlapPhoneTests' } }

  unless existing
    test_ref = Xcodeproj::XCScheme::TestAction::TestableReference.new(test_target)
    scheme.test_action.add_testable(test_ref)
    scheme.save!
    puts 'Added SlapPhoneTests to scheme'
  else
    puts 'SlapPhoneTests already in scheme'
  end
else
  puts "Scheme not found at #{scheme_path}"
  # List available schemes
  Dir.glob('SlapPhone.xcodeproj/xcshareddata/xcschemes/*.xcscheme').each do |s|
    puts "Found: #{s}"
  end
end
