//
//  DetailViewController.h
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/26/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>

#import "MyGoogleMapParser.h"
#import "SearchViewController.h"
#import "SingletonRestaurants.h"

@protocol RestaurantListDelegate <NSObject>

- (BOOL) tableShouldReload;

@end


@interface DetailViewController : UIViewController<UISplitViewControllerDelegate,UIPopoverControllerDelegate,SearchViewControllerDelegate,MyGoogleMapParser,MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) UIPopoverController * searchPopOverController;
@property (strong, nonatomic) SingletonRestaurants * sharedData;


@property (strong, nonatomic) id delegate;


@end
