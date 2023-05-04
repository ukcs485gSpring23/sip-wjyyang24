<!--
Name of your final project
-->
# Sip
![Swift](https://img.shields.io/badge/swift-5.5-brightgreen.svg) ![Xcode 13.2+](https://img.shields.io/badge/xcode-13.2%2B-blue.svg) ![iOS 15.0+](https://img.shields.io/badge/iOS-15.0%2B-blue.svg) ![watchOS 8.0+](https://img.shields.io/badge/watchOS-8.0%2B-blue.svg) ![CareKit 2.1+](https://img.shields.io/badge/CareKit-2.1%2B-red.svg) ![ci](https://github.com/netreconlab/CareKitSample-ParseCareKit/workflows/ci/badge.svg?branch=main)

## Description
<!--
Give a short description on what your project accomplishes and what tools is uses. Basically, what problems does it solve and why it's different from other apps in the app store.
-->
Sip is an app which helps users form healthy habits through quick tasks that anyone can complete. Sip strives to facilitate an environment for self improvement through positivity and constant encouragement.

### Demo Video
<!--
Add the public link to your YouTube or video posted elsewhere.
-->
To learn more about this application, watch the video below:

<a href="http://www.youtube.com/watch?feature=player_embedded&v=mib_YioKAQQ
" target="_blank"><img src="http://img.youtube.com/vi/mib_YioKAQQ/0.jpg" 
alt="Sample demo video" width="240" height="180" border="10" /></a>

### Designed for the following users
<!--
Describe the types of users your app is designed for and who will benefit from your app.
-->
Sip is designed for people who want a smart application to guide them through the process of building healthy habits. As opposed to traditional note-taking or reminder apps, Sip's premade tasks, as well as its capability to allow users to create their own tasks, hold the user's hand throughout their usage. Sip is not designed for those who need a hyper-capable productivity app, it's for those who just need a little encouragement throughout their week to constantly improve themselves.

<!--
In addition, you can drop screenshots directly into your README file to add them to your README. Take these from your presentations.
-->
<image width="299" alt="Login View" src="https://user-images.githubusercontent.com/88963440/236204930-94ef81bc-b56b-4a1d-9cf1-b83263be6d6e.png"><image width="299" alt="Care View 1" src="https://user-images.githubusercontent.com/88963440/236204877-c0fd9529-9df3-4c77-80aa-249d9828e6eb.png"><image width="299" alt="Care View 2" src="https://user-images.githubusercontent.com/88963440/236204908-b2821bf0-f0ec-4d44-906e-35b275c5e1f6.png"><image width="299" alt="Insights View" src="https://user-images.githubusercontent.com/88963440/236204958-af549ac5-f5d9-4aaa-9bf1-605951ad4400.png"><image width="299" alt="Contacts View" src="https://user-images.githubusercontent.com/88963440/236204920-77c50ea7-92a8-41c3-b20d-5f4eaee0b81f.png"><image width="299" alt="Profile View" src="https://user-images.githubusercontent.com/88963440/236205045-f8261fc0-e603-401c-b89c-c1b44359454c.png"><image width="299" alt="Add Task View" src="https://user-images.githubusercontent.com/88963440/236204851-a7a76606-2fc8-49e2-8c62-a40a6b3d0d96.png">

<!--
List all of the members who developed the project and
link to each members respective GitHub profile
-->
Developed by: 
- [Wesley Yang](https://github.com/wjyyang24) - `University of Kentucky`, `Computer Science`

ParseCareKit synchronizes the following entities to Parse tables/classes using [Parse-Swift](https://github.com/parse-community/Parse-Swift):

- [x] OCKTask <-> Task
- [x] OCKHealthKitTask <-> HealthKitTask 
- [x] OCKOutcome <-> Outcome
- [x] OCKRevisionRecord.KnowledgeVector <-> Clock
- [x] OCKPatient <-> Patient
- [x] OCKCarePlan <-> CarePlan
- [x] OCKContact <-> Contact

**Use at your own risk. There is no promise that this is HIPAA compliant and we are not responsible for any mishandling of your data**

<!--
What features were added by you, this should be descriptions of features added from the [Code](https://uk.instructure.com/courses/2030626/assignments/11151475) and [Demo](https://uk.instructure.com/courses/2030626/assignments/11151413) parts of the final. Feel free to add any figures that may help describe a feature. Note that there should be information here about how the OCKTask/OCKHealthTask's and OCKCarePlan's you added pertain to your app.
-->
## Contributions/Features
- Featured Tip View with link to tips on forming habits
- Daily Sleep Amount and Quality Check-in
- Daily Water Consumption Goals
- Basic Beginner Workout Plan with 3 sets of exercises
- Diet Goals for consuming important food groups
- Encouragement to eat breakfast daily
- Reminders to move and stretch
- Step, Heart Rate, and Stair Trackers
- Informative Card on planning your day
- Sugary Drink Tracker
- Insights View showing data on all aforementioned tasks
- Full Contacts View with search and adding capabilities
- Profile View with capabilities to edit user info and profile picture
- Users can add their own tasks (CareKit and HealthKit)
- 4 Care Plans to help organize tasks

## Final Checklist
<!--
This is from the checkist from the final [Code](https://uk.instructure.com/courses/2030626/assignments/11151475). You should mark completed items with an x and leave non-completed items empty
-->
- [x] Signup/Login screen tailored to app
- [x] Signup/Login with email address
- [x] Custom app logo
- [x] Custom styling
- [x] Add at least **5 new OCKTask/OCKHealthKitTasks** to your app
  - [x] Have a minimum of 7 OCKTask/OCKHealthKitTasks in your app
  - [x] 3/7 of OCKTasks should have different OCKSchedules than what's in the original app
- [x] Use at least 5/7 card below in your app
  - [x] InstructionsTaskView - typically used with a OCKTask
  - [x] SimpleTaskView - typically used with a OCKTask
  - [x] Checklist - typically used with a OCKTask
  - [x] Button Log - typically used with a OCKTask
  - [ ] GridTaskView - typically used with a OCKTask
  - [x] NumericProgressTaskView (SwiftUI) - typically used with a OCKHealthKitTask
  - [ ] LabeledValueTaskView (SwiftUI) - typically used with a OCKHealthKitTask
- [x] Add the LinkView (SwiftUI) card to your app
- [x] Replace the current TipView with a class with CustomFeaturedContentView that subclasses OCKFeaturedContentView. This card should have an initializer which takes any link
- [x] Tailor the ResearchKit Onboarding to reflect your application
- [x] Add tailored check-in ResearchKit survey to your app
- [x] Add a new tab called "Insights" to MainTabView
- [x] Replace current ContactView with Searchable contact view
- [x] Change the ProfileView to use a Form view
- [x] Add at least two OCKCarePlan's and tie them to their respective OCKTask's and OCContact's 

## Wishlist features
<!--
Describe at least 3 features you want to add in the future before releasing your app in the app-store
-->
1. Social features for friendly competition
2. Ability to delete tasks
3. Ability to import images into tasks

## Challenges faced while developing
<!--
Describe any challenges you faced with learning Swift, your baseline app, or adding features. You can describe how you overcame them.
-->

## Setup Your Parse Server

### Heroku
The easiest way to setup your server is using the [one-button-click](https://github.com/netreconlab/parse-hipaa#heroku) deplyment method for [parse-hipaa](https://github.com/netreconlab/parse-hipaa).


## View your data in Parse Dashboard

### Heroku
The easiest way to setup your dashboard is using the [one-button-click](https://github.com/netreconlab/parse-hipaa-dashboard#heroku) deplyment method for [parse-hipaa-dashboard](https://github.com/netreconlab/parse-hipaa-dashboard).
