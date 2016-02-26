//
//  IANFMDBQueue.h
//  IANFMDBDemo
//
//  Created by ian on 16/2/22.
//  Copyright © 2016年 ian. All rights reserved.
//

#import <FMDB/FMDB.h>

@interface IANFMDBQueue : FMDatabaseQueue

/**
 *  通过路径初始化(有则创建，无则获取)
 *
 *  @param aPath 数据库文件路径
 *
 *  @return Queue实例
 */
- (instancetype)initWithPath:(NSString *)aPath;

/**
 *  通过数据库名称初始化
 *
 *  @param dbName 数据库名称 例如：cangteacher.db
 *
 *  @return Queue实例
 */
- (instancetype)initWithdbName:(NSString *)dbName;

/**
 *  在对应数据库中创建新表
 *
 *  @param tableName 数据库名称
 *  @param listParam 字段名key，类型名为value的字典
 *
 *  @return 是否成功
 */
- (BOOL)executeCreateTableName:(NSString *)tableName listParam:(NSDictionary *)listParam;

/**
 *  更新数据
 *
 *  @param sql   sql语句
 *  @param param 参数
 *
 *  @return 是否成功
 */
- (BOOL)executeUpdate:(NSString *)sql param:(NSArray *)param;

/**
 *  查询行数
 *
 *  @param tableName 表名
 *
 *  @return 数量
 */
- (NSUInteger)dataRowCount:(NSString *)tableName;

/**
 *  返回指定Class的结果数组
 *
 *  @param sql        sql语句
 *  @param modelClass model类型
 *
 *  @return 数组
 */
- (NSArray *)executeQuery:(NSString *)sql withArgumentInArray:param modelClass:(Class)modelClass;

/**
 *  返回指定Class的结果数组，并执行自定义操作
 *
 *  @param sql        sql语句
 *  @param param      参数
 *  @param modelClass model类型
 *  @param handle     自定义事件
 *
 *  @return 数组
 */
- (NSArray *)executeQuery:(NSString *)sql withArgumentInArray:(id)param modelClass:(Class)modelClass handle:(void(^)(id model, FMResultSet *rs))handle;

// 清除数据库中重复的数据
- (BOOL)executeCleanRepeatData:(NSString *)tableName columnName:(NSString *)columnName;

// 增加
- (BOOL)executeInsertTableName:(NSString *)tableName mapValueParam:(NSDictionary *)mapValueParam;

// 删除
- (BOOL)executeDeleteTabelName:(NSString *)tableName mapCondition:(NSDictionary *)mapCondition;

// 修改
- (BOOL)executeUpdateTableName:(NSString *)tableName mapValueParam:(NSDictionary *)mapValueParam mapCondition:(NSDictionary *)mapCondition;

// 查询
- (BOOL)executeSelectTableName:(NSString *)tableName columnList:(NSArray *)columnList mapCondition:(NSDictionary *)mapCondition;

// 创建数据库查询sql语句
- (NSString *)createSelectSQL:(NSString *)tableName columnList:(NSArray *)columnList mapCondition:(NSDictionary *)mapCondition;

@end
