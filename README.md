# Continuous Integration with Fastlane and Jenkins

This is the demo project linked to the blog article available on the [Zühlke Blog](http://blog.zuehlke.com/en/continuous-integration-for-mobile-apps-with-fastlane-and-jenkins/). 

Follow the steps outlined in this document to set up a minimal continuous integration workflow with Fastlane and Jenkins.

## Environment and Tools installed

 - Mac OS 10.11 El Capitan
 - Xcode 7.1
 - iOS 9 project with cocoapods setup for Alamofire 3.1.1
 - RubyGems 2.4.8
 - Fastlane 1.37.0
 - Jenkins 1.634
 - Cocoapods 0.39.0

## Install and configure fastlane for your project

Before installing the CI server, the lane needs to run on your machine. Make sure the following works before starting to [configure Jenkins](## Install and configure Jenkins). 

### Install Fastlane

See the official documentation: https://github.com/fastlane/fastlane#installation

At the time of the writing: 
   - `sudo gem install fastlane --verbose`
   - `xcode-select --install`
   - If you experience slow launch times, try  `gem cleanup`
   - The lane we will be using also requires Cocoapods to be installed: `sudo gem install cocoapods`

### Init Fastlane for your project

Initialize Fastlane with `fastlane init`, in the root of your Xcode project. Enter an App Identifier, your apple ID and the scheme name of the App. If you want to start simple, do not setup deliver, snapshot and sigh. They can be initialized later on, for example with `deliver init`. Check the [full console output](https://dl.dropboxusercontent.com/u/664542/github-doc-images/fastlane-init-console-output.txt) of my installtion for more details.

### Create your testing lane
For an easier access to Fastlane files, drag the fastlane folder inside your Xcode project. 
![Drag fastlane folder into Xcode](https://dl.dropboxusercontent.com/u/664542/github-doc-images/drag-fastlane-folder.png)

Open fastlane/Fastfile and create a simple testing lane. These are the key elements:

 - Build the app with: `gym(scheme: "IosContinuousIntegration", workspace: "IosContinuousIntegration.xcworkspace", use_legacy_build_api: true)`
   - `workspace` allows to build a project where cocoapoads are installed.
   -	if a `workspace` is specified, the `scheme` is mandatory. There are indeed 3 schemes in this demo app: IosContinuousIntegration, Alamofire and Pods.
   - `use_legacy_build_api` fixes an [issue of the Apple build tool](https://openradar.appspot.com/radar?id=4952000420642816)

 - Run the tests with: `scan(device: "iPhone 6s")`
   -	`device` defines which simulator will run the tests
   - `scan` can be configured through a [Scanfile](https://github.com/adou600/IosContinuousIntegration/blob/master/fastlane/Scanfile). In this example, it is used to set the scheme of the application.

The lane called `test` uses the action increment_build_number which requires a Build number set in Xcode. Set it by clicking on the target / Build Settings tab and search for CURRENT_PROJECT_VERSION

![Current project version in build settings](https://dl.dropboxusercontent.com/u/664542/github-doc-images/current-project-version.png)
*Set the current project version in Xcode. Make sure "All" is selected in the header, and not "Basic".*

Make sure the lane is working by running `fastlane ios test`. Thanks to gym, an archive will be added in the Xcode organizer. The Unit and UI tests will also be executed in the simulator.
![Fastlane console result](https://dl.dropboxusercontent.com/u/664542/github-doc-images/fastlane-console-result.png)
*Result output for the command `fastlane ios test`. 1 Unit Test and 1 UI Test have been executed.*

## Install and configure Jenkins

Now that you have a lane running the tests, you need a CI server executing it automatically for every commit.

*Note*: to be able to run tests for an iOS project, you need a Mac with Xcode and Fastlane installed. In a real-life setup, Jenkins runs on a centralized server, where every developer can check the current state of the project.

### Install jenkins

 - Install Jenkins: `brew update && brew install jenkins`
 - Start Jenkins: `jenkins`
 - Browse Jenkins on http://localhost:8080
 - Install Jenkins plugins: 
   - On http://localhost:8080, go to Manage Jenkins / Manage plugins / Available
   - Search for the following plugins and click "Download and install after restart":
     - AnsiColor: show colored output of Fastlane log files
     - GIT: allow the use of Git as a build SCM
     - Slack Notification Plugin: can publish build status to Slack channels.
   - Restart Jenkins by checking "Restart Jenkins when installation is complete and no jobs are running". 
![Restart Jenkins](https://dl.dropboxusercontent.com/u/664542/github-doc-images/install-jenkins-plugins.png)
*What can be seen while installing a plugin.*
   -	The installed plugins are visible in Manage Jenkins / Manage plugins / Installed.

### Create a build job

The build job is what will start the lane for every new commit pushed to the repository.

 - New Item / Freestyle project, enter a build job name and click ok
![Create a build job](https://dl.dropboxusercontent.com/u/664542/github-doc-images/jenkins-build-job.png)

 - Configure Source Code Management by choosing GIT and entering the SSH URL of the repository.
![Configure SCM](https://dl.dropboxusercontent.com/u/664542/github-doc-images/source-code-management.png)

 - If you get a Permission denied error, make sure the user running Jenkins has an SSH key set in his [Github profile](https://help.github.com/articles/generating-ssh-keys/). 

 - Configure Build Triggers to periodically check whether there is a new commit in the repo. We use here the polling approach from Jenkins to the repository. [Push notifications](https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin#GitPlugin-Pushnotificationfromrepository) from the repository to Jenkins is another alternative.
![Configure Build Triggers](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-trigger-config.png)

 - Configure AnsiColor to get the right colors in the console output of Jenkins. 
![Configure AnsiColor](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-env-config.png)

 - Configure Slack Notification Plugin so that every information about the build gets posted in a channel.
![Configure Slack Notifier](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-info-to-slack.png)

 - Add a build step which will run the lane:
![Add build step](https://dl.dropboxusercontent.com/u/664542/github-doc-images/add-build-step.png)

 - Configure the build step by writing the same command we ran locally:
![Add build step](https://dl.dropboxusercontent.com/u/664542/github-doc-images/configure-build-step.png)

- Add a post-build action to enable Slack notifications
![Slack Post build](https://dl.dropboxusercontent.com/u/664542/github-doc-images/post-build-slack.png)

 - Click save to persist the changes.

### Configure Slack Integration

Don't forget to activate a [Jenkins Integration](https://slack.com/integrations) in your Slack channel.

![Configure Slack Integration for Jenkins](https://dl.dropboxusercontent.com/u/664542/github-doc-images/slack-service-integration.png)
*A Slack channel right after creation, with the link to add a service integration*

Posting all the build info into a Slack channel allows the team to get informed about build failures. They can discuss about it and get notified when everything is back to normal. Slack works on every OS and [push notifications](https://slack.zendesk.com/hc/en-us/articles/201398457-Mobile-push-notifications) can be enable on the Slack's mobile app. 

![Why using Slack?](https://dl.dropboxusercontent.com/u/664542/github-doc-images/why-slack.png)
*Example of what can be achieved when using Slack notifications for every build*

### Test the build job

 - On Jenkins Webapp, click Build Now to make sure the build step is working.
 - If everything worked as expected, you should see a blue bubble in the left of your build history in Jenkins.
![Build history](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-history-success.png)
*Example of a build history on Jenkins containing only 1 successful build*

 - Click on the build number to get more information like the full console output. 
 - Notifications should also have been sent to the configured slack channel.
 ![Slack Build Notifications](https://dl.dropboxusercontent.com/u/664542/github-doc-images/slack-integration-result.png)
*What you should see in your Slack channel after this manual test build*
 - As a final test, find a way to make your tests fail, and then commit and push the change. After max 1 minute, the build job should automatically start. After about a minute or two, the build history should contain a red bubble, identifying a failed build. 
 - Fix the test, commit and push again and make sure the Jenkins returns to blue.
![Build history with failed build](https://dl.dropboxusercontent.com/u/664542/github-doc-images/build-history-failed.png)
*Example of a build history on Jenkins, with 2 sussessful builds (#1 and #3) and 1 failed build (#2)*


# References

 - Continous Delivery Book, by Jez Humble and David Farley: http://martinfowler.com/books/continuousDelivery.html
 - Integrate Jenkins and Fastlane, by Felix Krause: https://github.com/KrauseFx/fastlane/blob/master/docs/Jenkins.md
 - Setting up Jenkins on a Mac, by Eric Cerney: http://www.cimgf.com/2015/05/26/setting-up-jenkins-ci-on-a-mac-2/
 - Automated UI testing in Xcode 7, by Richard North: https://rnorth.org/11/automated-ui-testing-in-xcode-7
 - Fastlane is now part of Fabric, by Felix Krause: https://krausefx.com/blog/fastlane-is-now-part-of-fabric
 - Apple headhunts UCLAN student: http://www.uclan.ac.uk/news/apple_headhunts_uclan_student.php
