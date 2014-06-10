//
//  JRDatabase.m
//
//  Created by Jan-Yves on 3/12/13.
//  Copyright (c) 2013 Jan-Yves Ruzicka. All rights reserved.

#import "JRDatabase.h"

//Objects to save
#import "JROFObject.h"
#import "JRProject.h"
#import "JRTask.h"

//Database
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>

//Constants
//TKTKTK we must be able to abstract the query into its own class
static NSString *kJRProjectsUpdate = @"UPDATE projects SET name=?,ancestors=?,status=?completionDate=?,creationDate=? deferredDate=? WHERE ofid=?;";
static NSString *kJRProjectsInsert = @"INSERT INTO projects (name,ancestors,status,completionDate,creationDate,deferredDate,ofid) VALUES (?,?,?,?,?,?,?);";

static NSString *kJRTasksUpdate = @"UPDATE tasks SET name=?,projectID=?,projectName=?,ancestors=?,completionDate=?,creationDate=? WHERE ofid=?;";
static NSString *kJRTasksInsert = @"INSERT INTO tasks (name,projectID,projectName,ancestors,completionDate,creationDate,ofid) VALUES (?,?,?,?,?,?,?);";

@implementation JRDatabase

-(id)initWithLocation:(NSString *)location type:(JRDatabaseType)type {
    if (self = [super init]) {
        self.location = [location stringByStandardizingPath];
        self.projectsRecorded = 0;
        self.tasksRecorded = 0;
        _type = type;
    }
    return self;
}

-(void)dealloc {
    if (_database) [_database close];
}

+(id)databaseWithLocation:(NSString *)location type:(JRDatabaseType)type {
    return [[self alloc] initWithLocation:location type:type];
}

-(BOOL)canExist {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //Check dir exists
    NSArray *dirComponents = [self.location pathComponents];
    NSIndexSet *dirSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dirComponents.count-1)];
    NSString *dir = [[dirComponents objectsAtIndexes:dirSet] componentsJoinedByString:@"/"];
    
    if ([dir isEqualToString:@""]) //current dir
        return YES;
    
    BOOL isDir;
    BOOL fileExists = [fm fileExistsAtPath:dir isDirectory:&isDir];
    return (fileExists && isDir);
}

// Is the database currently in existence here able to accept input by this database?
// Returns:
// - JRDatabaseExactMatch:   Contains just the right tables to support this database
// - JRDatabaseSubset:       Contains the tables to support this database and more
// - JRDatabaseDoesNotExist: Database doesn't even exist.
// - JRDatabaseDoesNotMatch: Doesn't contain the right tables to support this database
-(JRDatabaseOverlap)overlapWithDatabaseFile {
    //Check to see if db exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:self.location])
        return JRDatabaseDoesNotExist;

    //We presume it's safe to open the file...
    //Check to see if it has every table we need
    FMResultSet *r = [self.database executeQuery:@"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"];
    NSMutableArray *tables = [NSMutableArray array];
    while ([r next]) [tables addObject:[r stringForColumnIndex:0]];

    if ([self requiresType:JRDatabaseTasks]) {
        if ([tables containsObject:@"tasks"])
            [tables removeObject:@"tasks"];
        else
            return JRDatabaseDoesNotMatch;
    }

    if ([self requiresType:JRDatabaseProjects]) {
        if ([tables containsObject:@"projects"])
            [tables removeObject:@"projects"];
        else
            return JRDatabaseDoesNotMatch;
    }

    return (tables.count == 0 ? JRDatabaseExactMatch : JRDatabaseSubset);
}

//Database fetcher
-(FMDatabase *)database {
    if (!_database) {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        BOOL newDB = (![fm fileExistsAtPath:self.location]);
        _database = [FMDatabase databaseWithPath:self.location];
        [_database open];
        if (newDB) [self populateDatabase];
    }
    return _database;
}

#pragma mark - Database methods
-(NSError *)purgeDatabase {
    NSError *err;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:self.location error:&err];

    if (!err)
        [self populateDatabase];

    return err;
}

-(NSError *)saveOFObject:(JROFObject *)o {
    if ([o isKindOfClass:[JRTask class]])
        return [self saveTask:(JRTask *)o];
    else if ([o isKindOfClass:[JRProject class]])
        return [self saveProject:(JRProject *)o];
    else {
        NSString *desc = [NSString stringWithFormat:@"JRDatabase tried to save a %@ to file. Can only save JRTasks and JRProjects", [o className]];
        NSError *err = [NSError errorWithDomain:NSMachErrorDomain
                                           code:1
                                       userInfo:@{NSLocalizedDescriptionKey: desc}];
        return err;
                                                                                    
    }
}

-(NSError *)saveTask:(JRTask *)t {
    //Check: are we trying to save tasks to a non-task database?
    if (![self requiresType:JRDatabaseTasks])
        return [NSError errorWithDomain: NSMachErrorDomain
                                   code:1
                               userInfo: @{NSLocalizedDescriptionKey: @"Trying to save a task to a non-task database."}];

    // UPDATE required?
    NSUInteger count = [self.database intForQuery:@"SELECT COUNT(*) FROM tasks WHERE ofid=?",t.id];
    NSString *query = (count > 0 ? kJRTasksUpdate : kJRTasksInsert);
        
    NSArray *args = @[
                     t.name,
                     t.projectID,
                     t.projectName,
                     t.ancestry,
                     (t.completionDate ? t.completionDate : @-1),
                     t.creationDate,
                     t.id];
    
    if (![self.database executeUpdate:query withArgumentsInArray:args])
        return [self.database lastError];
    else {
        self.tasksRecorded += 1;
        return nil;
    }
}

-(NSError *)saveProject:(JRProject *)p {
    //Check: are we trying to save tasks to a non-task database?
    if (![self requiresType:JRDatabaseProjects])
        return [NSError errorWithDomain: NSMachErrorDomain
                                   code:1
                               userInfo: @{NSLocalizedDescriptionKey: @"Trying to save a project to a non-project database."}];

    // UPDATE required?
    NSUInteger count = [self.database intForQuery:@"SELECT COUNT(*) FROM projects WHERE ofid=?",p.id];
    NSString *query = (count > 0 ? kJRProjectsUpdate : kJRProjectsInsert);
        
    NSArray *args = @[
                      p.name,
                      p.ancestry,
                      p.status,
                      (p.completionDate ? p.completionDate : @-1),
                      p.creationDate,
                      (p.deferredDate ? p.deferredDate : @-1),
                      p.id
                    ];
    
    if (![self.database executeUpdate:query withArgumentsInArray:args])
        return [self.database lastError];
    else {
        self.projectsRecorded += 1;
        return nil;
    }
}

#pragma mark - Private methods
-(void)populateDatabase {
    //Tasks
    if ([self requiresType: JRDatabaseTasks])
        [self.database update:@"CREATE TABLE tasks (id INTEGER PRIMARY KEY, name STRING, ofid STRING, projectID STRING, projectName STRING, ancestors STRING, creationDate DATE, completionDate DATE, deferredDate DATE);" withErrorAndBindings:nil];
    //Projects
    if ([self requiresType: JRDatabaseProjects])
        [self.database update:@"CREATE TABLE projects (id INTEGER PRIMARY KEY, name STRING, ofid STRING, ancestors STRING, status STRING,creationDate DATE, completionDate DATE, deferredDate DATE);" withErrorAndBindings:nil];
}

-(BOOL)requiresType:(JRDatabaseType) type {
    return ((self.type & type) == type);
}

@end
