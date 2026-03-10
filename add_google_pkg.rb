require 'xcodeproj'

project_path = 'Diagnose.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'Diagnose' }

correct_url = 'https://github.com/google/GoogleSignIn-iOS'

# Clean up existing if needed
project.root_object.package_references.delete_if { |p| p.repositoryURL == correct_url }
target.package_product_dependencies.delete_if { |d| d.product_name == 'GoogleSignIn' }

# Create Package Reference with 9.0.0
remote_pkg = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
remote_pkg.repositoryURL = correct_url
remote_pkg.requirement = {
  'kind' => 'upToNextMajorVersion',
  'minimumVersion' => '9.1.0'
}
project.root_object.package_references << remote_pkg

# Create Product Dependency
product_dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
product_dep.package = remote_pkg
product_dep.product_name = 'GoogleSignIn'
target.package_product_dependencies << product_dep

project.save
puts "✅ Configured GoogleSignIn-iOS 9.1.0"
