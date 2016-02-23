//
//  Person.m
//  IANFMDBDemo
//
//  Created by ian on 16/2/22.
//  Copyright © 2016年 ian. All rights reserved.
//

#import "Person.h"

@implementation Person

// 用过JSONModel的都明白这个写法
- (NSDictionary *)fmdbPropertyMapping
{
    return @{
             @"name_sql" : @"name",
             @"gender_sql" : @"gender",
             @"age_sql" : @"age",
             @"weight_sql" : @"weight",
             @"height_sql" : @"height",
             @"married_sql" : @"married"
             };
}

@end
