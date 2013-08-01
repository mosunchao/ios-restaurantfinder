//
//  MyGoogleMapParser.h
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/26/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyGoogleMapParser <NSObject>

- (void) didFinishParsingJSON:(NSArray *)result latitude:(double)lat longitude:(double)lng;

@end

@interface MyGoogleMapParser : NSObject

@property (strong, nonatomic) id delegate;
- (void)searchACity:(NSString*)city;
- (void) searchRestaurantsAtLatitude:(double)latitude longitude:(double)longitude radius:(double)radius;

@end
