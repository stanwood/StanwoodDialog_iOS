Pod::Spec.new do |s|
  s.name             = 'StanwoodDialog'
  s.version          = '1.0.0'
  s.summary          = 'Library to show a rating dialog prompt like the one used in On Air.'

  s.description      = <<-DESC
This library allows to show a rating dialog prompt like the one used in On Air. 
This allows a more personal approach and dismisses automatically when no interaction.
                       DESC

  s.homepage         = 'https://github.com/stanwood/StanwoodDialog_iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Eugene Peschard' => 'eugene.peschard@stanwood.io' }
  s.source           = { :git => 'https://github.com/stanwood/StanwoodDialog_iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Stanwood_Dialog_iOS/Classes/**/*.{swift}'
  
  s.resource_bundles = {
    'Stanwood_Dialog_iOS' => ['Stanwood_Dialog_iOS/Classes/**/*.{xib,png,jpeg}']
  }

  s.frameworks = 'UIKit'
end
