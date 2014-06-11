//
//  JRProject.h
//
//  Created by Jan-Yves on 28/01/14.
//  Copyright (c) 2014 Jan-Yves Ruzicka. All rights reserved.
//

#import "JROFObject.h"
@class OmniFocusProject,JRTask;

@interface JRProject : JROFObject {
    NSString *_name, *_id, *_status;
    NSDate *_creationDate, *_completionDate, *_deferredDate;
    
    NSMutableArray *_tasks;
}

@property (atomic,readonly) OmniFocusProject *project;

#pragma mark Initializer
-(id)initWithProject:(OmniFocusProject *)project parent:(JROFObject *)parent;
+(JRProject *)projectWithProject:(OmniFocusProject *)project parent:(JROFObject *)parent;
+(NSMutableArray *)projectsFromArray:(NSArray *)array parent:(JROFObject *)parent;

#pragma mark Getters
-(NSMutableArray *)tasks;

#pragma mark Properties
-(NSString *)status;
-(NSDate *)creationDate;
-(NSDate *)completionDate;
-(NSDate *)deferredDate;

#pragma mark Traversing the tree
-(void)eachTask:(void (^)(JRTask *))function;

#pragma mark Export types
+(NSDictionary *)columns;
-(NSDictionary *)asDict;
@end
