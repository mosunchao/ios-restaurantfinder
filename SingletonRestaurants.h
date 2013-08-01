//
//  SingletonRestaurants.h
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/26/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingletonRestaurants : NSObject
@property (strong, nonatomic) NSMutableArray * arrayRestaurants;
@property (strong, nonatomic) SingletonRestaurants * sharedData;
+ (SingletonRestaurants*) sharedInstance;
+ (void) clearArray;
@end
