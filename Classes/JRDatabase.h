//
//  JRDatabase.h
//
//  Created by Jan-Yves on 3/12/13.
//  Copyright (c) 2013 Jan-Yves Ruzicka. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JROFObject,  JRProject, JRTask;
@class FMDatabase;

typedef enum {JRDatabaseProjects=1,JRDatabaseTasks=2} JRDatabaseType;
typedef enum {JRDatabaseExactMatch,JRDatabaseSubset,JRDatabaseDoesNotExist,JRDatabaseDoesNotMatch} JRDatabaseOverlap;

@interface JRDatabase : NSObject {
    FMDatabase *_database;
}

@property NSString *location;
@property NSUInteger projectsRecorded;
@property NSUInteger tasksRecorded;

@property (readonly) JRDatabaseType type;

-(id)initWithLocation:(NSString *)location type:(JRDatabaseType)type;
+(id)databaseWithLocation:(NSString *)location type:(JRDatabaseType)type;

//Can this database exist in the filesystem without creating additional folders?
-(BOOL)canExist;

//Is this database correctly formatted, given the type of database we're creating?
-(JRDatabaseOverlap)overlapWithDatabaseFile;

-(FMDatabase *)database;

-(NSError *)purgeDatabase;
-(NSError *)saveOFObject:(JROFObject *)o;
-(NSError *)saveTask:(JRTask *)t;
-(NSError *)saveProject:(JRProject *)p;
@end
