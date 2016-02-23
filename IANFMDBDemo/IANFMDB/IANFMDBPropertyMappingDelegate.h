//
//  IANFMDBPropertyMappingDelegate.h
//  IANFMDBDemo
//
//  Created by ian on 16/2/22.
//  Copyright © 2016年 ian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IANFMDBPropertyMappingDelegate <NSObject>

@required
- (NSDictionary *)fmdbPropertyMapping;

@end
