//
//  FacebookLocationSharer.m
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/31/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import "FacebookLocationSharer.h"
@interface FacebookLocationSharer ()
@property (nonatomic, strong) NSURLConnection * conn;
@property (nonatomic, strong) NSMutableData * receivedData;
@end
@implementation FacebookLocationSharer {
    double latitutde;
    double longitude;
}
- (void)searchRestaurantAtLatitude:(double)lat longitude:(double)lng {
    NSString * str = [@"https://graph.facebook.com/search?q=restaurant&type=place&center=" stringByAppendingFormat:@"%f,%f&distance=500",lat,lng];
    NSURL * url = [NSURL URLWithString:str];
    NSURLRequest * request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    self.conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (self.conn) {
        self.receivedData = [NSMutableData data];
    } else {
        NSLog (@"connection is nil");
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection {
    NSLog(@"did finish loading");
    // start parsing JSON from facebook
    NSError * error = nil;
    NSDictionary * tempDict = [NSJSONSerialization JSONObjectWithData:self.receivedData options:0 error:&error];
    if (error) {
        NSLog(@"Error loading JSON from Facebook: %@", error.localizedDescription);
        return;
    }
    NSArray * dataArray = [tempDict objectForKey:@"data"];
    if (dataArray.count > 0) {
        tempDict = dataArray[0];
        NSString * placeId = [tempDict objectForKey:@"id"];
        
        // call delegate
        if ([self.delegate respondsToSelector:@selector(doneSearchingWithPlaceID:)]) {
            [self.delegate doneSearchingWithPlaceID:placeId];
        }
        
    } else {
        NSLog(@"no place id fonud on facebook");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"recieved response");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"received DATA");
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}
@end
