//
//  IANFMDBQueue.h
//  IANFMDBDemo
//
//  Created by ian on 16/2/22.
//  Copyright © 2016年 ian. All rights reserved.
//

#import <FMDB/FMDB.h>

@interface IANFMDBQueue : FMDatabaseQueue

// 初始化
- (instancetype)initWithPath:(NSString *)aPath;

// 更新数据
- (BOOL)executeUpdate:(NSString *)sql param:(NSArray *)param;

// 查询行数
- (NSUInteger)dataRowCount:(NSString *)tableName;

// 返回指定Class的结果数组
- (NSArray *)executeQuery:(NSString *)sql withArgumentInArray:param modelClass:(Class)modelClass;

// 返回指定Class的结果数组，并执行自定义操作
- (NSArray *)executeQuery:(NSString *)sql withArgumentInArray:(id)param modelClass:(Class)modelClass handle:(void(^)(id model, FMResultSet *rs))handle;

// 增加
- (BOOL)executeInsertTableName:(NSString *)tableName mapValueParam:(NSDictionary *)mapValueParam;

// 删除
- (BOOL)executeDeleteTabelName:(NSString *)tableName mapCondition:(NSDictionary *)mapCondition;

// 修改
- (BOOL)executeUpdateTableName:(NSString *)tableName mapValueParam:(NSDictionary *)mapValueParam mapCondition:(NSDictionary *)mapCondition;

// 查询
- (BOOL)executeSelectTableName:(NSString *)tableName columnList:(NSArray *)columnList mapCondition:(NSDictionary *)mapCondition;



@end
