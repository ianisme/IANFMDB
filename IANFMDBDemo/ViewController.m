//
//  ViewController.m
//  IANFMDBDemo
//
//  Created by ian on 16/2/22.
//  Copyright © 2016年 ian. All rights reserved.
//

#import "ViewController.h"
#import "IANFMDBQueue.h"

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
                                                             @"age_sql" : @70,
                                                             @"weight_sql" : @175l,
                                                             @"height_sql" : @22,
                                                             @"married_sql" : @1
                                                             }];
    NSLog(@"%@", isSuccess ? @"数据插入成功" : @"");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
