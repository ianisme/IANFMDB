//
//  TeacherSqliteManager.m
//  IANFMDBDemo
//
//  Created by ian on 16/2/26.
//  Copyright © 2016年 ian. All rights reserved.
//

#import "TeacherSqliteManager.h"

@implementation TeacherSqliteManager

+ (instancetype)shareInstance
{
    static TeacherSqliteManager *shareManager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareManager = [[TeacherSqliteManager alloc] init];
    });
    return shareManager;
}


@end
