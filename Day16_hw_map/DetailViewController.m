//
//  DetailViewController.m
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/26/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import "DetailViewController.h"
#import "Reachability.h"
#import "CustomAnnotation.h"
#import "RestaurantDetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController {
    MKCoordinateRegion originalRegion;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Add search button on top-right navigation bar
    UIBarButtonItem * btnSearchVC = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStyleBordered target:self action:@selector(popOverSearchVC)];
    
    self.navigationItem.rightBarButtonItem = btnSearchVC;
    
    // Initialize popOverController
    SearchViewController * searchVC = [[SearchViewController alloc] init];
    searchVC.delegate = self;
    self.searchPopOverController = [[UIPopoverController alloc] initWithContentViewController:searchVC];
    self.searchPopOverController.delegate = self;
    self.searchPopOverController.popoverContentSize = CGSizeMake(320, 120);
    
    self.sharedData = [SingletonRestaurants sharedInstance];
    
    originalRegion = self.mapView.region;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// hide or show popOver
- (void) popOverSearchVC {
    if (self.searchPopOverController.popoverVisible) {
        [self.searchPopOverController dismissPopoverAnimated:YES];
    } else {
        [self.searchPopOverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

// delegate callBack from SearchViewController
- (void)doneEnteringText:(NSString *) addressStr {
    // reachabliity check
    if ([self isReachableToHost]) {
        // remove all annotations from map
        [self.mapView removeAnnotations:self.mapView.annotations];
        // perform map search with addressStr
        [self forwardGeocoding:addressStr];
    } else { // no network connection!!!
        [self initAlertWithMessage:@"No Internet Connection!"];
    }
}

// forward Geocoding
- (void) forwardGeocoding:(NSString*) addressStr {
    
    //dispatch_async(dispatch_queue_create("search google maps", NULL), ^{
        // search on Google Maps with lat,long,radius
        MyGoogleMapParser * googleParser = [[MyGoogleMapParser alloc] init];
        googleParser.delegate = self;
        [googleParser searchACity:addressStr];

    //});
    [self.searchPopOverController dismissPopoverAnimated:YES];
    /*
     
     CLGeocoder * geocoder = [[CLGeocoder alloc] init];
     
    [geocoder geocodeAddressString:addressStr completionHandler:^(NSArray * placemarks, NSError * error) {
       
        CLPlacemark * thisPlacemark = placemarks[0];
        if ([thisPlacemark.country isEqualToString:@"United States"]) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(thisPlacemark.region.center.latitude, thisPlacemark.region.center.longitude), 10000, 10000);
            
            [self.mapView setRegion:region animated:YES];
            
            // search on Google Maps with lat,long,radius
            MyGoogleMapParser * googleParser = [[MyGoogleMapParser alloc] init];
            googleParser.delegate = self;
            [googleParser searchRestaurantsAtLatitude:thisPlacemark.region.center.latitude longitude:thisPlacemark.region.center.longitude radius:5000];
            
            
            // dismiss popOverVC
            [self.searchPopOverController dismissPopoverAnimated:YES];
        } else {
            [self initAlertWithMessage:@"address entered is not in the United States"];
        }

    }];
     */
}

// delegate call back from MyGoogleMapParser
- (void)didFinishParsingJSON:(NSArray *)result latitude:(double)lat longitude:(double)lng {
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        
        // clear previous results
        [SingletonRestaurants clearArray];
        
        if (result == nil) {
            [self initAlertWithMessage:@"No such city in the US."];
            [self.mapView setRegion:originalRegion animated:YES];

            
        } else if (result.count == 0) {
            [self initAlertWithMessage:@"No Restaurant Was Found."];
            [self.mapView setRegion:originalRegion animated:YES];

        } else {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(lat, lng), 10000, 10000);
            
            [self.mapView setRegion:region animated:YES];

            // create custom dictionary
            for (NSDictionary * entry in result) {
                NSDictionary * geometryDict = [entry objectForKey:@"geometry"];
                // location: lat , long
                NSDictionary * locationDict = [geometryDict objectForKey:@"location"];
                
                // initialize an annotation for map to add later
                CustomAnnotation * annotation = [[CustomAnnotation alloc] init];

                
                annotation.title = [entry objectForKey:@"name"];
                annotation.rating = [entry objectForKey:@"rating"];
                if (annotation.rating == nil) annotation.rating = @0;
                annotation.subtitle = [entry objectForKey:@"vicinity"];
                
                // annotation iamge
                NSString * iconURL = [entry objectForKey:@"icon"];
                annotation.icon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconURL]]];
                
                // attempt getting restaurant image
                NSArray * photoArray = [entry objectForKey:@"photos"];
                NSString * photoReference = @"";
                if (photoArray) {
                    photoReference = [photoArray[0] objectForKey:@"photo_reference"];
                }
                annotation.photoReference = photoReference;
                
                // convert coordinates to double type values
                double latitude = ((NSNumber*)[locationDict objectForKey:@"lat"]).doubleValue;
                double longitude = ((NSNumber*)[locationDict objectForKey:@"lng"]).doubleValue;
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                
                // add annotation to the map
                [self.mapView addAnnotation:annotation];

                // add to global data
                [self.sharedData.arrayRestaurants addObject:annotation];
            }
        }
        
        // reload table view on master VC
        [self.delegate tableShouldReload];
        
        
        
    //});

}

#pragma mark Mapview delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView*pinView=nil;
    if(annotation != self.mapView.userLocation)
    {
        static NSString * defaultPin = @"pin";
        pinView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPin];
        if(pinView==nil) {
            pinView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:defaultPin];
        }
        pinView.pinColor=MKPinAnnotationColorRed;
        pinView.canShowCallout=YES;
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.animatesDrop=YES;
    }
    else
    {
        [self.mapView.userLocation setTitle:@"You are Here!"];
    }
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    RestaurantDetailViewController * restaurantDetailVC = [[RestaurantDetailViewController alloc] init];
    restaurantDetailVC.title = @"Restaurant Detail";
    restaurantDetailVC.annotation = view.annotation;
    [self.navigationController pushViewController:restaurantDetailVC animated:YES];
}


#pragma mark Splitview delegate

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    /*
    UINavigationController * navDetail = svc.viewControllers[1];
    pc.contentViewController = (DetailViewController*)navDetail.viewControllers[0];
     */
    barButtonItem.title = NSLocalizedString(@"Restaurants", @"Restaurants");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

#pragma mark Reachability
- (BOOL) isReachableToHost {
    Reachability * r = [Reachability reachabilityWithHostName:@"http://cmshopper.herokuapp.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

- (void)initAlertWithMessage:(NSString*)message {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
@end
