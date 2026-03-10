require 'xcodeproj'

project_path = 'Diagnose.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first
main_group = project.main_group.find_subpath('Diagnose', false)

def add_file(project, target, main_group, filepath)
    dirname = File.dirname(filepath).sub(/^Diagnose\//, '')
    filename = File.basename(filepath)
    
    # Try to find existing group
    target_group = main_group
    unless dirname == 'Diagnose'
        dirname.split('/').each do |sub|
            target_group = target_group.groups.find { |g| g.name == sub } || target_group.new_group(sub)
        end
    end
    
    # Check if file already in group
    unless target_group.files.find { |f| f.name == filename || f.path == filename }
        file_ref = target_group.new_file(filename)
        target.add_file_references([file_ref])
        puts "✅ Added #{filename} to #{target_group.display_name}"
    end
end

add_file(project, target, main_group, 'Diagnose/Models/AuthManager.swift')
add_file(project, target, main_group, 'Diagnose/Views/ShopLoginView.swift')

project.save
puts "Project synced successfully."
