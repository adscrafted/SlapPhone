#!/usr/bin/env ruby
# Add unit test target to Xcode project

PROJECT_FILE = "/Users/anthony/Documents/Projects/SlapPhone/SlapPhone.xcodeproj/project.pbxproj"

content = File.read(PROJECT_FILE)

# Check if SlapPhoneTests already exists
if content.include?("SlapPhoneTests")
  puts "SlapPhoneTests target already exists!"
  exit 0
end

# IDs for new elements
test_product_id = "FP0003"
test_target_id = "NT0003"
test_sources_id = "SP0003"
test_frameworks_id = "FC0003"
test_resources_id = "RP0003"
test_group_id = "GR0080"
test_config_list_id = "BC0005"
test_config_debug_id = "XC0009"
test_config_release_id = "XC0010"
target_dep_id = "TD0002"
container_proxy_id = "CP0002"

# File references for test files
stats_test_ref = "FT0001"
stats_test_build = "BT0001"
impact_test_ref = "FT0002"
impact_test_build = "BT0002"
voice_test_ref = "FT0003"
voice_test_build = "BT0003"
paywall_test_ref = "FT0004"
paywall_test_build = "BT0004"

# 1. Add file references in PBXFileReference section
file_refs = <<~REFS

		/* Unit Tests */
		#{test_product_id} /* SlapPhoneTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = SlapPhoneTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
		#{stats_test_ref} /* StatisticsManagerTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StatisticsManagerTests.swift; sourceTree = "<group>"; };
		#{impact_test_ref} /* ImpactEventTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ImpactEventTests.swift; sourceTree = "<group>"; };
		#{voice_test_ref} /* VoicePackTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = VoicePackTests.swift; sourceTree = "<group>"; };
		#{paywall_test_ref} /* PaywallManagerTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PaywallManagerTests.swift; sourceTree = "<group>"; };
REFS

content.gsub!(/(\/* UI Tests \*\/\n\s+FP0002)/) do
  "#{file_refs}\n\t\t/* UI Tests */\n\t\tFP0002"
end

# 2. Add build file references
build_files = <<~BUILD

		/* Unit Test Sources */
		#{stats_test_build} /* StatisticsManagerTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{stats_test_ref}; };
		#{impact_test_build} /* ImpactEventTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{impact_test_ref}; };
		#{voice_test_build} /* VoicePackTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{voice_test_ref}; };
		#{paywall_test_build} /* PaywallManagerTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{paywall_test_ref}; };
BUILD

content.gsub!(/(\/* UI Tests \*\/\n\s+AA0100)/) do
  "#{build_files}\n\t\t/* UI Tests */\n\t\tAA0100"
end

# 3. Add SlapPhoneTests group
group_entry = <<~GROUP
		#{test_group_id} /* SlapPhoneTests */ = {
			isa = PBXGroup;
			children = (
				#{stats_test_ref} /* StatisticsManagerTests.swift */,
				#{impact_test_ref} /* ImpactEventTests.swift */,
				#{voice_test_ref} /* VoicePackTests.swift */,
				#{paywall_test_ref} /* PaywallManagerTests.swift */,
			);
			path = SlapPhoneTests;
			sourceTree = "<group>";
		};
GROUP

content.gsub!(/(GR0070 \/\* SlapPhoneUITests \*\/ = \{)/) do
  "#{group_entry}\t\t#{$1}"
end

# 4. Add SlapPhoneTests group to main group children
content.gsub!(/(GR0070 \/\* SlapPhoneUITests \*\/,)/) do
  "#{test_group_id} /* SlapPhoneTests */,\n\t\t\t\t#{$1}"
end

# 5. Add product reference
content.gsub!(/(FP0002 \/\* SlapPhoneUITests.xctest \*\/,)/) do
  "#{$1}\n\t\t\t\t#{test_product_id} /* SlapPhoneTests.xctest */,"
end

# 6. Add source build phase
sources_phase = <<~SOURCES
		#{test_sources_id} /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				#{stats_test_build} /* StatisticsManagerTests.swift in Sources */,
				#{impact_test_build} /* ImpactEventTests.swift in Sources */,
				#{voice_test_build} /* VoicePackTests.swift in Sources */,
				#{paywall_test_build} /* PaywallManagerTests.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
SOURCES

content.gsub!(/(\/* End PBXSourcesBuildPhase section \*\/)/) do
  "#{sources_phase}#{$1}"
end

# 7. Add frameworks build phase
frameworks_phase = <<~FRAMEWORKS
		#{test_frameworks_id} /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
FRAMEWORKS

content.gsub!(/(\/* End PBXFrameworksBuildPhase section \*\/)/) do
  "#{frameworks_phase}#{$1}"
end

# 8. Add resources build phase
resources_phase = <<~RESOURCES
		#{test_resources_id} /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
RESOURCES

content.gsub!(/(\/* End PBXResourcesBuildPhase section \*\/)/) do
  "#{resources_phase}#{$1}"
end

# 9. Add container item proxy
proxy_entry = <<~PROXY
		#{container_proxy_id} /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = PR0001 /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = NT0001;
			remoteInfo = SlapPhone;
		};
PROXY

content.gsub!(/(\/* End PBXContainerItemProxy section \*\/)/) do
  "#{proxy_entry}#{$1}"
end

# 10. Add target dependency
dep_entry = <<~DEP
		#{target_dep_id} /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			target = NT0001 /* SlapPhone */;
			targetProxy = #{container_proxy_id} /* PBXContainerItemProxy */;
		};
DEP

content.gsub!(/(\/* End PBXTargetDependency section \*\/)/) do
  "#{dep_entry}#{$1}"
end

# 11. Add native target
native_target = <<~TARGET
		#{test_target_id} /* SlapPhoneTests */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = #{test_config_list_id} /* Build configuration list for PBXNativeTarget "SlapPhoneTests" */;
			buildPhases = (
				#{test_sources_id} /* Sources */,
				#{test_frameworks_id} /* Frameworks */,
				#{test_resources_id} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
				#{target_dep_id} /* PBXTargetDependency */,
			);
			name = SlapPhoneTests;
			productName = SlapPhoneTests;
			productReference = #{test_product_id} /* SlapPhoneTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		};
TARGET

content.gsub!(/(\/* End PBXNativeTarget section \*\/)/) do
  "#{native_target}#{$1}"
end

# 12. Add target to project targets list
content.gsub!(/(NT0002 \/\* SlapPhoneUITests \*\/,)/) do
  "#{$1}\n\t\t\t\t#{test_target_id} /* SlapPhoneTests */,"
end

# 13. Add target attributes
content.gsub!(/(NT0002 = \{\n\s+CreatedOnToolsVersion = 15\.0;\n\s+TestTargetID = NT0001;\n\s+\};)/) do
  "#{$1}\n\t\t\t\t\t#{test_target_id} = {\n\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;\n\t\t\t\t\t\tTestTargetID = NT0001;\n\t\t\t\t\t};"
end

# 14. Add build configurations for test target
test_configs = <<~CONFIGS
		#{test_config_debug_id} /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = SMDCB3B296;
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.adscrafted.slapphone.tests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/SlapPhone.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/SlapPhone";
			};
			name = Debug;
		};
		#{test_config_release_id} /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = SMDCB3B296;
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.adscrafted.slapphone.tests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/SlapPhone.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/SlapPhone";
			};
			name = Release;
		};
CONFIGS

content.gsub!(/(\/* End XCBuildConfiguration section \*\/)/) do
  "#{test_configs}#{$1}"
end

# 15. Add configuration list for test target
config_list = <<~LIST
		#{test_config_list_id} /* Build configuration list for PBXNativeTarget "SlapPhoneTests" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				#{test_config_debug_id} /* Debug */,
				#{test_config_release_id} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
LIST

content.gsub!(/(\/* End XCConfigurationList section \*\/)/) do
  "#{config_list}#{$1}"
end

# Write updated project file
File.write(PROJECT_FILE, content)
puts "Successfully added SlapPhoneTests target!"
puts "Test files:"
puts "  - StatisticsManagerTests.swift"
puts "  - ImpactEventTests.swift"
puts "  - VoicePackTests.swift"
puts "  - PaywallManagerTests.swift"
