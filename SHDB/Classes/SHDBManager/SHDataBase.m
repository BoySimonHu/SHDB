//
//  SHDataBase.m
//  DBDemo
//
//  Created by Simon Mr on 2017/12/7.
//  Copyright © 2017年 Simon Mr. All rights reserved.
//

#import "SHDataBase.h"
#import "FMDB.h"

@interface SHDataBase ()
@property (nonatomic, strong) FMDatabaseQueue *fmdbQueue;
@property (nonatomic, strong) FMDatabase *fmdb;
@end

@implementation SHDataBase

+ (instancetype)getInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)dataBase:(SHDataBase *)dataBase anPath:(NSString *)path {
    return [SHDataBase databaseWithPath:path key:@""];
}

+ (instancetype)databaseWithPath:(NSString *)path key:(NSString *)key {
    if (path.length == 0) {
        return nil;
    }
    
    SHDataBase *dbModel = [[SHDataBase alloc] init];
    dbModel.fmdbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    [dbModel.fmdbQueue inDatabase:^(FMDatabase *db) {
        dbModel.fmdb = db;
        if (key.length > 0) {
            [db setKey:key];
        }
    }];
    return dbModel;
}

- (BOOL)executeUpdate:(NSString *)sql {
    return [self executeUpdate:sql withParameterDictionary:@{}];
}

- (BOOL)executeUpdate:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments {
    return [self.fmdb executeUpdate:sql withParameterDictionary:arguments];
}

- (NSMutableArray<NSDictionary *> *)executeQuery:(NSString *)sql {
    return [self executeQuery:sql withParameterDictionary:@{}];
}

- (NSMutableArray<NSDictionary *> *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments {
    FMResultSet *resultSet = [self.fmdb executeQuery:sql withParameterDictionary:arguments];
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    while ([resultSet next]) {
        [resultArray addObject:[resultSet resultDictionary]];
    }
    
    [resultSet close];
    
    return resultArray;
}

- (BOOL)close {
    BOOL isClosed = [self.fmdb close];
    if (isClosed) {
        self.fmdb = nil;
        self.fmdbQueue = nil;
    }
    
    return isClosed;
}

- (NSMutableArray<NSString *> *)getAllCoulumWithTableName:(NSString *)tableName {
    NSString *select = [NSString stringWithFormat:@"select * from %@ limit 0", tableName];
    FMResultSet *set = [self.fmdb executeQuery:select];
    NSArray *columnArray = set.columnNameToIndexMap.allKeys;
    return [NSMutableArray arrayWithArray:columnArray];
}

#pragma mark - Transaction
- (void)executeUpdateInTransaction:(BOOL (^)(void))block {
    [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL result = block();
        if (!result) {
            *rollback = YES;
            return;
        }
    }];
}

- (BOOL)beginTransaction {
    return [self.fmdb beginTransaction];
}

- (BOOL)commit {
    return [self.fmdb commit];
}

- (BOOL)rollback {
    return [self.fmdb rollback];
}

#pragma mark - DBVersion
- (BOOL)updateDBVersion:(NSInteger)newVersion {
    NSString *sql = @"PRAGMA user_version";
    FMResultSet *resultSet = [self.fmdb executeQuery:sql];
    NSInteger version = 0;
    while ([resultSet next]) {
        version = [[resultSet resultDictionary].allValues.firstObject integerValue];
    }
    [resultSet close];
    
    NSString *updateSql = [NSString stringWithFormat:@"PRAGMA user_version = %zd", newVersion];
    BOOL result = [self.fmdb executeUpdate:updateSql];
    
    return result;
}

- (NSInteger)getDBVersion {
    NSString *sql = @"PRAGMA user_version";
    FMResultSet *resultSet = [self.fmdb executeQuery:sql];
    NSInteger version = 0;
    while ([resultSet next]) {
        version = [[resultSet resultDictionary].allValues.firstObject integerValue];
    }
    [resultSet close];
    
    return version;
}

@end
