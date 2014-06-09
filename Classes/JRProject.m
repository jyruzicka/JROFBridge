//
//  JRProject.m
//  of-store
//
//  Created by Jan-Yves on 28/01/14.
//  Copyright (c) 2014 Jan-Yves Ruzicka. All rights reserved.
//

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


-(NSDate *)creationDate {
    if (!_creationDate) _creationDate = self.project.creationDate;
    return _creationDate;
}

-(NSDate *)completionDate {
    if (!self.completed) return NULL;
    
    if (!_completionDate) _completionDate = [self.project.completionDate get];
    return _completionDate;
}

-(BOOL)completed {
    return self.project.completed;
}

#pragma mark Utility methods

-(BOOL)shouldBeRecorded {
    return self.completed;
}

-(void)each:(void (^)(JROFObject *))function {
    function(self);
    for (JRTask *t in self.tasks)
        [t each:function];
}

@end
