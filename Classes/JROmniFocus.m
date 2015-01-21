//  JROmniFocus.m
//
//  Created by Jan-Yves on 6/06/14.
//  Copyright (c) 2014 Jan-Yves Ruzicka. All rights reserved.

#import "JROmniFocus.h"
#import "OmniFocus.h"

//Need to know about folders and projects
#import "JRFolder.h"
#import "JRProject.h"
#import "JRTask.h"

//All OmniFocus processes start with this string
static const NSString *kJRIdentifierPrefix = @"com.omnigroup.OmniFocus";

//Store instance of OmniFocus
static JROmniFocus *kJRInstance;

//String identifying the current running OmniFocus instance. Accessed via +[JROmniFocus processString]
static NSString *kJRProcessString;

@implementation JROmniFocus

#pragma mark Initializers and factories

-(id)init {
    if (!kJRInstance && [JROmniFocus isRunning]) {
        self = [super init];
        self.processString = [JROmniFocus processString];
        self.application = [JROmniFocus applicationFromString:self.processString];
    }
    else
        self = kJRInstance;
    return self;
}

+(JROmniFocus *)instance {
    if (!kJRInstance)
        return [[self alloc] init];
    else
        return kJRInstance;
}

#pragma mark - Private class methods
+(NSString *)processString {
    if (!kJRProcessString) {
        NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
        for (NSRunningApplication *app in apps) {
            if (!app.bundleIdentifier) continue;
            NSRange occurance = [app.bundleIdentifier rangeOfString:(NSString *)kJRIdentifierPrefix];
            if (
                occurance.location != NSNotFound &&
                ![app.bundleIdentifier isEqualToString: @"com.omnigroup.OmniFocus.Today"
            ) { //string in the bundle identifier, not omnifocus.today (widget)
                kJRProcessString = app.bundleIdentifier;
                break;
            }
        }
        if (!kJRProcessString) kJRProcessString = @"";
    }
    return kJRProcessString;
}

+(BOOL)isRunning{
    return (![self.processString isEqualToString:@""]);
}

+(OmniFocusApplication *)applicationFromString:(NSString *)string {
    if ([self isRunning])
        return (OmniFocusApplication *) [SBApplication applicationWithBundleIdentifier:string];
    else
        return nil;
}

#pragma mark - Instance methods and properties

-(JROmniFocusVersion)version {
    if (!_version) {
        NSRange of2 = [self.processString rangeOfString:(NSString *)@"com.omnigroup.OmniFocus2"];
        if (of2.location == NSNotFound)
            _version = JROmniFocusVersion1;
        else {
            @try {
                [self.application defaultDocument];
                _version = JROmniFocusVersion2Pro;
            }
            @catch (NSException *exception) {
                _version = JROmniFocusVersion2Standard;
            }
        }
    }
    return _version;
}

-(NSString *)ofVersion {
    if (!_ofVersion)
        _ofVersion = self.application.version;
    return _ofVersion;
}

-(NSString *)buildNumber {
    if (!_buildNumber)
        _buildNumber = self.application.buildNumber;
    return _buildNumber;
}

-(NSMutableArray *)projects {
    if (!_projects)
        _projects = [JRProject projectsFromArray:self.application.defaultDocument.projects parent:nil];
    return _projects;
}

-(NSMutableArray *)flattenedProjects {
    if (!_projects)
        _projects = [JRProject projectsFromArray:self.application.defaultDocument.flattenedProjects parent:nil];
    return _projects;
}

-(NSMutableArray *)folders {
    if (!_folders)
        _folders = [JRFolder foldersFromArray: self.application.defaultDocument.folders parent: nil excluding: self.excludedFolders];
    return _folders;
}

-(NSMutableArray *)flattenedFolders {
    if (!_flattenedFolders)
        _folders = [JRFolder foldersFromArray: self.application.defaultDocument.flattenedFolders parent: nil excluding: self.excludedFolders];
    return _flattenedFolders;        
}

-(NSMutableArray *)flattenedTasks {
    if (!_flattenedTasks)
        _flattenedTasks = [JRTask tasksFromArray: self.application.defaultDocument.flattenedTasks parent: nil];
    return _flattenedTasks;
}

-(void)eachTask:(void (^)(JRTask *))function {
    for (JRFolder *f in self.folders)
        [f eachTask:function];
    for (JRProject *p in self.projects)
        [p eachTask:function];
}

-(void)eachProject:(void (^)(JRProject *))function {
    for (JRFolder *f in self.folders)
        [f eachProject:function];
    for (JRProject *p in self.projects)
        function(p);
}

@end
