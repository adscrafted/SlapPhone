#!/usr/bin/env ruby
# Add sound files to Xcode project

require 'securerandom'

PROJECT_FILE = "/Users/anthony/Documents/Projects/SlapPhone/SlapPhone.xcodeproj/project.pbxproj"
SOUNDS_DIR = "/Users/anthony/Documents/Projects/SlapPhone/SlapPhone/Resources/Sounds"

# Read project file
content = File.read(PROJECT_FILE)

# Generate unique IDs
def gen_id
  "S" + SecureRandom.hex(11).upcase[0, 22]
end

# Sound folders and their files
folders = {
  "default" => %w[ow1 ow2 ouch1 ouch2 oof1 grunt1 argh1 hey1],
  "angry" => %w[angry1 angry2 rage1 rage2 growl1 yell1 grr1 what1],
  "dramatic" => %w[scream1 scream2 dramatic1 dramatic2 wail1 cry1 nooo1 whyyy1],
  "silly" => %w[boing1 boing2 squeak1 squeak2 honk1 pop1 splat1 spring1],
  "plug" => %w[moan1 ooh1 ahh1 sigh1 gasp1 oh1 huh1 hmm1]
}

# Generate file references and build file entries
file_refs = []
build_files = []
group_children = {}

folders.each do |folder, files|
  folder_id = gen_id
  group_children[folder] = { id: folder_id, files: [] }

  files.each do |file|
    file_ref_id = gen_id
    build_file_id = gen_id

    file_refs << "\t\t#{file_ref_id} /* #{file}.m4a */ = {isa = PBXFileReference; lastKnownFileType = audio.m4a; path = \"#{file}.m4a\"; sourceTree = \"<group>\"; };"
    build_files << "\t\t#{build_file_id} /* #{file}.m4a in Resources */ = {isa = PBXBuildFile; fileRef = #{file_ref_id}; };"
    group_children[folder][:files] << { id: file_ref_id, name: file }
  end
end

# Generate group entries
group_entries = []
group_refs = []

group_children.each do |folder, data|
  children = data[:files].map { |f| "\t\t\t\t#{f[:id]} /* #{f[:name]}.m4a */," }.join("\n")
  group_entries << <<~GROUP
\t\t#{data[:id]} /* #{folder} */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
#{children}
\t\t\t);
\t\t\tpath = #{folder};
\t\t\tsourceTree = "<group>";
\t\t};
GROUP
  group_refs << "\t\t\t\t#{data[:id]} /* #{folder} */,"
end

# Insert file references
file_ref_section = file_refs.join("\n")
content.gsub!(/(\t\tFA0083.*Bangers-Regular\.ttf.*\n)/) do
  "#{$1}\n\t\t/* Sound Files */\n#{file_ref_section}\n"
end

# Insert build files (before End PBXBuildFile section)
build_file_section = build_files.join("\n")
content.gsub!(/(\/\* End PBXBuildFile section \*\/)/) do
  "\n\t\t/* Sound Files */\n#{build_file_section}\n#{$1}"
end

# Update Sounds group to include subfolders
sounds_group_pattern = /(\t\tGR0061 \/\* Sounds \*\/ = \{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n)(\t\t\t\);)/

content.gsub!(sounds_group_pattern) do
  "#{$1}#{group_refs.join("\n")}\n\t\t\t);"
end

# Add group definitions before End PBXGroup section
group_section = group_entries.join("\n")
content.gsub!(/(\/\* End PBXGroup section \*\/)/) do
  "#{group_section}#{$1}"
end

# Add build files to Resources phase
resource_build_refs = build_files.map { |bf| bf.match(/\t\t(\S+) \/\*/)[1] }
resource_refs = resource_build_refs.map { |ref| "\t\t\t\t#{ref} /* in Resources */," }.join("\n")

content.gsub!(/(\t\t\t\tAA0083 \/\* Bangers-Regular\.ttf in Resources \*\/,\n)(\t\t\t\);)/) do
  "#{$1}#{resource_refs}\n\t\t\t);"
end

# Write updated project file
File.write(PROJECT_FILE, content)
puts "Added #{folders.values.flatten.count} sound files to project!"
