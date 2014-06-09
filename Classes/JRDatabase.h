//
//  JRDatabase.h
//
//  Created by Jan-Yves on 3/12/13.
//  Copyright (c) 2013 Jan-Yves Ruzicka. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JROFObject,  JRProject, JRTask;
@class FMDatabase;


@interface JRDatabase : NSObject {
    FMDatabase *_database;
}

@property NSString *location;
@property NSUInteger projectsRecorded;
@property NSUInteger tasksRecorded;

-(id)initWithLocation:(NSString *)location;
+(id)databaseWithLocation:(NSString *)location;

-(BOOL)isLegal;

-(FMDatabase *)database;

-(NSError *)purgeDatabase;
-(NSError *)saveOFObject:(JROFObject *)o;
-(NSError *)saveTask:(JRTask *)t;
-(NSError *)saveProject:(JRProject *)p;
@end
