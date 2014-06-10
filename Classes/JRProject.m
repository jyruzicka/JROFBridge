//
//  JRProject.m
//  of-store
//
//  Created by Jan-Yves on 28/01/14.
//  Copyright (c) 2014 Jan-Yves Ruzicka. All rights reserved.
//

#import "JROmniFocus.h"
#import "JRProject.h"
#import "OmniFocus.h"

//Children
#import "JRTask.h"

@implementation JRProject

#pragma mark Initializer
-(id)initWithProject:(OmniFocusProject *)project parent:(JROFObject *)parent {
    if (self = [super initWithParent:parent]) {
        _project = project;
    }
    return self;
}

+(id)projectWithProject:(OmniFocusProject *)project parent:(JROFObject *)parent {
    return [[self alloc] initWithProject:project parent:parent];
}

+(NSMutableArray *)projectsFromArray:(NSArray *)array parent:(JROFObject *)parent {
     NSMutableArray *arr = [NSMutableArray arrayWithCapacity:array.count];
    for (OmniFocusProject *p in array)
        [arr addObject: [JRProject projectWithProject:p parent:parent]];
    return arr;
}

#pragma mark Getters

-(NSMutableArray *)tasks {
    if (!_tasks)
        _tasks = [JRTask tasksFromArray: self.project.rootTask.flattenedTasks parent:self];
    return _tasks;
}

#pragma mark Properties

-(NSString *)name {
    if (!_name) _name = self.project.name;
    return _name;
}

-(NSString *)id {
    if (!_id) _id = self.project.id;
    return _id;
}

-(NSString *)status {
    if (!_status) {
        JRTask *nextTask = (self.tasks.count > 0 ? self.tasks[0] : nil);
        switch (self.project.status) {
        case OmniFocusProjectStatusActive:
            if (nextTask && nextTask.isWaiting)
                _status = @"Waiting on";
            else if (self.deferredDate || (nextTask && nextTask.deferredDate))
                _status = @"Deferred";
            else
                _status = @"Active";
            
            break;
        case OmniFocusProjectStatusOnHold:
            _status = @"On hold";
            break;
        case OmniFocusProjectStatusDone:
            _status = @"Done";
            break;
        default:
            _status = @"Dropped";
        }
    }
    return _status;
}


-(NSDate *)creationDate {
    if (!_creationDate) _creationDate = self.project.creationDate;
    return _creationDate;
}

-(NSDate *)completionDate {
    if (!self.isCompleted) return nil;
    
    if (!_completionDate) _completionDate = [self.project.completionDate get];
    return _completionDate;
}

-(NSDate *)deferredDate {
    if (!_deferredDate) {
        if (JROmniFocus.instance.version == JROmniFocusVersion1)
            _deferredDate = [self.project.startDate get];
        else
            _deferredDate = [self.project.deferDate get];

        if (!_deferredDate && self.tasks.count > 0)//Also check first task
            _deferredDate = ((JRTask *)self.tasks[0]).deferredDate;
    }
    return _deferredDate;
}

-(BOOL)isCompleted {
    return self.project.completed;
}

#pragma mark Traversing the tree
-(void)eachTask:(void (^)(JRTask *))function {
    for (JRTask *t in self.tasks)
        function(t);
}

#pragma mark Export types
+(NSDictionary *)columns {
    return @{
        @"name": @"STRING",
        @"ancestors": @"STRING",
        @"status": @"STRING",
        @"completionDate": @"DATE",
        @"creationDate": @"DATE",
        @"deferredDate": @"DATE",
        @"ofid": @"STRING",
        @"numberOfTasks": @"INTEGER"
    };
}

-(NSDictionary *)asDict {
    return @{
        @"name": self.name,
        @"ancestors": self.ancestry,
        @"status": self.status,
        @"completionDate": (self.completionDate ? self.completionDate : @-1),
        @"creationDate": self.creationDate,
        @"deferredDate": (self.deferredDate ? self.deferredDate : @-1),
        @"ofid": self.id,
        @"numberOfTasks": @(self.tasks.count)
    };
}

@end
