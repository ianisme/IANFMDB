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
    NSString *dbName = @"teacher.db";
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [directory stringByAppendingPathComponent:dbName];
    NSLog(@"%@",dbPath);
    _queue = [[IANFMDBQueue alloc] initWithPath:dbPath];
    
    [self createTable];
    [self insertCangTeacher];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createTable
{
    NSString *sql = @"CREATE TABLE People (                     \
    id INTEGER PRIMARY KEY AUTOINCREMENT,   \
    name_sql TEXT,                              \
    gender_sql TEXT,                              \
    age_sql INTEGER,                        \
    weight_sql REAL,                            \
    height_sql REAL,                             \
    married_sql INTEGER                          \
    )";
    [_queue executeUpdate:sql param:nil];
}

- (void)insertCangTeacher
{
    NSDictionary *param = @{
                            @"name_sql" : @"苍井空",
                            @"gender_sql" : @"male",
                            @"age_sql" : @70,
                            @"weight_sql" : @175l,
                            @"height_sql" : @22,
                            @"married_sql" : @1
                            };
    [_queue executeInsertTableName:@"People" mapValueParam:param];
}


@end
