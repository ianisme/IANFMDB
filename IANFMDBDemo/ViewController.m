//
//  ViewController.m
//  IANFMDBDemo
//
//  Created by ian on 16/2/22.
//  Copyright © 2016年 ian. All rights reserved.
//

#import "ViewController.h"
#import "IANFMDBQueue.h"
#import "Person.h"

@interface ViewController ()
{
    IANFMDBQueue *_queue;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *dbName = @"teacher3.db";
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [directory stringByAppendingPathComponent:dbName];
    NSLog(@"%@",dbPath);
    _queue = [[IANFMDBQueue alloc] initWithPath:dbPath];
    
    BOOL isSuccess;
    isSuccess = [_queue executeCreateTableName:@"Person" listParam:@{
                                                         @"name_sql" : @"TEXT",
                                                         @"gender_sql" : @"TEXT",
                                                         @"age_sql" : @"INTEGER",
                                                         @"weight_sql" : @"REAL",
                                                         @"height_sql" : @"REAL",
                                                         @"married_sql" : @"INTEGER",
                                                         }];
    
    NSLog(@"%@", isSuccess ? @"表创建成功" : @"");
    

    
    isSuccess = [_queue executeInsertTableName:@"Person" mapValueParam:@{
                                                             @"name_sql" : @"苍井空",
                                                             @"gender_sql" : @"male",
                                                             @"age_sql" : @90,
                                                             @"weight_sql" : @175l,
                                                             @"height_sql" : @22,
                                                             @"married_sql" : @1
                                                             }];
    NSLog(@"%@", isSuccess ? @"数据插入成功" : @"");
    
    NSLog(@"%zd",[_queue dataRowCount:@"Person"]);

    
    NSString *sqlString = [_queue createSelectSQL:@"Person" columnList:nil mapCondition:nil];
    
    NSArray *array = [_queue executeQuery:sqlString withArgumentInArray:nil modelClass:[Person class] handle:^(id model, FMResultSet *rs) {
        NSLog(@"这是一个自定义事件");
    }];
    
    NSLog(@"%@",array);


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
