require 'xcodeproj'

project_path = 'Diagnose.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Add Google Sign-In Package
package_url = 'https://github.com/google/google-signin-swift'

# Check if already added
existing_pkg = project.root_object.package_references.find { |p| p.repositoryURL == package_url }
if existing_pkg.nil?
    # Note: we use version 7.1.0 as the base
    # version_rule = { :kind => 'upToNextMajorVersion', :minimumVersion => '7.1.0' }
    package_ref = project.new_remote_package_reference(package_url, :upToNextMajorVersion => '7.1.0')
    
    # Create the dependency
    dependency = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
    dependency.package = package_ref
    dependency.product_name = 'GoogleSignIn'
    
    # Add to target
    target.package_product_dependencies << dependency
    
    puts "✅ Added GoogleSignIn package dependency."
else
    puts "ℹ️ GoogleSignIn package already exists."
end

project.save
puts "Project updated."
