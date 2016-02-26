//
//  TeacherSqliteManager.h
//  IANFMDBDemo
//
//  Created by ian on 16/2/26.
//  Copyright © 2016年 ian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IANFMDBQueue.h"

@interface TeacherSqliteManager : NSObject

@property (nonatomic, strong) IANFMDBQueue *queue;

+ (instancetype)shareInstance;

@end
