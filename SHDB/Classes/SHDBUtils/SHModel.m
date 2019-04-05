//
//  SHModel.m
//  DBDemo
//
//  Created by Simon Mr on 2017/12/7.
//  Copyright © 2017年 Simon Mr. All rights reserved.
//

#import "SHModel.h"
#import "MJExtension.h"
#import <UIKit/UIKit.h>
#import "SHDB.h"

@interface SHModel ()

@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSArray<NSArray *> *propertyArray;
@property (strong, nonatomic) NSString *createTableSql;
@property (strong, nonatomic) NSString *insertSql;
@property (strong, nonatomic) NSString *updateSql;
@property (strong, nonatomic) NSString *deleteSql;

@property (strong, nonatomic) NSString *primaryKeyName;

@property (strong, nonatomic) NSString *tableName;

//@property (strong, nonatomic) SHDataBase *database;

@property (assign, nonatomic) NSTimeInterval lastTime;

@end

@implementation SHModel

//@synthesize database = _database;

- (BOOL)createTableInDB:(SHDataBase *)database {
    return [database executeUpdate:self.createTableSql];
}

- (instancetype)initWithIDkey:(NSString *)idkey {
    self = [super init];
    if (self) {
        NSDictionary *arguments = @{self.primaryKeyName : idkey};
        NSString *where = [NSString stringWithFormat:@"WHERE %@ = :%@", self.primaryKeyName, idkey];
        return [self selectOneWhere:where withParameterDictionary:arguments];
    }
    return self;
}

//- (SHDataBase *)database {
//    if (!_database) {
//        _database = [AppDataBase getInstance].dataBase;
//    }
//    return _database;
//}

//- (void)setDatabase:(SHDataBase *)database {
//    _database = database;
//}

+ (NSArray *)ignoredPropertyNames {
    return @[@"className", @"propertyArray", @"createTableSql", @"insertSql", @"updateSql", @"deleteSql", @"tableName", @"database", @"lastTime", @"primaryKeyName"];
}

- (NSString *)className {
    if (!_className) {
        _className = NSStringFromClass([self class]);
    }
    return _className;
}

- (NSString *)tableName {
    if (!_tableName) {
        // 去除"Model" SHModel --> SH
        _tableName = [self.className stringByReplacingOccurrencesOfString:SH_SQLITE_MODEL withString:@""];
    }
    return _tableName;
}

- (NSString *)primaryKeyName {
    if (!_primaryKeyName) {
        // 获得主键 SHModel --> SHID
        _primaryKeyName = [self.className stringByReplacingOccurrencesOfString:SH_SQLITE_MODEL withString:SH_SQLITE_ID];
        NSString *prefix = [_primaryKeyName substringToIndex:1].lowercaseString;
        NSString *suffix = [_primaryKeyName substringFromIndex:1];
        
        _primaryKeyName = [prefix stringByAppendingString:suffix];
    }
    return _primaryKeyName;
}

- (NSArray *)propertyArray {
    if (!_propertyArray) {
        NSArray *ignoredArray = [self.class ignoredPropertyNames];
        
        NSMutableArray *array = [NSMutableArray array];
        
        [self.class mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
            NSString *name = property.name;
            if (![ignoredArray containsObject:name]) {
                NSString *typeCode = property.type.code;
                NSString *type = @"";
                
                // 基础数据类型集合
                NSString *baseDataTypeCodeStringSet = @"cislqCISLQfdB";
                if ([typeCode isEqualToString:@"NSNumber"]
                    || [baseDataTypeCodeStringSet containsString:typeCode]) {
                    type = SH_SQLITE_REAL;
                } else if ([typeCode isEqualToString:@"NSString"]) {
                    type = SH_SQLITE_TEXT;
                } else if ([typeCode isEqualToString:@"NSData"]) {
                    type = SH_SQLITE_BLOB;
                }
//                
//                if ([typeCode isEqualToString:@"NSNumber"]) {
//                    type = SH_SQLITE_REAL;
//                } else if ([typeCode isEqualToString:@"NSString"]) {
//                    type = SH_SQLITE_TEXT;
//                } else if ([typeCode isEqualToString:@"NSData"]) {
//                    type = SH_SQLITE_BLOB;
//                }
                
                if (![name isEqualToString:SH_SQLITE_DESCRIPTION] &&
                    ![name isEqualToString:SH_SQLITE_DEBUGDESCRIPTION] &&
                    ![name isEqualToString:SH_SQLITE_IDKEY] &&
                    name.length > 0 &&
                    type.length > 0) {
                    [array addObject:@[ name, type ]];
                }
            }
        }];
        
        _propertyArray = array;
    }
    return _propertyArray;
}

- (NSString *)createTableSql {
    if (!_createTableSql) {
        NSString *tableName = self.tableName;
        NSString *primaryKeyName = self.primaryKeyName;
        if (tableName.length == 0 || primaryKeyName.length == 0) {
            return nil;
        }
        
        NSMutableString *sql = [NSMutableString string];
        [sql appendFormat:@"CREATE TABLE IF NOT EXISTS \"%@\" ( ", tableName];
        [sql appendFormat:@"\"%@\" %@ PRIMARY KEY NOT NULL", primaryKeyName, SH_SQLITE_TEXT];
        [self.propertyArray enumerateObjectsUsingBlock:^(NSArray *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSString *name = obj[0];
            NSString *type = obj[1];
            [sql appendFormat:@", \"%@\" %@", name, type];
        }];
        [sql appendString:@" )"];
        _createTableSql = sql;
    }
    return _createTableSql;
}

- (NSString *)insertSql {
    if (!_insertSql) {
        NSString *tableName = self.tableName;
        NSString *primaryKeyName = self.primaryKeyName;
        if (tableName.length == 0 || primaryKeyName.length == 0) {
            return nil;
        }
        
        NSMutableString *insertSql = [NSMutableString string];
        [insertSql appendFormat:@"INSERT INTO \"%@\" ( ", tableName];
        [insertSql appendFormat:@"\"%@\"", primaryKeyName];
        
        NSMutableString *valuesSql = [NSMutableString string];
        [valuesSql appendString:@"VALUES ( "];
        [valuesSql appendFormat:@":%@", primaryKeyName];
        
        [self.propertyArray enumerateObjectsUsingBlock:^(NSArray *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSString *name = obj[0];
            
            [insertSql appendFormat:@", \"%@\"", name];
            
            [valuesSql appendFormat:@", :%@", name];
        }];
        
        _insertSql = [NSString stringWithFormat:@"%@ ) %@ )", insertSql, valuesSql];
    }
    return _insertSql;
}

- (NSString *)updateSql {
    if (!_updateSql) {
        NSString *tableName = self.tableName;
        NSString *primaryKeyName = self.primaryKeyName;
        if (tableName.length == 0 || primaryKeyName.length == 0) {
            return nil;
        }
        
        NSMutableString *sql = [NSMutableString string];
        [sql appendFormat:@"UPDATE \"%@\" SET ", tableName];
        
        [self.propertyArray enumerateObjectsUsingBlock:^(NSArray *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSString *name = obj[0];
            [sql appendFormat:@"\"%@\" = :%@", name, name];
            
            if (idx != self.propertyArray.count - 1) {
                [sql appendString:@", "];
            }
        }];
        
        [sql appendFormat:@" WHERE \"%@\" = :%@", primaryKeyName, primaryKeyName];
        
        _updateSql = sql;
    }
    return _updateSql;
}

- (NSString *)deleteSql {
    if (!_deleteSql) {
        NSString *tableName = self.tableName;
        NSString *primaryKeyName = self.primaryKeyName;
        if (tableName.length == 0 || primaryKeyName.length == 0) {
            return nil;
        }
        
        NSMutableString *sql = [NSMutableString string];
        [sql appendFormat:@"DELETE FROM \"%@\" ", tableName];
        [sql appendFormat:@"WHERE \"%@\" = :%@", primaryKeyName, primaryKeyName];
        
        _deleteSql = sql;
    }
    return _deleteSql;
}

#pragma mark -
+ (instancetype)createModel {
    return [[self.class alloc] init];
}

- (BOOL)save {
    return [self insertOrUpdate];
}

- (BOOL)deleteData {
    return [self deleteWithIdKey:self.idKey];
}

- (BOOL)deleteWithIdKey:(NSString *)idKey {
    NSDictionary *arguments = @{self.primaryKeyName : idKey};
    BOOL result = [[SHDataBase getInstance] executeUpdate:self.deleteSql withParameterDictionary:arguments];
    
    return result;
}

- (BOOL)insertOrUpdate {
    NSDate *date = [NSDate date];
    NSString *now = [NSString stringWithFormat:@"%lld", (long long) (date.timeIntervalSince1970 * 1000)];
    
    NSString *sql = nil;
    
    if (self.idKey.length == 0) {
        self.idKey = [self getNextIdKey];
        sql = self.insertSql;
    } else {
        sql = self.updateSql;
    }
    
    NSMutableDictionary *arguments = [self mj_keyValuesWithIgnoredKeys:[self.class ignoredPropertyNames]];
    
    [self.propertyArray enumerateObjectsUsingBlock:^(NSArray *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *name = obj[0];
        if (!arguments[name]) {
            arguments[name] = [NSNull null];
        }
    }];
    
    BOOL result = [[SHDataBase getInstance] executeUpdate:sql withParameterDictionary:arguments];
    
    return result;
}

- (NSString *)getNextIdKey {
    NSString *uuid = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    
    while (self.lastTime == now) {
        now = [NSDate date].timeIntervalSince1970;
    }
    
    return [NSString stringWithFormat:@"%@-%.6f", uuid, now];
}

- (__kindof SHModel *)selectOneWhere:(NSString *)whereClause
             withParameterDictionary:(NSDictionary *)arguments {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM \"%@\" %@ LIMIT 1", self.tableName, whereClause];
    NSArray *dictionaryArray = [[SHDataBase getInstance] executeQuery:sql withParameterDictionary:arguments];
    if (dictionaryArray.count == 0) {
        return nil;
    }
    return [self.class mj_objectWithKeyValues:dictionaryArray[0]];
}

- (void)updateTableAddColumn {
    NSMutableArray *localColumnArr = [[SHDataBase getInstance] getAllCoulumWithTableName:self.tableName];
    if ([self isNilOrNull:localColumnArr] || localColumnArr.count == 0) return;
    
    [localColumnArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *uppercaseString = [(NSString *)obj uppercaseString];
        [localColumnArr replaceObjectAtIndex:idx withObject:uppercaseString];
    }];
    
    NSMutableArray *columnArr = [[self propertyArray] mutableCopy];
    
    [columnArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *newSql = [NSString stringWithFormat:@"%@", [[columnArr objectAtIndex:idx] objectAtIndex:0]];
        
        //add
        if (![localColumnArr containsObject:[newSql uppercaseString]]) {
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@", self.tableName, [[columnArr objectAtIndex:idx] objectAtIndex:0], [[columnArr objectAtIndex:idx] objectAtIndex:1]];
            [self.class executeQuery:sql withParameterDictionary:@{}];
        }
    }];
}

- (BOOL)isNilOrNull:(id)value {
    return value == nil || value == [NSNull null];
}

#pragma mark - Category Method
+ (NSMutableArray<__kindof SHModel *> *)selectAll {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM \"%@\"", [NSStringFromClass([self class]) stringByReplacingOccurrencesOfString:SH_SQLITE_MODEL withString:@""]];
    NSArray *dictionaryArray = [[SHDataBase getInstance] executeQuery:sql withParameterDictionary:@{}];
    return [self.class mj_objectArrayWithKeyValuesArray:dictionaryArray];
}

+ (NSMutableArray<__kindof SHModel *> *)selectAllWhere:(NSString *)whereClause
                               withParameterDictionary:(NSDictionary *)arguments {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM \"%@\" %@", [NSStringFromClass([self class]) stringByReplacingOccurrencesOfString:SH_SQLITE_MODEL withString:@""], whereClause];
    NSArray *dictionaryArray = [[SHDataBase getInstance] executeQuery:sql withParameterDictionary:arguments];
    return [self.class mj_objectArrayWithKeyValuesArray:dictionaryArray];
}

+ (BOOL)deleteAllWhere:(NSString *)whereClause
        withParameterDictionary:(NSDictionary *)arguments {
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM \"%@\" %@", [NSStringFromClass([self class]) stringByReplacingOccurrencesOfString:SH_SQLITE_MODEL withString:@""], whereClause];
    
    BOOL result = [[SHDataBase getInstance] executeUpdate:sql withParameterDictionary:arguments];
    
    return result;
}

+ (NSMutableArray<__kindof SHModel *> *)executeQuery:(NSString *)sql
                             withParameterDictionary:(NSDictionary *)arguments {
    NSArray *dictionaryArray = [[SHDataBase getInstance] executeQuery:sql withParameterDictionary:arguments];
    return [self.class mj_objectArrayWithKeyValuesArray:dictionaryArray];
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    NSString *className = NSStringFromClass([self class]);
    return @{ @"idKey" : ((SHModel *)[[self.class alloc] init]).primaryKeyName };
}


@end
