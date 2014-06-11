#import <Foundation/Foundation.h>

@interface JRDatabaseQuery : NSObject

@property NSString *table;
@property NSMutableDictionary *values;
@property NSString *primaryKey;

#pragma mark Initializers and factories
-(id)initForTable:(NSString *)table;
-(id)initForTable:(NSString *)table values: (NSDictionary *)values;

+(JRDatabaseQuery *)queryForTable:(NSString *)table;
+(JRDatabaseQuery *)queryForTable:(NSString *)table values:(NSDictionary *)values;

#pragma mark Add values
-(void)addValue:(id)value forKey:(NSString *)key;
-(BOOL)removeKey:(NSString *)key;

#pragma mark - Perform things
-(NSString *)insert:(NSArray **)values;
-(NSString *)update:(NSArray **)values;
-(NSString *)create;
-(NSString *)count:(id *)values;
@end