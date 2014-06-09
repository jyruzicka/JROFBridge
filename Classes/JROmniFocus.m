//  JROmniFocus.m
//
//  Created by Jan-Yves on 6/06/14.
//  Copyright (c) 2014 Jan-Yves Ruzicka. All rights reserved.

#import "JROmniFocus.h"
#import "OmniFocus.h"

//Need to know about folders and projects
#import "JRFolder.h"
#import "JRProject.h"

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

+(id)instance {
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
            if (occurance.location != NSNotFound) { //string in the bundle identifier
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
    if (!version) {
        NSRange of2 = [self.processString rangeOfString:(NSString *)@"com.omnigroup.OmniFocus2"];
        if (of2.location == NSNotFound)
            version = JROmniFocusVersion1;
        else {
            @try {
                [self.application defaultDocument];
                return JROmniFocusVersion2Pro;
            }
            @catch (NSException *exception) {
                return JROmniFocusVersion2;
            }
        }
    }
}

-(NSMutableArray *)projects {
    if (!_projects) {
        _projects = [NSMutableArray array];
        for (OmniFocusProject *p in self.application.defaultDocument.projects) {
            JRProject *jrp = [JRProject projectWithProject:p parent:nil];
            [_projects addObject:jrp];
        }
    }
    return _projects;
}

-(NSMutableArray *)folders {
    if (!_folders) {
        _folders = [NSMutableArray array];
        for (OmniFocusFolder *f in self.application.defaultDocument.folders) {
            //Skip top-level folders with specific names
            if ([self.excludedFolders containsObject:f.name]) continue;
            
            JRFolder *jrf = [JRFolder folderWithFolder:f parent:nil];
            [_folders addObject:jrf];
        }
    }
    return _folders;
}

-(void)each:(void (^)(JROFObject *))function {
    for (JRFolder *f in self.folders)
        [f each:function];
    for (JRProject *p in self.projects)
        [p each:function];
}
@end
