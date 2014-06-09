//
//  JRTask.h
//
//  Created by Jan-Yves on 28/01/14.
//  Copyright (c) 2014 Jan-Yves Ruzicka. All rights reserved.
//

#import "JROFObject.h"
@class OmniFocusTask;
@class JRProject;

@interface JRTask : JROFObject {
    NSString *_name, *_id;
    NSString *_projectName, *_projectID;
    NSDate *_creationDate, *_completionDate, *_deferredDate;
    BOOL _completed;
}

@property (atomic,readonly) OmniFocusTask *task;

#pragma mark Initializer
-(id)initWithTask:(OmniFocusTask *)task parent:(JROFObject *)parent;
+(JRTask *)taskWithTask:(OmniFocusTask *)task parent:(JROFObject *)parent;
+(NSMutableArray *)tasksFromArray:(NSArray *)tasks parent:(JROFObject *)parent;

#pragma mark Properties
//Dates
-(NSDate *)creationDate;
-(NSDate *)deferredDate;
-(NSDate *)completionDate;

//Other
-(BOOL)completed;

//Project stuff
-(NSString *)projectName;
-(NSString *)projectID;
@end
