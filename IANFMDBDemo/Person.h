//
//  Person.h
//  IANFMDBDemo
//
//  Created by ian on 16/2/22.
//  Copyright © 2016年 ian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IANFMDBPropertyMappingDelegate.h"

@interface Person : NSObject <IANFMDBPropertyMappingDelegate>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, assign) float weight;
@property (nonatomic, assign) double height;
@property (nonatomic, assign) BOOL married;

@end
