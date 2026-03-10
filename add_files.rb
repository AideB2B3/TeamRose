require 'xcodeproj'

project_path = 'Diagnose.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first
group = project.main_group.find_subpath('Diagnose', false)

def add_files(dir_path, group, target)
  Dir.glob(File.join(dir_path, '*')).each do |path|
    name = File.basename(path)
    next if name == '.DS_Store'
    
    if File.directory?(path)
      subgroup = group.new_group(name, name)
      add_files(path, subgroup, target)
    else
      file_ref = group.new_reference(name)
      if name.end_with?('.swift')
        target.source_build_phase.add_file_reference(file_ref, true)
      elsif name.end_with?('.xcassets')
        target.resources_build_phase.add_file_reference(file_ref, true)
      end
    end
  end
end

shop_dir = 'Diagnose/ShopDashboard'
shop_group = group.new_group('ShopDashboard', 'ShopDashboard')
add_files(shop_dir, shop_group, target)

# Add RoleSelectionRootView.swift if not already added
unless group.files.find { |f| f.path == 'RoleSelectionRootView.swift' }
  file_ref = group.new_reference('RoleSelectionRootView.swift')
  target.source_build_phase.add_file_reference(file_ref, true)
end

project.save
puts "Added target files successfully."
