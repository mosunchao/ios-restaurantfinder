//
//  SingletonRestaurants.m
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/26/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import "SingletonRestaurants.h"

@implementation SingletonRestaurants
static SingletonRestaurants * sharedSingleton = nil;
+ (SingletonRestaurants *) sharedInstance {
    if (sharedSingleton == nil) {
        sharedSingleton = [[SingletonRestaurants alloc] init];
    }
    return sharedSingleton;
}

+ (void)clearArray {
    if (sharedSingleton) {
        sharedSingleton.arrayRestaurants = [[NSMutableArray alloc] init];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        self.arrayRestaurants = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
