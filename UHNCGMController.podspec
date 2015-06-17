#
# Be sure to run `pod lib lint UHNCGMController.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "UHNCGMController"
  s.version          = "0.1.2"
  s.summary          = "A central continuous glucose monitor controller."
  s.description      = <<-DESC
                       The central CGM controller is built upon the UHNBLEControlelr, a general central BLE controller. The CGM controller provides a delegate based interface to interacting with CGM service as defined by BT-SIG.

                       * Read/Write/Notification interact with CGM characterisitics
                       * Procedures via record access control point
                       * Operartions via the specific ops control point
                       DESC
  s.homepage         = "https://github.com/uhnmdi/UHNCGMController"
  s.license          = 'MIT'
  s.author           = { "Nathaniel Hamming" => "nathaniel.hamming@gmail.com" }
  s.source           = { :git => "https://github.com/uhnmdi/UHNCGMController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/NateHam80'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'UHNCGMController' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'CoreBluetooth'
  s.dependency 'UHNDebug'
  s.dependency 'UHNBLEController'

end
