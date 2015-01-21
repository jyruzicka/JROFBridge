# JROFBridge CHANGELOG

## 0.2.6 - 2015-01-21

* [FIXED] Will no longer recognise applications with id "com.omnigroup.OmniFocus.Today" (OmniFocus' new widget).

## 0.2.5 - 2014-07-04

* [NEW] `JROmniFocus` now contains instance methods `ofVersion` and `buildNumber` to determine the version of OmniFocus it's talking to.

## 0.2.4 - 2014-06-30

* [FIXED] `-[JROmniFocus version]` now returns a sane and proper value.

## 0.2.3

* Changed name of values in `JROmniFocusVersion` enum: Changed `JROmniFocusVersion2` to `JROmniFocusVersion2Standard` to make it more obvious which version it is.

## 0.2.2

* Fixed a bug where projects with deferral dates in the past may still be marked "Deferred"

## 0.2.1

* Added `-[JRProject remainingTasks]` - only returns those tasks which aren't complete.
* Added `-[JRProject deferralType]` and `-[JRProject deferralLabel]` - determine whether the project or its first task (or neither) are deferred.

## 0.2.0

Initial release *to public*. Exciting stability improvements, overall more flexible code, even closures in some places.

## 0.1.0

Initial release.