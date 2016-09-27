source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'Keymochi' do
    pod 'Realm'
    pod 'RealmSwift'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'SwiftHEXColors'
    pod 'Firebase'
    pod 'Firebase/Core’
    pod 'Firebase/Database'
    pod 'SwiftDate', git: 'https://github.com/malcommac/SwiftDate.git', branch: 'feature/swift-3.0'
    pod 'PAM', git: 'https://github.com/Keymochi/PAM.git', branch: 'master'
end

target 'KeymochiTests' do
    pod 'Realm'
    pod 'RealmSwift'
    pod 'Quick'
    pod 'Nimble'
end

target 'KeymochiUITests' do
    pod 'Quick'
    pod 'Nimble'
end

target 'Keyboard' do
    pod 'Realm'
    pod 'RealmSwift'
    pod 'SwiftHEXColors'
    pod 'Firebase'
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'PAM', git: 'https://github.com/Keymochi/PAM.git', branch: 'master'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
