//
//  MyGoogleMapParser.m
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/26/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import "MyGoogleMapParser.h"

#define KEY @"AIzaSyAw0m3prCKzqP-zrWauU7DsXJgMDnbQY-Y"

@interface MyGoogleMapParser()
@property (strong,nonatomic) NSURLConnection * conn;
@property (strong,nonatomic) NSMutableData * receivedData;
@property (strong,nonatomic) NSArray * results;
@end

@implementation MyGoogleMapParser {
    double lat;
    double lng;
    double foundCity;
}

- (void)searchACity:(NSString*)city {
    
    // url encode
    NSString *encodedAddress = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) city, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 ));
    
    NSString * str = [NSString stringWithFormat:@"https://maps.google.com/maps/api/geocode/json?address=%@&region=US&sensor=false",encodedAddress];
    NSLog(@"%@",str);
    NSURL * url = [NSURL URLWithString:str];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    self.conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (self.conn) {
        self.receivedData = [NSMutableData data];
    } else {
        NSLog (@"connection is nil");
    }
}

- (void)searchRestaurantsAtLatitude:(double)latitude longitude:(double)longitude radius:(double)radius {
    NSURL * url = [self getURL:latitude longitude:longitude radius:radius];
    NSURLRequest * request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    self.conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (self.conn) {
        self.receivedData = [NSMutableData data];
    } else {
        NSLog (@"connection is nil");
    }
}

// get the Google Map search api with custom input lat,long,radius
- (NSURL*) getURL:(double)latitude longitude:(double)longitude radius:(double)radius {
    NSString * str = [@"https://maps.googleapis.com/maps/api/place/search/json?location=" stringByAppendingFormat:@"%f,%f",latitude,longitude];
    str = [str stringByAppendingFormat:@"&radius=%f&types=restaurant&region=US&sensor=false&key=AIzaSyAw0m3prCKzqP-zrWauU7DsXJgMDnbQY-Y",radius];
    NSLog(@"%@",str);
    return [NSURL URLWithString:str];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Finished Loading");
    // starts parsing JSON
    NSError * error = nil;
    if (!foundCity) {
        NSDictionary * rootDict = [NSJSONSerialization JSONObjectWithData:self.receivedData options:0 error:nil];
        NSArray * tempCity = [rootDict objectForKey:@"results"];
        
        if (tempCity.count > 0) { // if city result is not empty
            NSDictionary * location = [[tempCity[0] objectForKey:@"geometry"] objectForKey:@"location"];
            lat = ((NSNumber*)[location objectForKey:@"lat"]).doubleValue;
            lng = ((NSNumber*)[location objectForKey:@"lng"]).doubleValue;
            
            // flag
            foundCity = YES;
            
            // clear receivedData
            self.receivedData = nil;
            
            // perform search on restaurant
            [self searchRestaurantsAtLatitude:lat longitude:lng radius:5000];
        } else { // throw error: not city was found.
            if ([self.delegate respondsToSelector:@selector(didFinishParsingJSON:latitude:longitude:)]) {
                [self.delegate didFinishParsingJSON:nil latitude:0 longitude:0];
            }
        }
    } else { // if the city is found, search 
        NSDictionary * rootDict = [NSJSONSerialization JSONObjectWithData:self.receivedData options:0 error:&error];
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        } else {
            self.results = [rootDict objectForKey:@"results"];
        }
        
        // delegate call back
        if ([self.delegate respondsToSelector:@selector(didFinishParsingJSON:latitude:longitude:)]) {
            [self.delegate didFinishParsingJSON:self.results latitude:lat longitude:lng];
        }
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
