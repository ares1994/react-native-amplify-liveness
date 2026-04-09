require 'xcodeproj'

project_path = 'example/ios/AmplifyLivenessExample.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'AmplifyLivenessExample' }

# 1. Add SPM dependency to the project
package_url = 'https://github.com/aws-amplify/amplify-ui-swift-liveness'
unless project.root_object.package_references.find { |p| p.repositoryURL == package_url }
  package_ref = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
  package_ref.repositoryURL = package_url
  package_ref.requirement = {
    'kind' => 'exactVersion',
    'version' => '1.4.4'
  }
  project.root_object.package_references << package_ref

  # 2. Add product to target's frameworks build phase
  package_product = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
  package_product.package = package_ref
  package_product.product_name = 'FaceLiveness'

  build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
  build_file.product_ref = package_product

  frameworks_phase = target.frameworks_build_phase
  frameworks_phase.files << build_file
end

# 3. Add references to AmplifyLiveness.swift and AmplifyLiveness.m to the target
group = project.main_group.find_subpath('AmplifyLivenessExample', true)

root_dir = __dir__
swift_file_path = File.expand_path('ios/AmplifyLiveness.swift', root_dir)
m_file_path = File.expand_path('ios/AmplifyLiveness.m', root_dir)

[swift_file_path, m_file_path].each do |path|
  file_ref = group.files.find { |f| f.real_path.to_s == path || f.path == path }
  unless file_ref
    file_ref = group.new_reference(path)
    target.source_build_phase.add_file_reference(file_ref)
  end
end

# Ensure bridging header or build settings are correct if needed
# (React Native projects usually already import RCTBridgeModule so we might just need to ensure Swift is configured)
target.build_configurations.each do |config|
  # Setting Swift version just in case it's not set
  config.build_settings['SWIFT_VERSION'] = '5.0'
end

project.save
puts "Successfully configured Xcode project with native SPM and local source files."
