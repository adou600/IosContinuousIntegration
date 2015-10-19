# IosContinuousIntegration
Minimal setup which can be used to perform continuous integration for iOS 9 projects with Jenkins and Fastlane. 

## Environment and Tools
 - Mac OS 10.11 El Capitan
 - Xcode 7.0.1
 - iOS 9 project with cocoapods (Alamofire 3.0.0)
 - RubyGems 2.4.8
 - Fastlane 1.33.4
 

## Install and configure fastlane in your project

 - See the official documentation: https://github.com/KrauseFx/fastlane#installation
 - At the time of the writing: 
   - ```$ sudo gem install fastlane --verbose```
   - ```xcode-select --install```
 - Init Fastlane for your project
   - ```$ cd IosContinuousIntegration```
   -  Initialize fastlane with ```$ fastlane init```, making sur  to enter an App Identifier, your apple ID and the scheme name of the app. It is not necessary to setup deliver, snapshot and sigh for now. 

```
My-MacBook-Pro:IosContinuousIntegration adou600$ fastlane init
[09:01:49]: This setup will help you get up and running in no time.
[09:01:49]: First, it will move the config files from `deliver` and `snapshot`
[09:01:49]: into the subfolder `fastlane`.

[09:01:49]: fastlane will check what tools you're already using and set up
[09:01:49]: the tool automatically for you. Have fun! 
Do you want to get started? This will move your Deliverfile and Snapfile (if they exist) (y/n)
y
Do you have everything commited in version control? If not please do so! (y/n)
y
[09:02:39]: Created new folder './fastlane'.
[09:02:39]: ------------------------------
[09:02:39]: To not re-enter your username and app identifier every time you run one of the fastlane tools or fastlane, these will be stored from now on.
App Identifier (com.krausefx.app): ch.adriennicolet.ios.IosContinuousIntegration
Your Apple ID (fastlane@krausefx.com): adrien.nicolet@gmail.com
[09:03:00]: Created new file './fastlane/Appfile'. Edit it to manage your preferred app metadata information.
Do you want to setup 'deliver', which is used to upload app screenshots, app metadata and app updates to the App Store? (y/n)
n
Do you want to setup 'snapshot', which will help you to automatically take screenshots of your iOS app in all languages/devices? (y/n)
n
Do you want to use 'sigh', which will maintain and download the provisioning profile for your app? (y/n)
n
Optional: The scheme name of your app (If you don't need one, just hit Enter): IosContinuousIntegration
[09:04:35]: 'deliver' not enabled.
[09:04:35]: 'snapshot' not enabled.
[09:04:35]: 'xctool' not enabled.
[09:04:35]: 'cocoapods' enabled.
[09:04:35]: 'carthage' not enabled.
[09:04:35]: 'sigh' not enabled.
[09:04:35]: Created new file './fastlane/Fastfile'. Edit it to manage your own deployment lanes.
[09:04:35]: fastlane will send the number of errors for each action to
[09:04:35]: https://github.com/fastlane/enhancer to detect integration issues
[09:04:35]: No sensitive/private information will be uploaded
[09:04:35]: You can disable this by adding `opt_out_usage` to your Fastfile
[09:04:35]: Successfully finished setting up fastlane
```

   - For an easier access to Fastlane files, drag the fastlane folder inside your Xcode project. 
      ![Drag fastlane folder Xcode](https://dl.dropboxusercontent.com/u/664542/github-doc-images/drag-fastlane-folder.png)
   - Open fastlane/Fastfile and replace its content with a single lane running the tests using `xctest`. The app is build using `gym`, before each lane. 
```Ruby
# Customise this file, documentation can be found here:
# https://github.com/KrauseFx/fastlane/tree/master/docs
# All available actions: https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md
# can also be listed using the `fastlane actions` command

# Change the syntax highlighting to Ruby
# All lines starting with a # are ignored when running `fastlane`

# By default, fastlane will send which actions are used
# No personal data is shared, more information on https://github.com/fastlane/enhancer
# Uncomment the following line to opt out
#opt_out_usage

# If you want to automatically update fastlane if a new version is available:
update_fastlane

# This is the minimum version number required.
# Update this, if you use features of a newer version
fastlane_version "1.33.4"

default_platform :ios


platform :ios do

  before_all do
    cocoapods
    increment_build_number
    gym(scheme: "IosContinuousIntegration", workspace: "IosContinuousIntegration.xcworkspace", use_legacy_build_api: true)
  end

  desc "Runs all the tests"
  lane :test do
    xctest(scheme: "IosContinuousIntegration", workspace: "IosContinuousIntegration.xcworkspace", destination: "name=iPhone 5s,OS=9.0")
  end

  after_all do |lane|

  end

  error do |lane, exception|
    say "error in lane! "
  end

end

# More information about multiple platforms in fastlane:
# https://github.com/KrauseFx/fastlane/blob/master/docs/Platforms.md
```
   - This lane uses the action "increment_build_number" which requires a Build number set in Xcode. Set it by clicking on the target, Build Settings tab and search for CURRENT_PROJECT_VERSION
![Current project version in build settings](https://dl.dropboxusercontent.com/u/664542/github-doc-images/current-project-version.png)
   - Make sure the lane is working by running `fastlane ios test`. Thanks to gym, it will add an archive in the Xcode organizer and the Unit and UI tests will be executed. 
```
... 
[10:18:42]: [SHELL]: 
[10:18:42]: [SHELL]: 	 Executed 1 test, with 0 failures (0 unexpected) in 0.003 (0.005) seconds
[10:18:42]: [SHELL]: .
[10:18:42]: [SHELL]: 
[10:18:42]: [SHELL]: 	 Executed 1 test, with 0 failures (0 unexpected) in 11.777 (11.778) seconds
[10:18:42]: [SHELL]: 

+------+-------------------------------------+-------------+
|                     fastlane summary                     |
+------+-------------------------------------+-------------+
| Step | Action                              | Time (in s) |
+------+-------------------------------------+-------------+
| 1    | update_fastlane                     | 10          |
| 2    | Verifying required fastlane version | 0           |
| 3    | default_platform                    | 0           |
| 4    | cocoapods                           | 3           |
| 5    | increment_build_number              | 0           |
| 6    | gym                                 | 39          |
| 7    | xctest                              | 22          |
+------+-------------------------------------+-------------+

[10:18:42]: fastlane.tools finished successfully 🎉
```
