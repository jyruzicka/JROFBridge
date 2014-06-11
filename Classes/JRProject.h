//  JRProject.h
//
//  For license information see the LICENSE file

#import "JROFObject.h"
@class OmniFocusProject,JRTask;

/**
 * Represents a folder in the OmniFocus tree
 */
@interface JRProject : JROFObject {
    NSString *_name, *_id, *_status;
    NSDate *_creationDate, *_completionDate, *_deferredDate;
    
    NSMutableArray *_tasks;
}

/**
 * The OmniFocus project this object represents.
 */
@property (atomic,readonly) OmniFocusProject *project;

///---------------------------------
/// @name Initializers and factories
///---------------------------------

/**
 * Default initializer
 *
 * @param project The OmniFocus project this object represents
 * @param parent The project's parent. A value of `nil` indicates a root project.
 */
-(id)initWithProject:(OmniFocusProject *)project parent:(JROFObject *)parent;

/**
 * Default factory.
 *
 * @see initWithProject:parent:
 */
+(JRProject *)projectWithProject:(OmniFocusProject *)project parent:(JROFObject *)parent;

/**
 * Generate an array of projects from an array of `OmniFocusProject` objects.
 *
 * @param parent The parent object for all generated projects.
 */
+(NSMutableArray *)projectsFromArray:(NSArray *)array parent:(JROFObject *)parent;

///-------------------------
/// @name Collection getters
///-------------------------

/**
 * @return The projects's sub-tasks.
 */
-(NSMutableArray *)tasks;

///-----------------
/// @name Properties
///-----------------

/**
 * @return The project's status. This can be:
 *
 * * "Waiting on": First task has a context beginning with "Waiting".
 * * "Deferred": First task has a defer date in the future.
 * * "Active": Project is marked "Active"
 * * "On hold": Project is marked "On Hold"
 * * "Done": Project is marked "Done"
 * * "Dropped": Project is marked "Dropped"
 */
-(NSString *)status;

/**
 * @return The project's creation date.
 */
-(NSDate *)creationDate;

/**
 * @return The project's completion date, or `nil` if not complete.
 */
-(NSDate *)completionDate;

/**
 * @return The project's defer date, or its first task's defer date if project has no defer date, or `nil` if neither has a defer date.
 */
-(NSDate *)deferredDate;

///--------------------------
/// @name Traversing the tree
///--------------------------

/**
 * Perform an action on each task contained within this folder.
 */
-(void)eachTask:(void (^)(JRTask *))function;

///----------------
/// @name Exporting
///----------------

/**
 * @return A list of columns and their types used to represent a JRProject in SQL.
 */
+(NSDictionary *)columns;

/**
 * @return A list of JRProject values as a dictionary, for export to SQL.
 */
-(NSDictionary *)asDict;
@end
