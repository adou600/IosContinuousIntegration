# Continuous Integration with Fastlane and Jenkins

Demo project which can be used to get familiar with continuous integration for iOS 9 applications.

Follow the steps outlined in this document to set up a minimal continuous integration workflow with Fastlane and Jenkins.

## Environment and Tools installed

 - Mac OS 10.11 El Capitan
 - Xcode 7.1
 - iOS 9 project with cocoapods setup for Alamofire 3.1.1
 - RubyGems 2.4.8
 - Fastlane 1.37.0
 - Jenkins 1.634
 - Cocoapods 0.39.0
 
## Why Fastlane? Why Jenkins?

If you want to have continuous integration for your project and get rid of the expensive build master, the first step is to find a way to build your code and run the tests with the command line. We will use [the awesome Fastlane](https://fastlane.tools) in this tutorial, but [Xcode bots](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/xcode_guide-continuous_integration/) could do it as well. 

Fastlane can easily be integrated into Jenkins, especially because the output produced by the executed lane is much more human readable than what `xcodebuild` gives. Besides, the commands are really simple to remember, with lots of sensible defaults and a clean syntax. See for example [Gym](https://github.com/fastlane/gym) and [Felix's blog](https://krausefx.com/blog/ios-tools). Jenkins is known to be very flexible, thanks to the enormous amount of maintained plugins available. Combining the flexibility of Jenkins and the power of Fastlane should allow to cover almost any scenario of delivery for your app. Xcode bots is however less extendable but might be slightly less tricky to configure. 

Fastlane provides a bunch of tools in the command line which help to automate the deployment of apps. Building the app and running the test is just one of the tasks that can be achieved by Fastlane. It comes in a form of a config file where the lanes are defined. Besides running the tests, several useful workflow can be imagined thanks to [various actions](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md). [Snapshot](https://github.com/KrauseFx/snapshot) allows to automatically take the screenshots of your app in several languages, [Deliver](https://github.com/KrauseFx/deliver) uploads your screenshots and metadata to the App Store, [Cert](https://github.com/fastlane/cert) helps to manage the iOS code signing certificates... And that's just the tip of the iceberg. 

Fastlane is an open source project developed by Felix Krause. As we can see on his repository, it seems that most of the commits come from him directly. He is however reviewing [lots of pull requests](https://github.com/KrauseFx/fastlane/pulls?q=is%3Aopen+is%3Apr) from the community and most of them are merged. The amount of work Felix has achieved alone is impressive. He has done a so incredible work that apparently, Apple [approached him to start an internship](http://www.uclan.ac.uk/news/apple_headhunts_uclan_student.php) in the Silicon Valley. Plus, in October 2015, [Fabric](https://get.fabric.io/ios), a widely used build tool for apps, announced that Fastlane will be [integrated in their tool and supported by their team](https://fabric.io/blog/welcoming-fastlane-to-fabric). But Fastlane will remain open source and free. Felix can now work 100% on Fastlane, which is a very good news if one want to make sure that it remains up to date after every iOS release.

Last but not least, the [Android developers](https://github.com/fastlane/fastlane/blob/master/docs/Android.md) can now also benefit from Fastlane. This brings the huge advantage of having one common tool for both platform. This, of course, helps to standardize the development process for your apps. *One tool to rule them all (they say)*. And again, Fastlane and Jenkins work well together, for Android development as well. 

Still not convinced about those tools? Just scroll down and look at the screenshots. You will, I hope, change your mind! 

## Install and configure fastlane for your project

We will use Fastlane to build the project and run the tests with the command line. Make sure the following works before starting to [configure Jenkins](## Install and configure Jenkins). 

### Install Fastlane

See the official documentation: https://github.com/fastlane/fastlane#installation

At the time of the writing: 
   - `sudo gem install fastlane --verbose`
   - `xcode-select --install`
   - From time to time, slow launch times of Fastlane can be experienced. As suggested in the [documentation](https://github.com/fastlane/fastlane#installation), a `gem cleanup` can fix the issue. 
   - The lane we will be using also requires Cocoapods gem to be installed: `sudo gem install cocoapods`

### Init Fastlane for your project

   - `cd IosContinuousIntegration`
   -  Initialize Fastlane with `fastlane init`. Make sure to enter an App Identifier, your apple ID and the scheme name of the app (IosContinuousIntegration). It is not necessary to setup deliver, snapshot and sigh for now because this tutorial focuses on continuous integration. Each of them can be initialized later on, for example with `deliver init`. Check the [full console output](https://dl.dropboxusercontent.com/u/664542/github-doc-images/fastlane-init-console-output.txt) for more details. 

### Create your testing lane

   - For an easier access to Fastlane files, drag the fastlane folder inside your Xcode project. 
![Drag fastlane folder into Xcode](https://dl.dropboxusercontent.com/u/664542/github-doc-images/drag-fastlane-folder.png)

   - Open fastlane/Fastfile and replace its content with a single lane running the tests using `scan`. The app is built using `gym`, before each lane. See [the full Fastfile](https://github.com/adou600/IosContinuousIntegration/blob/master/fastlane/Fastfile). The key parts are:
     - Build the app: `gym(scheme: "IosContinuousIntegration", workspace: "IosContinuousIntegration.xcworkspace", use_legacy_build_api: true)`
       - Specifying the `workspace` allows to build a project where cocoapoads are installed.
       - If a `workspace` is specified, the `scheme` is mandatory. There are indeed 3 schemes in this demo app: IosContinuousIntegration, Alamofire and Pods. 
       - `use_legacy_build_api` fixes an [issue of the Apple build tool](https://openradar.appspot.com/radar?id=4952000420642816) by using the old way of building and signing. 
     - Run the tests: `scan(device: "iPhone 6s")`
        - `device` allows to force the simulator to use to run the tests.
        - `scan` can be configured with the help of a [Scanfile](https://github.com/adou600/IosContinuousIntegration/blob/master/fastlane/Scanfile). In this example, it is used to set the scheme of the application: "IosContinuousIntegration".

   - The lane called `test` uses the action "increment_build_number" which requires a Build number set in Xcode. Set it by clicking on the target, Build Settings tab and search for CURRENT_PROJECT_VERSION
![Current project version in build settings](https://dl.dropboxusercontent.com/u/664542/github-doc-images/current-project-version.png)
*Where to set the current project version. Make sure "All" is selected in the header, and not "Basic".*

   - Make sure the lane is working by running `fastlane ios test`. Thanks to gym, an archive will be added in the Xcode organizer. The Unit and UI tests will also be executed in the simulator. 
![Fastlane console result](https://dl.dropboxusercontent.com/u/664542/github-doc-images/fastlane-console-result.png)
*Result output for the command `fastlane ios test`. 1 Unit Test and 1 UI Test have been executed.*

## Install and configure Jenkins

Now that you have a lane running the tests, you need a CI server executing it automatically for every commit.

Note: to be able to run tests for an iOS project, a Mac machine with Xcode and Fastlane installed is required. Thus, Jenkins has to be installed on a Mac. For simplification, the following steps will assume you install Jenkins on the same machine you write your code. But in a real-life setup, Jenkins would run on a different machine, so that every developer can see what made the tests fail. 

### Install jenkins

 - Install Jenkins: `brew update && brew install jenkins`
 - Start Jenkins: `jenkins`
 - Browse Jenkins on http://localhost:8080
 - Install Jenkins plugins which will help to checkout out code from a repository, display the results and notify a slack channel about the build status: 
   - Go to Manage Jenkins / Manage plugins / Available
   - Select the following plugins and click "Download and install after restart":
     - AnsiColor: show colored output of Fastlane log files
     - GIT: allow the use of Git as a build SCM
     - Slack Notification Plugin: can publish build status to Slack channels.
   - Restart Jenkins by checking "Restart Jenkins when installation is complete and no jobs are running". 
![Restart Jenkins](https://dl.dropboxusercontent.com/u/664542/github-doc-images/install-jenkins-plugins.png)
*What can be seen while installing a plugin.*

   - Make sure the plugins are installed. They should be visible in Manage Jenkins / Manage plugins / Installed.

### Create a build job

Create a build job which will start on every commit pushed to the repository.

 - New Item / Freestyle project, enter a build job name and click ok
![Create a build job](https://dl.dropboxusercontent.com/u/664542/github-doc-images/jenkins-build-job.png)
 - Configure Source Code Management by choosing GIT and entering the SSH URL of the repository (Github in the example).
![Configure SCM](https://dl.dropboxusercontent.com/u/664542/github-doc-images/source-code-management.png)
 - If you get a "Permission denied error", make sure the user running Jenkins has an SSH key set in the [Github profile](https://github.com/settings/ssh). See the doc on [help.github.com](https://help.github.com/articles/generating-ssh-keys/)
 - Configure Build Triggers to periodically check whether there is a new commit in the repo. We use here the polling approach from Jenkins to the repository. Push notifications from the repository to Jenkins is another way of doing it. See [the Git Plugin doc](https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin#GitPlugin-Pushnotificationfromrepository)
![Configure Build Triggers](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-trigger-config.png)

 - Configure AnsiColor to get the right colors in the console output of Jenkins. 
![Configure AnsiColor](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-env-config.png)

 - Configure Slack Notification Plugin so that every information about the build gets posted in a channel.
![Configure Slack Notifier](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-info-to-slack.png)

 - Add a build step which will run the lane:
![Add build step](https://dl.dropboxusercontent.com/u/664542/github-doc-images/add-build-step.png)

 - Configure the build step by writing the same command we ran locally `fastlane ios test`:
![Add build step](https://dl.dropboxusercontent.com/u/664542/github-doc-images/configure-build-step.png)

- Add a post-build action to enable Slack notifications
![Slack Post build](https://dl.dropboxusercontent.com/u/664542/github-doc-images/post-build-slack.png)

 - Click save to persist the changes.

### Configure Slack Integration

Don't forget to activate a Jenkins Integration for the wanted Slack channel in the Slack Settings: [https://your-team.slack.com/services](https://your-team.slack.com/services). 

You can also access it directly from the Slack channel, with "+ Add a service integration".
![Configure Slack Integration for Jenkins](https://dl.dropboxusercontent.com/u/664542/github-doc-images/slack-service-integration.png)
*A Slack channel right after creation, with the link to add a service integration*

Posting all the build info into a Slack channel allows the team to get informed about build failures. They can discuss about it and get notified when everything is back to normal. Slack works on every OS and [push notifications](https://slack.zendesk.com/hc/en-us/articles/201398457-Mobile-push-notifications) can be enable on the Slack's mobile app. 

![Why using Slack?](https://dl.dropboxusercontent.com/u/664542/github-doc-images/why-slack.png)
*Example of what can be achieved when using Slack notifications for every build*

### Test the build job

 - Click Build Now to make sure the build step is working. 
 - If everything worked as expected, you should see a blue bubble in the left of your build history in Jenkins.
![Build history](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-history-success.png)
*Example of a build history on Jenkins containing only 1 successful build*

 - By clicking on the build number, one can get information about the build, like the full console output log. 
 - As a final test, make a test fail in the project, commit and push the change. After max 1 minute, the build job should automatically start. After about a minute or two, the build history should contain a red bubble, identifying a failed build. 
 - Fix the test, commit and push again and make sure the Jenkins returns to blue.
![Build history with failed build](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-history-failed.png)
*Example of a build history on Jenkins, with 2 sussessful builds (#1 and #3) and 1 failed build (#2)*

 - Notifications should also have been sent to the configured slack channel.
![Slack Build Notifications](https://dl.dropboxusercontent.com/u/664542/github-doc-images/slack-integration-result.png)
*What you should see in your Slack channel after this manual test build*
 
### Next steps

Having a CI server for your project, you can now keep improving it incrementally... Sending emails in case of a broken build or configure authorizations to access Jenkins are widely used features on CI servers. A ton of Jenkins plugins are available for almost all your needs: [Jenkins Plugins Wiki](https://wiki.jenkins-ci.org/display/JENKINS/Plugins)

Setting up a CI Server for a project is a very important step. But in order to benefit from it and make it last the distance, the tests have to remain stable and maintainable. You want to make sure that every broken build means: "the last commit broke something", and not: "the test failed but I believe everything is still working because the tests are flaky". This is why using just the Xcode recorder to write your UI tests is not enough. Indeed, the generated code is very sensitive to every change made in the user interface. A common pattern in testing helping avoid it is the [Page Object pattern](http://martinfowler.com/bliki/PageObject.html). It comes from the Web technologies but can easily be adapted for iOS. The idea is to create an object which knows how to interact with the UI. This object is used by every test. The main advantage is clear: if the UI changes, the update needs to be done only to this object and all the test using this page (or this view) will benefit from the change. The Xcode test recorder can still be used to figure out how to interact with the UI, but the generated code needs then to go inside the corresponding Page Object and made more generic. The following article can be a good starting point: https://rnorth.org/11/automated-ui-testing-in-xcode-7. 

Happy delivery, and keep automating! 

# References

Those articles and books are good references to go deeper in this topic:
 - http://martinfowler.com/books/continuousDelivery.html
 - https://github.com/KrauseFx/fastlane/blob/master/docs/Jenkins.md
 - http://www.cimgf.com/2015/05/26/setting-up-jenkins-ci-on-a-mac-2/
 - https://rnorth.org/11/automated-ui-testing-in-xcode-7
 - https://krausefx.com/blog/fastlane-is-now-part-of-fabric
