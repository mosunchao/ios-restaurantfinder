//
//  FacebookLocationSharer.h
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/31/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol FacebookLocationSharerDelegate

- (void) doneSearchingWithPlaceID:(NSString *)placeID;

@end
@interface FacebookLocationSharer : NSObject
@property (strong, nonatomic) id delegate;
- (void) searchRestaurantAtLatitude:(double)lat longitude:(double)lng;

@end
