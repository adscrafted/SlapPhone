#!/usr/bin/env ruby
# Add SlapPhoneTests unit test target to Xcode project

PROJECT_FILE = "/Users/anthony/Documents/Projects/SlapPhone/SlapPhone.xcodeproj/project.pbxproj"

content = File.read(PROJECT_FILE)

# Check if already exists
if content.include?("SlapPhoneTests")
  puts "SlapPhoneTests already exists!"
  exit 0
end

# === 1. Add to PBXBuildFile section (before /* UI Tests */) ===
build_files = <<-BUILDFILES

		/* Unit Tests */
		UT0001 /* StatisticsManagerTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = TF0001; };
		UT0002 /* ImpactEventTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = TF0002; };
		UT0003 /* VoicePackTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = TF0003; };
		UT0004 /* PaywallManagerTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = TF0004; };

BUILDFILES

content.sub!("		/* UI Tests */\n		AA0100", "#{build_files}		/* UI Tests */\n		AA0100")

# === 2. Add to PBXFileReference section (before /* UI Tests */) ===
file_refs = <<-FILEREFS

		/* Unit Tests */
		TP0001 /* SlapPhoneTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = SlapPhoneTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
		TF0001 /* StatisticsManagerTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StatisticsManagerTests.swift; sourceTree = "<group>"; };
		TF0002 /* ImpactEventTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ImpactEventTests.swift; sourceTree = "<group>"; };
		TF0003 /* VoicePackTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = VoicePackTests.swift; sourceTree = "<group>"; };
		TF0004 /* PaywallManagerTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PaywallManagerTests.swift; sourceTree = "<group>"; };

FILEREFS

content.sub!("		/* UI Tests */\n		FP0002", "#{file_refs}		/* UI Tests */\n		FP0002")

# === 3. Add PrivacyInfo.xcprivacy file reference ===
privacy_ref = "\n		FA0090 /* PrivacyInfo.xcprivacy */ = {isa = PBXFileReference; lastKnownFileType = text.xml; path = PrivacyInfo.xcprivacy; sourceTree = \"<group>\"; };\n"
content.sub!("		FA0083 /* Bangers-Regular.ttf */", "		FA0083 /* Bangers-Regular.ttf */#{privacy_ref}")

# === 4. Add PrivacyInfo build file ===
privacy_build = "		AA0090 /* PrivacyInfo.xcprivacy in Resources */ = {isa = PBXBuildFile; fileRef = FA0090; };\n"
content.sub!("		AA0084 /* Sounds in Resources */", "#{privacy_build}		AA0084 /* Sounds in Resources */")

# === 5. Add FC0003 frameworks phase ===
fc_section = <<-FC
		FC0003 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
FC

content.sub!("/* End PBXFrameworksBuildPhase section */", "#{fc_section}/* End PBXFrameworksBuildPhase section */")

# === 6. Add SlapPhoneTests group before SlapPhoneUITests ===
test_group = <<-GROUP
		TG0001 /* SlapPhoneTests */ = {
			isa = PBXGroup;
			children = (
				TF0001 /* StatisticsManagerTests.swift */,
				TF0002 /* ImpactEventTests.swift */,
				TF0003 /* VoicePackTests.swift */,
				TF0004 /* PaywallManagerTests.swift */,
			);
			path = SlapPhoneTests;
			sourceTree = "<group>";
		};
GROUP

content.sub!("		GR0070 /* SlapPhoneUITests */ = {", "#{test_group}		GR0070 /* SlapPhoneUITests */ = {")

# === 7. Add TG0001 to main group children ===
content.sub!("				GR0070 /* SlapPhoneUITests */,", "				TG0001 /* SlapPhoneTests */,\n				GR0070 /* SlapPhoneUITests */,")

# === 8. Add TP0001 to Products group ===
content.sub!("				FP0002 /* SlapPhoneUITests.xctest */,", "				FP0002 /* SlapPhoneUITests.xctest */,\n				TP0001 /* SlapPhoneTests.xctest */,")

# === 9. Add PrivacyInfo to Resources group ===
content.sub!("				FA0081 /* Info.plist */,", "				FA0081 /* Info.plist */,\n				FA0090 /* PrivacyInfo.xcprivacy */,")

# === 10. Add PrivacyInfo to resources build phase ===
content.sub!("				AA0083 /* Bangers-Regular.ttf in Resources */,", "				AA0083 /* Bangers-Regular.ttf in Resources */,\n				AA0090 /* PrivacyInfo.xcprivacy in Resources */,")

# === 11. Add container item proxy for unit tests ===
proxy = <<-PROXY
		CP0002 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = PR0001 /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = NT0001;
			remoteInfo = SlapPhone;
		};
PROXY

content.sub!("/* End PBXContainerItemProxy section */", "#{proxy}/* End PBXContainerItemProxy section */")

# === 12. Add target dependency for unit tests ===
dep = <<-DEP
		TD0002 /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			target = NT0001 /* SlapPhone */;
			targetProxy = CP0002 /* PBXContainerItemProxy */;
		};
DEP

content.sub!("/* End PBXTargetDependency section */", "#{dep}/* End PBXTargetDependency section */")

# === 13. Add NT0003 native target ===
native_target = <<-TARGET
		NT0003 /* SlapPhoneTests */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = BC0004 /* Build configuration list for PBXNativeTarget "SlapPhoneTests" */;
			buildPhases = (
				SP0003 /* Sources */,
				FC0003 /* Frameworks */,
				RP0003 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
				TD0002 /* PBXTargetDependency */,
			);
			name = SlapPhoneTests;
			productName = SlapPhoneTests;
			productReference = TP0001 /* SlapPhoneTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		};
TARGET

content.sub!("/* End PBXNativeTarget section */", "#{native_target}/* End PBXNativeTarget section */")

# === 14. Add to project targets list ===
content.sub!("				NT0002 /* SlapPhoneUITests */,", "				NT0002 /* SlapPhoneUITests */,\n				NT0003 /* SlapPhoneTests */,")

# === 15. Add target attributes ===
attrs = <<-ATTRS
					NT0003 = {
						CreatedOnToolsVersion = 15.0;
						TestTargetID = NT0001;
					};
ATTRS

content.sub!("				};\n			};\n			buildConfigurationList = BC0002", "				};\n#{attrs}			};\n			buildConfigurationList = BC0002")

# === 16. Add RP0003 resources phase ===
rp_section = <<-RP
		RP0003 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
RP

content.sub!("/* End PBXResourcesBuildPhase section */", "#{rp_section}/* End PBXResourcesBuildPhase section */")

# === 17. Add SP0003 sources phase ===
sp_section = <<-SP
		SP0003 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				UT0001 /* StatisticsManagerTests.swift in Sources */,
				UT0002 /* ImpactEventTests.swift in Sources */,
				UT0003 /* VoicePackTests.swift in Sources */,
				UT0004 /* PaywallManagerTests.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
SP

content.sub!("/* End PBXSourcesBuildPhase section */", "#{sp_section}/* End PBXSourcesBuildPhase section */")

# === 18. Add build configurations for test target ===
configs = <<-CONFIGS
		CF0007 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 4BLK4KNLW2;
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
		CF0008 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 4BLK4KNLW2;
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

content.sub!("/* End XCBuildConfiguration section */", "#{configs}/* End XCBuildConfiguration section */")

# === 19. Add configuration list for test target ===
config_list = <<-LIST
		BC0004 /* Build configuration list for PBXNativeTarget "SlapPhoneTests" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				CF0007 /* Debug */,
				CF0008 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
LIST

content.sub!("/* End XCConfigurationList section */", "#{config_list}/* End XCConfigurationList section */")

# Write file
File.write(PROJECT_FILE, content)

puts "Successfully added:"
puts "  - SlapPhoneTests unit test target"
puts "  - PrivacyInfo.xcprivacy to main target"
puts "  - 4 unit test files"
