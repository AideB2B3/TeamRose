require 'xcodeproj'

project_path = 'Diagnose.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first
main_group = project.main_group.find_subpath('Diagnose', false) || project.main_group

def add_files_recursively(dir_path, current_group, target)
  Dir.glob(File.join(dir_path, '*')).each do |path|
    name = File.basename(path)
    next if name == '.DS_Store'
    
    if File.directory?(path)
      # Check if group already exists
      existing_group = current_group.children.find { |c| c.display_name == name && c.is_a?(Xcodeproj::Project::Object::PBXGroup) }
      subgroup = existing_group || current_group.new_group(name, name)
      add_files_recursively(path, subgroup, target)
    else
      # Check if file already exists in this group
      unless current_group.files.find { |f| f.display_name == name }
        file_ref = current_group.new_reference(name)
        if name.end_with?('.swift')
          target.source_build_phase.add_file_reference(file_ref, true)
        elsif name.end_with?('.xcassets') || name.end_with?('.plist')
          target.resources_build_phase.add_file_reference(file_ref, true)
        end
      end
    end
  end
end

add_files_recursively('Diagnose', main_group, target)

project.save
puts "Project synced with all files in Diagnose folder."
