platform :ios, '9.0'

# ignore all warnings from all pods
inhibit_all_warnings!

use_frameworks!

def nearbyweather_pods
    pod 'PKHUD'
    pod 'RainyRefreshControl'
    pod 'TextFieldCounter', :git => 'https://github.com/serralvo/TextFieldCounter.git', :branch => 'master'
    pod 'Alamofire'
    pod 'SDWebImage'
end

target 'NearbyWeather' do
    nearbyweather_pods
end  

target 'NearbyWeatherTests' do
  nearbyweather_pods
end
