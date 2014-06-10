//  JROmniFocus.h
//
// Acts as a wrapper object for omnifocus itself.
// Used to determine which version of OmniFocus is running
// (1, 2 or Pro), whether it's running, and to return the
// default document.
//
// Singleton object. Get the current application with
// +[OmniFocus instance];
//
//  Copyright (c) 2014 Jan-Yves Ruzicka. All rights reserved.

#import <Foundation/Foundation.h>

@class JROFObject, OmniFocusApplication, JRProject, JRTask;

typedef enum {JROmniFocusVersion1, JROmniFocusVersion2, JROmniFocusVersion2Pro} JROmniFocusVersion;

@interface JROmniFocus : NSObject {
    NSMutableArray *_projects, *_folders;
    NSMutableArray *_flattenedProjects, *_flattenedFolders, *_flattenedTasks;
    JROmniFocusVersion version;
}

@property OmniFocusApplication *application;
@property NSString *processString;
@property NSArray *excludedFolders;

#pragma mark Initializers and factories
-(id)init;
+(JROmniFocus *)instance;

#pragma mark Instance methods and properties
-(JROmniFocusVersion)version;

-(NSMutableArray *)folders;
-(NSMutableArray *)projects;

-(NSMutableArray *)flattenedFolders;
-(NSMutableArray *)flattenedProjects;
-(NSMutableArray *)flattenedTasks;

//Iterate through all objects in the tree
-(void)eachTask:(void (^)(JRTask *))function;
-(void)eachProject:(void (^)(JRProject *))function;

@end
