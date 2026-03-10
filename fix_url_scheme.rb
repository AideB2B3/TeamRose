require 'xcodeproj'

project_path = 'Diagnose.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'Diagnose' }

if target.nil?
  puts "❌ Target 'Diagnose' not found."
  exit 1
end

reverse_client_id = 'com.googleusercontent.apps.1052433569354-f1cij4np4h2edoovmospejqiatr8mv0d'

# Update Info.plist via the project's build settings if possible, 
# but better to add it to the URL Types in the project file structure.

# Access the build configuration to find the Info.plist
info_plist_path = nil
target.build_configurations.each do |config|
  path = config.build_settings['INFOPLIST_FILE']
  if path
    info_plist_path = path
    break
  end
end

if info_plist_path
  full_plist_path = File.join(File.dirname(project_path), info_plist_path)
  puts "ℹ️ Info.plist found at: #{full_plist_path}"
  
  # We can't easily edit Plist files directly with xcodeproj gem comfortably, 
  # but we can add URL Types to the target settings.
  
  # However, Xcode 13+ often stores URL Types in the project file itself or the plist.
  # Let's try adding it to the project's URL Types if they exist.
end

# The most reliable way for me as an agent is to add it to the target's build settings 
# or ensure it's in the project structure.
# But for Google Sign-In, it MUST be in the URL Schemes.

# Add URL Type to the target
url_type = {
  'CFBundleURLName' => 'Google Sign In',
  'CFBundleURLSchemes' => [reverse_client_id]
}

# Check if it already exists
existing_url_types = target.build_configurations.first.build_settings['CFBundleURLTypes'] || []
already_exists = existing_url_types.any? { |type| type['CFBundleURLSchemes'].include?(reverse_client_id) }

if !already_exists
  target.build_configurations.each do |config|
    config.build_settings['CFBundleURLTypes'] ||= []
    config.build_settings['CFBundleURLTypes'] << url_type
  end
  project.save
  puts "✅ Added URL Scheme to build settings: #{reverse_client_id}"
else
  puts "ℹ️ URL Scheme already exists in build settings."
end

# Also update the Plist directly using 'plutil' if it exists
if info_plist_path
  system("plutil -replace CFBundleURLTypes -json '[{\"CFBundleURLName\": \"Google Sign In\", \"CFBundleURLSchemes\": [\"#{reverse_client_id}\"]}]' #{full_plist_path}")
  puts "✅ Updated Info.plist with plutil."
end

puts "Done."
