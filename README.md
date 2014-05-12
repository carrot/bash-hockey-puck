Bash-Hockey-Puck
================

Purpose
-------

Bash-Hockey-Puck is a Bash script that allows an Android Application to be easily versioned + uploaded to HockeyApp.

Dependencies
------------
 
- Gradle 
  * [Install from gradle.org](http://www.gradle.org/installation) 
- HockeyApp: Puck 
  * Install [HockeyApp 2.0+ for Mac](http://hockeyapp.net/releases/mac/)
  * HockeyApp > Preferences > General > Helper:Install 

Setup
-----

- All you need to do is place this script in your application's root and update the variables, then you're good to go. 
- Ensure your manifest has something like android:versionCode="1" if you want versioning to work.