# IosContinuousIntegration
Minimal setup which can be used to perform continuous integration for iOS 9 projects with Jenkins and Fastlane. 

## Environment and Tools
 - Mac OS 10.11 El Capitan
 - Xcode 7.0.1
 - iOS 9 project with cocoapods (Alamofire 3.0.0)
 - RubyGems 2.4.8
 

## Install and configure fastlane in your project

 - See the official documentation: https://github.com/KrauseFx/fastlane#installation
 - At the time of the writing: 
   - ```$ sudo gem install fastlane --verbose```
   - ```xcode-select --install```
 - Init Fastlane for your project
   - ```$ cd IosContinuousIntegration```
   -  Initialize fastlane with ```$ fastlane init```, making sur  to enter an App Identifier, your apple ID and the scheme name of the app. It is not necessary to setup deliver, snapshot and sigh for now. 
