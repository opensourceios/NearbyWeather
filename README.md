# NearbyWeather - Open Source Weather

![Language](https://img.shields.io/badge/language-Swift%204-orange.svg)
![License](https://img.shields.io/github/license/erikmartens/NearbyWeather.svg?style=flat)
[![](https://img.shields.io/badge/Twitter-@erik_martens-blue.svg)](https://twitter.com/erik_martens)

|List View|Map View|Detail View|
|:---:|:---:|:---:|
![](https://i.imgur.com/Fba7ppE.png) | ![](https://i.imgur.com/fgPbJVx.png) | ![](https://i.imgur.com/MdQJiLj.png)

## About the App
NearbyWeather is a simple weather app, that provides current weather information for nearby cities, as well for bookmarked locations. NearbyWeather uses the OpenWeatherMap api to download weather data. Additionally the OpenWeatherMaps location database is directly bootstrapped into the app for quick access.

With NearbyWeather you can:
- See current weather information for bookmarked and nearby places via a list and a map view
- Detailed weather information is offered in addition to the overviews
- Add places as bookmarks via OpenWeatherMaps weather-station data base
- Choose your preferred units (celsius/fahrenheit/kelvin & kilometres/miles)
- Access previously loaded data offline

> Please note that you need to supply your own OpenWeatherMap api key, in order to use the app. A free tier api key only allows for 60 requests per minute, which may only be sufficient for a single user. As the app is available at no charge and is open source, a paid tier api key can not be included. 

> Downloading data for a bookmarked location counts as one request. Downloading bulk data for nearby places also counts as a single request, regardless of the amount of results you choose. You can add bookmarks indefinitely, but for example exceeding the 60 requests limit with a free tier api key may result in a failure to download data (this scenario has not been tested and depends of the tier of your api key).

## Goals of this Project
NearbyWeather should help you as a reference for your iOS development. Whether you just started iOS development or want to learn more about Swift by seeing in action, this project is here for your guidance. Idealy you already have gained some experience or got your feet wet with mobile development. NearbyWeather is created to teach basic principles of iOS development, including but not limited to:
- Accessing and using the user's location
- Persisiting data
- Network requests
- Using 3rd party libraries via CocoaPods
- Using support scripts for creating bootstrapped resources
- Programming concepts such as delegation, closures, generics & extensions
- Swift language features such as codables
- Avoidance of retain cycles
- 3D touch (coming soon)
- Peek & pop (coming soon)
- Using various UIKit classes
- Using MapKit and customising maps
- Language localization

It therefore otherwise refrains from advanced concepts. The architecture is kept simple by using [Apple's recommended MVC pattern](https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html). This architecture is fine for a small projects like this one. For complex apps there are better options, such as MVVP, VIP (Clean Swift) or even VIPER. The chosen architecture may for example limit the testability of the project, but then again for simplicty sake there are no unit tests present at all. Additionally the app uses singeltons for all services and managers. This further hinders testing. A better approach to enable this would be dependency injection. Furthermore delegation is used only losely. 

## Support and Open Source
Support is provided at the given support link, including instructions to get started with the app. The app's source code is open source. You can download and contribute via GitHub. To learn more about the project, visit the support website.
