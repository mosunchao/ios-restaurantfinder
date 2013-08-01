//
//  CustomAnnotation.h
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/26/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface CustomAnnotation : NSObject <MKAnnotation>
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSString * photoReference;
@property (strong, nonatomic) UIImage * icon;
@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * subtitle;
@property (strong, nonatomic) NSNumber * rating;
@end
