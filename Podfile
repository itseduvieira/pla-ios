platform :ios, '10.3'

target 'Plandoc' do
    use_frameworks!

    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'Firebase/Storage'
    pod 'Firebase/Messaging'
    pod 'Fabric', '~> 1.7.9'
    pod 'Crashlytics', '~> 3.10.5'
    pod 'IQKeyboardManagerSwift'
    pod 'ChromaColorPicker'
    pod 'FSCalendar'
    pod 'SearchTextField'
    pod 'MapboxGeocoder.swift', '~> 0.6'
    pod 'MapboxStatic.swift', '~> 0.9'
    pod 'Bolts'
    pod 'Charts'
    pod 'FacebookLogin'
    pod 'SwiftKeychainWrapper'
    pod 'Alamofire', '~> 4.7'
    pod 'PromiseKit/Alamofire', '~> 6.0'
    pod 'MaterialComponents/Snackbar'
    
    # Workaround for Cocoapods issue #7606
    post_install do |installer|
        installer.pods_project.build_configurations.each do |config|
            config.build_settings.delete('CODE_SIGNING_ALLOWED')
            config.build_settings.delete('CODE_SIGNING_REQUIRED')
        end
    end
end
