//
//  SHModel.h
//  DBDemo
//
//  Created by Simon Mr on 2017/12/7.
//  Copyright © 2017年 Simon Mr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SHDataBase;

NS_ASSUME_NONNULL_BEGIN

@protocol SHModelProtocol
@optional
+ (NSArray *)ignoredPropertyNames;
@end

@interface SHModel : NSObject <SHModelProtocol>

@property (strong, nonatomic) NSString *idKey; // Primary Key

/**
 DB中创建表

 @param database  初始化的SHDataBase
 @return  创建是否成功
 */
- (BOOL)createTableInDB:(SHDataBase *)database;

/**
 保存此条数据
 
 @return 保存是否成功
 */
- (BOOL)save;

/**
 删除此条数据
 
 @return 删除是否成功
 */
- (BOOL)deleteData;


/**
 根据主键删除数据

 @param idKey idKey
 @return 删除是否成功
 */
- (BOOL)deleteWithIdKey:(NSString *)idKey;

/**
 根据条件搜出一条数据

 @param whereClause where从句
 @param arguments 条件参数
 @return 返回一个SHModel
 */
- (__kindof SHModel *)selectOneWhere:(NSString *)whereClause
             withParameterDictionary:(NSDictionary *)arguments;

/**
 当model中添加一条新数据时，相应的表中添加新的一列
 */
- (void)updateTableAddColumn;


/**
 类方法： 创建一个Model

 @return Model
 */
+ (instancetype)createModel;



/**
 类方法： 搜出所有的数据

 @return 所有的数据
 */
+ (NSMutableArray<__kindof SHModel *> *)selectAll;

/**
 类方法： 根据条件搜出所有符合条件的数据

 @param whereClause where从句
 @param arguments 搜索参数
 @return 所有符合条件的数据
 */
+ (NSMutableArray<__kindof SHModel *> *)selectAllWhere:(NSString *)whereClause
                               withParameterDictionary:(NSDictionary *)arguments;


/**
 类方法： 根据条件删除所有符合条件的数据

 @param whereClause where从句
 @param arguments 搜索参数
 @return 删除操作是否成功
 */
+ (BOOL)deleteAllWhere:(NSString *)whereClause
        withParameterDictionary:(NSDictionary *)arguments;


/**
 类方法： 执行sql

 @param sql sql语句
 @param arguments 条件参数
 @return 搜索结果
 */
+ (NSMutableArray<__kindof SHModel *> *)executeQuery:(NSString *)sql
                             withParameterDictionary:(NSDictionary *)arguments;

@end

NS_ASSUME_NONNULL_END
