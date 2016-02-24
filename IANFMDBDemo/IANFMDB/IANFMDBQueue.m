//
//  IANFMDBQueue.m
//  IANFMDBDemo
//
//  Created by ian on 16/2/22.
//  Copyright © 2016年 ian. All rights reserved.
//

#import "IANFMDBQueue.h"
#import "IANFMDBPropertyMappingDelegate.h"
#import <objc/runtime.h>

@implementation IANFMDBQueue

- (instancetype)initWithPath:(NSString *)aPath
{
    return [super initWithPath:aPath];
}

- (instancetype)initWithdbName:(NSString *)dbName
{
    NSString *aPath = [self getDataBaseFilePath:dbName];
    return [self initWithPath:aPath];
}

- (BOOL)executeCreateTableName:(NSString *)tableName listParam:(NSDictionary *)listParam
{
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT count(*) as countNum FROM sqlite_master WHERE type ='table' and name = ?"];

    __block BOOL result = NO;
    [self inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sqlStr,tableName];
        if ([rs next]) {
            NSInteger count = [rs intForColumn:@"countNum"];
            if (count >= 1) {
                NSLog(@"%@数据表已存在，不需要创建",tableName);
                [rs close];
                result = NO;
            } else {
                //创建表
                if (tableName == nil || listParam == nil) {
                    return;
                }
                NSString *sqlString = @"CREATE TABLE ";
                sqlString = [sqlString stringByAppendingString:tableName];
                sqlString = [sqlString stringByAppendingString:@" (id INTEGER PRIMARY KEY AUTOINCREMENT"];
                
                NSString *columnString = @"";
                for (int i = 0; i < listParam.allKeys.count; i ++) {
                    NSString *seperator = sqlString.length < 1 ? @"" : @", ";
                    NSString *key = [listParam.allKeys objectAtIndex:i];
                    NSString *value = listParam[key];
                    NSString *keyAndValueStr = [NSString stringWithFormat:@"%@ %@",key,value];
                    
                    columnString = [[columnString stringByAppendingString:seperator] stringByAppendingString:keyAndValueStr];
                }
                
                sqlString = [sqlString stringByAppendingString:columnString];
                sqlString = [sqlString stringByAppendingString:@")"];
                
                result = [db executeUpdate:sqlString];
            }
        }
        [rs close];
        
    }];
    
    return result;
}

- (BOOL)executeUpdate:(NSString *)sql param:(NSArray *)param
{
    __block BOOL result = NO;
    [self inDatabase:^(FMDatabase *db) {
        if (param && param.count != 0) {
            result = [db executeUpdate:sql withArgumentsInArray:param];
        } else {
            result = [db executeUpdate:sql];
        }
    }];
    return result;
}

- (NSUInteger)dataRowCount:(NSString *)tableName
{
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",tableName];
    __block NSNumber *count;
    [self inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sqlStr withArgumentsInArray:nil];
        if ([rs next]) {
            count = (NSNumber *)rs[0];
        } else {
            count = @0;
        }
        [rs close];
    }];
    return count.integerValue;
}

- (NSArray *)executeQuery:(NSString *)sql withArgumentInArray:param modelClass:(Class)modelClass
{
    return [self executeQuery:sql withArgumentInArray:param modelClass:modelClass handle:nil];
}

- (NSArray *)executeQuery:(NSString *)sql withArgumentInArray:(id)param modelClass:(Class)modelClass handle:(void(^)(id model, FMResultSet *rs))handle
{
    __block NSMutableArray *modelArray = [@[] mutableCopy];
    [self inDatabase:^(FMDatabase *db) {
        NSDictionary *mapping = nil;
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:param];
        while ([rs next]) {
            id model = [[modelClass alloc] init];
            if (!mapping && [model conformsToProtocol:@protocol(IANFMDBPropertyMappingDelegate)]) {
                mapping = [model fmdbPropertyMapping];
            }
            
            for (int i = 0; i < [rs columnCount]; i++) {
                // 获取数据库中列名
                NSString *columnName = [rs columnNameForIndex:i];
                NSString *propertyName;
                if (mapping) {
                    propertyName = mapping[columnName];
                    if (propertyName == nil) {
                        propertyName = columnName;
                    }
                } else {
                    propertyName = columnName;
                }
                
                objc_property_t objcProperty = class_getProperty(modelClass, propertyName.UTF8String);
                // 如果属性不存在，则不操作
                if (objcProperty) {
                    if (![rs columnIndexIsNull:i]) {
                        [self setProperty:model rmResultSet:rs propertyName:propertyName columnName:columnName objcProperty:objcProperty];
                    }
                }
                
                NSAssert(![propertyName isEqualToString:@"description"], @"descriprion为自带方法，不能对description进行赋值");
            }
            
            // 执行block操作
            if (handle) {
                handle(model, rs);
            }
            [modelArray addObject:model];
        }
        [rs close];
    }];
    return modelArray;
}

- (BOOL)executeCleanRepeatData:(NSString *)tableName columnName:(NSString *)columnName
{
    NSString *sqlString = [NSString stringWithFormat:@"delete from %@ where %@ in (select %@ from %@ group by %@ having count(%@)>1) and id not in (select min(id) from %@ group by %@ having count(%@)>1)", tableName, columnName, columnName, tableName, columnName, columnName, tableName, columnName, columnName];
    return [self executeUpdate:sqlString param:nil];
}

- (BOOL)executeInsertTableName:(NSString *)tableName mapValueParam:(NSDictionary *)mapValueParam;
{
    NSArray *insertArray = [self createInsertSQL:tableName mapValueParam:mapValueParam];
    return [self executeUpdate:insertArray[0] param:insertArray[1]];;
}

- (BOOL)executeDeleteTabelName:(NSString *)tableName mapCondition:(NSDictionary *)mapCondition
{
    NSString *sql = [self createDeleteSQL:tableName mapCondition:mapCondition];
    return [self executeUpdate:sql param:nil];
}

- (BOOL)executeUpdateTableName:(NSString *)tableName mapValueParam:(NSDictionary *)mapValueParam mapCondition:(NSDictionary *)mapCondition
{
    NSString *sql = [self createUpdateSQL:tableName mapValueParam:mapValueParam mapCondition:mapCondition];
    return [self executeUpdate:sql param:nil];
}

- (BOOL)executeSelectTableName:(NSString *)tableName columnList:(NSArray *)columnList mapCondition:(NSDictionary *)mapCondition
{
    NSString *sql = [self createSelectSQL:tableName columnList:columnList mapCondition:mapCondition];
    return [self executeUpdate:sql param:nil];
}

#pragma mark - private method

- (void)setProperty:(id)model rmResultSet:(FMResultSet *)rs propertyName:(NSString *)propertyName columnName:(NSString *)columnName objcProperty:(objc_property_t)property
{
    NSString *firstType = [[[[NSString stringWithUTF8String:property_getAttributes(property)] componentsSeparatedByString:@","] firstObject] substringFromIndex:1];
    
    // float
    if ([firstType isEqualToString:@"f"]) {
        NSNumber *number = [rs objectForColumnName:columnName];
        [model setValue:@(number.floatValue) forKey:propertyName];
    }
    // int
    else if ([firstType isEqualToString:@"i"]) {
        NSNumber *number = [rs objectForColumnName:columnName];
        [model setValue:@(number.intValue) forKey:propertyName];
    }
    // unsigned int
    else if ([firstType isEqualToString:@"u"]) {
        NSNumber *number = [rs objectForColumnName:columnName];
        [model setValue:@(number.unsignedIntValue) forKey:propertyName];
    }
    // double
    else if ([firstType isEqualToString:@"d"]) {
        NSNumber *number = [rs objectForColumnName:columnName];
        [model setValue:@(number.doubleValue) forKey:propertyName];
    }
    // long
    else if ([firstType isEqualToString:@"l"]) {
        NSNumber *number = [rs objectForColumnName:columnName];
        [model setValue:@(number.longValue) forKey:propertyName];
    }
    // bool
    else if ([firstType isEqualToString:@"b"]) {
        NSNumber *number = [rs objectForColumnName:columnName];
        [model setValue:@(number.boolValue) forKey:propertyName];
    }
    // short
    else if ([firstType isEqualToString:@"s"]) {
        NSNumber *number = [rs objectForColumnName:columnName];
        [model setValue:@(number.shortValue) forKey:propertyName];
    }
    // NSInteger
    else if ([firstType isEqualToString:@"I"]) {
        NSNumber *number = [rs objectForColumnName:columnName];
        [model setValue:@(number.integerValue) forKey:propertyName];
    }
    // NSUInteger
    else if ([firstType isEqualToString:@"Q"]) {
        NSNumber *number = [rs objectForColumnName:columnName];
        [model setValue:@(number.unsignedIntegerValue) forKey:propertyName];
    }
    // NSData
    else if ([firstType isEqualToString:@"@\"NSData\""]) {
        NSData *value = [rs dataForColumn:columnName];
        [model setValue:value forKey:propertyName];
    }
    // NSDate
    else if ([firstType isEqualToString:@"@\"NSDate\""]) {
        NSDate *value = [rs dateForColumn:columnName];
        [model setValue:value forKey:propertyName];
    }
    // NSString
    else if ([firstType isEqualToString:@"@\"NSString\""]) {
        NSString *value = [rs stringForColumn:columnName];
        [model setValue:value forKey:propertyName];
    }
    // other
    else {
        id value = [rs objectForColumnName:columnName];
        [model setValue:value forKey:propertyName];
    }
}

- (NSString *)getDataBaseFilePath:(NSString *)dbName
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:dbName];
}

- (NSArray *)createInsertSQL:(NSString *)tableName mapValueParam:(NSDictionary *)mapValueParam
{
    NSMutableArray *resultArray = [@[] mutableCopy];
    
    if (tableName == nil || mapValueParam == nil) {
        return nil;
    }
    NSString *sqlString = @"INSERT OR IGNORE INTO ";
    sqlString = [sqlString stringByAppendingString:tableName];
    sqlString = [sqlString stringByAppendingString:@" ("];
    
    NSString *keyString = @"";
    NSString *valueString = @"";
    NSMutableArray *paramArray = [@[] mutableCopy];
    
    for (int i = 0; i < mapValueParam.allKeys.count; i ++) {
        NSString *keySeperator = keyString.length < 1 ? @"" : @",";
        NSString *key = [mapValueParam.allKeys objectAtIndex:i];
        keyString = [[keyString stringByAppendingString:keySeperator] stringByAppendingString:key];
        
        NSString *valueSeperator = valueString.length < 1 ? @"" : @",";
        valueString = [[valueString stringByAppendingString:valueSeperator] stringByAppendingString:@"?"];
        
        [paramArray addObject:mapValueParam[key]];
    }
    
    sqlString = [sqlString stringByAppendingString:keyString];
    sqlString = [sqlString stringByAppendingString:@") VALUES ("];
    sqlString = [sqlString stringByAppendingString:valueString];
    sqlString = [sqlString stringByAppendingString:@")"];
    
    [resultArray insertObject:sqlString atIndex:0];
    [resultArray insertObject:paramArray atIndex:1];
    
    return resultArray;
}

- (NSString *)createDeleteSQL:(NSString *)tableName mapCondition:(NSDictionary *)mapCondition
{
    if (tableName == nil) {
        return nil;
    }
    
    NSString *sqlString = @"DELETE FROM ";
    sqlString = [sqlString stringByAppendingString:tableName];
    
    if (mapCondition == nil || mapCondition.count <= 0) {
        return sqlString;
    }
    sqlString = [sqlString stringByAppendingString:@" WHERE "];
    
    NSString *conditions = @"";
    
    for (int j =0; j < mapCondition.allKeys.count; j++) {
        
        NSString *key = [mapCondition.allKeys objectAtIndex:j];
        NSString *value = [mapCondition objectForKey:key];
        NSString *seperator = conditions.length < 1 ? @"" : @" AND ";
        conditions = [[[[conditions stringByAppendingString:seperator] stringByAppendingString:key] stringByAppendingString:@"="] stringByAppendingString:value];
    }
    
    sqlString = [sqlString stringByAppendingString:conditions];
    
    return sqlString;
}

- (NSString *)createUpdateSQL:(NSString *)tableName mapValueParam:(NSDictionary *)mapValueParam mapCondition:(NSDictionary *)mapCondition
{
    if (tableName == nil || mapValueParam == nil) {
        return nil;
    }
    
    NSString *sqlString = @"UPDATE ";
    sqlString = [sqlString stringByAppendingString:tableName];
    sqlString = [sqlString stringByAppendingString:@" SET"];
    
    NSString *fields = @"";
    for (int i = 0; i<mapValueParam.allKeys.count; i++) {
        
        NSString *seperator = fields.length<1?@" ":@",";
        NSString *key = [mapValueParam.allKeys objectAtIndex:i];
        NSString *value = [mapValueParam objectForKey:key];
        value = [NSString stringWithFormat:@"\"%@\"",value];
        
        fields = [[[[fields stringByAppendingString:seperator] stringByAppendingString:key] stringByAppendingString:@"="] stringByAppendingString:value];
    }
    
    sqlString = [sqlString stringByAppendingString:fields];
    
    if (mapCondition == nil || [mapCondition count] <= 0) {
        return sqlString;
    }
    sqlString = [sqlString stringByAppendingString:@" WHERE "];
    
    NSString *conditions = @"";
    
    for (int j =0; j < mapCondition.allKeys.count; j++) {
        
        NSString *key = [mapCondition.allKeys objectAtIndex:j];
        NSString *value = [mapCondition objectForKey:key];
        
        NSString *seperator = conditions.length < 1 ? @"" : @" AND ";
        
        conditions = [[[[conditions stringByAppendingString:seperator] stringByAppendingString:key] stringByAppendingString:@"="] stringByAppendingString:value];
    }
    
    sqlString = [sqlString stringByAppendingString:conditions];
    
    return sqlString;
}

- (NSString *)createSelectSQL:(NSString *)tableName columnList:(NSArray *)columnList mapCondition:(NSDictionary *)mapCondition
{
    if (tableName == nil) {
        return nil;
    }
    NSString *sqlString = @"SELECT";
    NSString *fields = @"";
    
    if (columnList == nil || columnList.count <= 0) {
        fields = @" * ";
    } else {
        for (int i = 0; i < columnList.count; i ++) {
            NSString *seperator = fields.length < 1 ? @" " : @",";
            fields = [[fields stringByAppendingString:seperator] stringByAppendingString:columnList[i]];
        }
        fields = [fields stringByAppendingString:@" "];
    }
    
    sqlString = [sqlString stringByAppendingString:fields];
    sqlString = [sqlString stringByAppendingString:@"FROM "];
    sqlString = [sqlString stringByAppendingString:tableName];
    
    if (mapCondition == nil || mapCondition.count <= 0) {
        return sqlString;
    }
    sqlString = [sqlString stringByAppendingString:@" WHERE "];
    NSString *conditions = @"";
    
    for (int i = 0; i < mapCondition.allKeys.count; i ++) {
        NSString *key = [[mapCondition allKeys] objectAtIndex:i];
        NSString *value = mapCondition[key];
        
        NSString *seperator = conditions.length < 1 ? @" " : @" AND ";
        conditions = [[[[conditions stringByAppendingString:seperator] stringByAppendingString:key] stringByAppendingString:@"="] stringByAppendingString:value];
    }
    
    sqlString = [sqlString stringByAppendingString:conditions];
    
    return sqlString;
}

@end
