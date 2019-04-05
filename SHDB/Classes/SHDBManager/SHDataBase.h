//
//  SHDataBase.h
//  DBDemo
//
//  Created by Simon Mr on 2017/12/7.
//  Copyright © 2017年 Simon Mr. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHDataBase : NSObject

+ (instancetype)getInstance;

+ (instancetype)dataBase:(SHDataBase *)dataBase anPath:(NSString *)path;
+ (instancetype)databaseWithPath:(NSString *)path key:(NSString *)key;

- (BOOL)executeUpdate:(NSString *)sql;
- (BOOL)executeUpdate:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments;

- (NSMutableArray<NSDictionary *> *)executeQuery:(NSString *)sql;
- (NSMutableArray<NSDictionary *> *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments;

- (BOOL)close;
- (NSMutableArray<NSString *> *)getAllCoulumWithTableName:(NSString *)tableName;

#pragma mark - Transaction
- (void)executeUpdateInTransaction:(BOOL (^)(void))block;

- (BOOL)beginTransaction;
- (BOOL)commit;
- (BOOL)rollback;

#pragma mark - DBVersion
- (BOOL)updateDBVersion:(NSInteger)newVersion;
- (NSInteger)getDBVersion;

@end

NS_ASSUME_NONNULL_END
