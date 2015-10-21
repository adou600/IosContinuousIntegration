# Continuous Integration with Fastlane and Jenkins

Demo project which can be used to test continuous integration for iOS 9 applications.

Follow the steps outlined in this document to set up a minimal continuous integration workflow with Fastlane and Jenkins.

## Environment and Tools installed

 - Mac OS 10.11 El Capitan
 - Xcode 7.0.1
 - iOS 9 project with cocoapods setup for Alamofire 3.0.1
 - RubyGems 2.4.8
 - Fastlane 1.33.6
 - Jenkins 1.634
 
## Why Fastlane? Why Jenkins?

If you want to have continuous integration for your project and get rid of the expensive build master, the first step is to find a way to build your code and run the tests with the command line. We will use [the awesome fastlane](https://fastlane.tools) in this tutorial, but [Xcode bots](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/xcode_guide-continuous_integration/) could do it as well. 

Fastlane can easily be integrated into Jenkins especially because the output produced by the executed lane is much more human readable than the output produced by `xcodebuild`. See for example [Gym](https://github.com/fastlane/gym) and [Felix's blog](https://krausefx.com/blog/ios-tools). Jenkins is known to be very flexible, thanks to the enormous amount of maintained plugins available. Combining the flexibility of Jenkins and power of Fastlane should allow to cover almost any scenario of delivery for your app. Xcode bots is however a bit more rigid but might be slightly less tricky to configure. 

Fastlane provides a bunch of tools in the command line which can be used to automate the deployment of your apps. Building the app and running the test is just one of the task that can be achieved by Fastlane. It comes in a form of a config file where you define your lanes. Besides running the tests, several useful workflow can be imagined thanks to [various actions](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md). [Snapshot](https://github.com/KrauseFx/snapshot) allows to automatically take the screenshots of your app in several languages, [Deliver](https://github.com/KrauseFx/deliver) uploads your screenshots and metadata to the App Store, [Cert](https://github.com/fastlane/cert) helps manage the iOS code signing certificates,... And that's just the tip of the iceberg. 

Fastlane is an opensource project developed by Felix Krause. As we can see on his repository, it seems that most of the commits come from him directly. He is reviewing [lots of pull requests](https://github.com/KrauseFx/fastlane/pulls?q=is%3Aopen+is%3Apr) from the community and most of them are merged. In my opinion, we then have a quite low [bus factor](https://en.wikipedia.org/wiki/Bus_factor) for this project. What happens if our project delivery workflow is based on Fatlane and Felix starts to work for the concurrence or decides to stop working on that project? It is opensource indeed, but the amount of work he is achieving alone is incredible. So incredible that apparently, Apple [approached him to start an internship](http://www.uclan.ac.uk/news/apple_headhunts_uclan_student.php) in the silicon valley during fall 2015. I find myself dreaming of a Fastlane integrated in the official Apple toolchain, where every new iOS release directly comes with an updated and stable Fastlane... In the meantime, I still feel confident about using those tools, the community beeing so enthusiastic and reactive about it. 

## Install and configure fastlane for your project

We will use Fastlane to build the project and run the tests with the command line. Make sure this works fine before starting to [configure Jenkins](## Install and configure Jenkins). 

### Install fastlane

See the official documentation: https://github.com/KrauseFx/fastlane#installation

At the time of the writing: 
   - `sudo gem install fastlane --verbose`
   - `xcode-select --install`

### Init Fastlane for your project

   - [Fork](https://help.github.com/articles/fork-a-repo/) the IosContinuousIntegration repository, so that you can push changes to it later on. 
   - Clone the forked repository: `git clone git@github.com:YOUR-GITHUB-USERNAME/IosContinuousIntegration.git`
   - `cd IosContinuousIntegration`
   -  Initialize Fastlane with `fastlane init`, making sure to enter an App Identifier, your apple ID and the scheme name of the app. It is not necessary to setup deliver, snapshot and sigh for now because this tutorial focuses on continuous integration. You can init each of them later on, for example with `deliver init`. Check the [full console output](https://dl.dropboxusercontent.com/u/664542/github-doc-images/fastlane-init-console-output.txt) for more details. 

### Create your testing lane

   - For an easier access to Fastlane files, drag the fastlane folder inside your Xcode project. 
![Drag fastlane folder into Xcode](https://dl.dropboxusercontent.com/u/664542/github-doc-images/drag-fastlane-folder.png)

   - Open fastlane/Fastfile and replace its content with a single lane running the tests using `xctest`. The app is built using `gym`, before each lane. See [the full Fastfile](https://github.com/adou600/IosContinuousIntegration/blob/master/fastlane/Fastfile). The key parts are:
     - `gym(scheme: "IosContinuousIntegration", workspace: "IosContinuousIntegration.xcworkspace", use_legacy_build_api: true)`
       - Specifying the `workspace` allows to build a project using cocoapoads.
       - If a `workspace` is specified, the `scheme` is mandatory. There are indeed 3 schemes in this demo app: IosContinuousIntegration, Alamofire and Pods. 
       - `use_legacy_build_api` fixes an [issue of the Apple build tool](https://openradar.appspot.com/radar?id=4952000420642816) by using the old way of building and signing. 
     - `xctest(scheme: "IosContinuousIntegration", workspace: "IosContinuousIntegration.xcworkspace", destination: "name=iPhone 5s,OS=9.0")`
       - `destination` allows to specify which simulator will run the test. If you get an error while starting the simulator, try to [reset the simulators](http://stackoverflow.com/questions/2763733/how-to-reset-iphone-simulator). 
       - `workspace` and `scheme` need to be the same as for the gym command.

   - The lane called test uses the action "increment_build_number" which requires a Build number set in Xcode. Set it by clicking on the target, Build Settings tab and search for CURRENT_PROJECT_VERSION
![Current project version in build settings](https://dl.dropboxusercontent.com/u/664542/github-doc-images/current-project-version.png)
*Where to set the current project version. Make sure "All" is selected and not "Basic".*

   - Make sure the lane is working by running `fastlane ios test`. Thanks to gym, this will add an archive in the Xcode organizer and the Unit and UI tests will be executed. 
![Fastlane console result](https://dl.dropboxusercontent.com/u/664542/github-doc-images/fastlane-console-result.png)
*Abstract of the result output for the command `fastlane ios test`. 1 Unit Test and 1 UI Test have been executed.*

## Install and configure Jenkins

Now that you have a lane running your tests, you need a CI server which will allow you to automatically run `fastlane ios test` for every commit.

Note: to be able to run your tests for an iOS project, you will need a Mac with Xcode installed and Fastlane installed. Thus, Jenkins has to be installed on a Mac. For simplification, the following steps will assume you install Jenkins on the same machine you write your code. But in a real-life setup, Jenkins would run on a different machine, so that the tests can be executed for every commit in the repository and so thatb every developer can check what in the last commit made the tests fail through the Jenkins web server. 

### Install jenkins

 - Install Jenkins: `brew update && brew install jenkins`
 - Start Jenkins: `jenkins`
 - Browse Jenkins on http://localhost:8080
 - Install Jenkins plugins which will help you checkout out your code from Github, run the tests and display the results. 
   - Go to Manage Jenkins / Manage plugins / Available
   - Select the following plugins and click "Download and install after restart":
     - AnsiColor: show colored output of Fastline log files
     - GIT: allow the use of Git as a build SCM
     - Slack Notification Plugin: can publish build status to Slack channels.
   - Restart Jenkins by checking "Restart Jenkins when installation is complete and no jobs are running". 
![Restart Jenkins](https://dl.dropboxusercontent.com/u/664542/github-doc-images/install-jenkins-plugins.png)
*What you see after installing a plugin.*

   - Make sure the plugins are installed. They should be visible in Manage Jenkins / Manage plugins / Installed.

### Configure Slack Integration

Don't forget to activate a Jenkins Integration for the wanted Slack channel in the Slack Settings: [https://your-team.slack.com/services](https://your-team.slack.com/services). 

You can also access it directly from the channel, with "+ Add a service integration".
![Configure Slack Integration for Jenkins](https://dl.dropboxusercontent.com/u/664542/github-doc-images/slack-service-integration.png)
*A Slack channel right after creation, with the link "+ Add service integration"*

Posting all the build info into a Slack channel allows the team to get informed about build failures. They can discuss about it and get notified when everything is back to normal. Slack works on every OS and you can enable [push notifications](https://slack.zendesk.com/hc/en-us/articles/201398457-Mobile-push-notifications) on your mobile. 

![Why using Slack?](https://dl.dropboxusercontent.com/u/664542/github-doc-images/why-slack.png)
*Example of what you can achieve when using Slack notifications for every build*

### Create a build job

Create a build job which will start on every commit pushed to the repository.

 - New Item / Freestyle project, enter your build job name and click ok
![Create a build job](https://dl.dropboxusercontent.com/u/664542/github-doc-images/jenkins-build-job.png)
 - Configure Source Code Management by choosing GIT and entering the SSH URL of your repository (Github in the example).
![Configure SCM](https://dl.dropboxusercontent.com/u/664542/github-doc-images/source-code-management.png)
 - If you get a "Permission denied error", make sure the user running Jenkins has an SSH key set in the [Github profile](https://github.com/settings/ssh). See the doc on [help.github.com](https://help.github.com/articles/generating-ssh-keys/)
 - Configure Build Triggers to periodically check wether there is a new commit in the repo. We use here the polling approach from Jenkins to the repository. Push notifications from the repository to Jenkins is another way of doing it. See [the Git Plugin doc](https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin#GitPlugin-Pushnotificationfromrepository)
![Configure Build Triggers](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-trigger-config.png)

 - Configure AnsiColor to get the right colors in the console output of Jenkins. 
![Configure AnsiColor](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-env-config.png)

 - Configure Slack Notification Plugin so that every information about the build gets posted in a channel you watch.
![Configure Slack Notifier](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-info-to-slack.png)

 - Add a build step which will run the lane:
![Add build step](https://dl.dropboxusercontent.com/u/664542/github-doc-images/add-build-step.png)

 - Configure the build step by writing the same command we ran locally `fastlane ios test`:
![Add build step](https://dl.dropboxusercontent.com/u/664542/github-doc-images/configure-build-step.png)

- Add a post-build action to enable Slack notifications
![Slack Post build](https://dl.dropboxusercontent.com/u/664542/github-doc-images/post-build-slack.png)

 - Click save to persist the changes.

### Test the build job

 - Click Build Now to make sure the build step is working. 
 - If everything worked as expected, you should see a blue bubble in the left of your build history in Jenkins.
![Build history](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-history-success.png)
*Example of a build history on Jenkins containing only 1 successful build*

 - By clicking on the build number, you can obtain information about the build, like the full console output log. 
 - As a final test, make a test fail in your project, commit and push the change. After max 1 minute, the build job should automatically start. After a while, the build history should contain a red bubble, identifying a failed build. 
 - Fix the test, commit and push again and make sure the Jenkins build is blue again.
![Build history with failed build](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-history-failed.png)
*Example of a build history on Jenkins containing only 1 successful build*

 - Notifications should also have been sent to your configured slack channel.
![Slack Build Notifications](https://dl.dropboxusercontent.com/u/664542/github-doc-images/slack-integration-result.png)
*What you should see in your Slack channel after this manual test build*
 
### Next steps

Now that you have a running CI server for your project, you can continue improving it continuously... Sending emails in case of a broken build or setup authorization to access Jenkins are features widely used in CI servers. A ton of Jenkins plugins are available for almost all your needs: [Jenkins Plugins Wiki](https://wiki.jenkins-ci.org/display/JENKINS/Plugins)

# References

Those articles and books are good references to go deeper in this topic:
 - http://martinfowler.com/books/continuousDelivery.html
 - https://github.com/KrauseFx/fastlane/blob/master/docs/Jenkins.md
 - http://www.cimgf.com/2015/05/26/setting-up-jenkins-ci-on-a-mac-2/
 - https://rnorth.org/11/automated-ui-testing-in-xcode-7
