//
//  RestaurantDetailViewController.m
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/26/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import "RestaurantDetailViewController.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define KEY_USER @"AIzaSyAw0m3prCKzqP-zrWauU7DsXJgMDnbQY-Y"

@interface RestaurantDetailViewController ()
@property (strong,nonatomic) NSMutableData * receivedData;
@end

@implementation RestaurantDetailViewController {
    NSString * currentPlaceID;
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
    // UI setup
    UIBarButtonItem * btnShare = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleBordered target:self action:@selector(postToSocialViaSL:)];
    self.navigationItem.rightBarButtonItem = btnShare;
    
    self.titleLabel.text = self.annotation.title;
    self.addressLabel.text = self.annotation.subtitle;
    self.ratingLabel.text = [@"User Rating: " stringByAppendingString:self.annotation.rating.stringValue];
    
    // get image
    NSString * str = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&sensor=true&key=%@",self.annotation.photoReference,KEY_USER];
    NSURL * url = [NSURL URLWithString:str];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request  delegate:self];
    if (conn) {
        self.receivedData = [NSMutableData data];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    float center = self.view.frame.size.width/2;
    self.imageView.center = CGPointMake(center, 200);
    
    self.titleLabel.center = CGPointMake(center, 350);
    self.addressLabel.center = CGPointMake(center, 400);
    self.ratingLabel.center = CGPointMake(center, 450);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneSearchingWithPlaceID:(NSString *)placeID {
    currentPlaceID = placeID;
}

- (void) postToSocialViaSL:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        //NSLog(@"here");
        //SLComposeViewController * composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        //[self presentViewController:composeController animated:YES completion:nil];
        FacebookLocationSharer * fbSearch = [[FacebookLocationSharer alloc] init];
        fbSearch.delegate = self;
        [fbSearch searchRestaurantAtLatitude:self.annotation.coordinate.latitude longitude:self.annotation.coordinate.longitude];
        
        if (currentPlaceID == nil) {
            NSLog(@"Cannot find this place on facebook");
            return;
        }
        
        // getting account and info
        ACAccountStore * accountStore = [[ACAccountStore alloc] init];
        ACAccountType * accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSDictionary * readOptions = @{
                                       ACFacebookAppIdKey: @"160727617451830",
                                       ACFacebookPermissionsKey: @[@"email"],
                                       ACFacebookAudienceKey: ACFacebookAudienceFriends};
        
        
        // asking Read Permission for the first time
        [accountStore requestAccessToAccountsWithType:accountType options:readOptions completion:^(BOOL granted, NSError * error) {
            if (granted == YES) {
                // Get account and communicate with Facebook API
                NSDictionary * writeOptions = @{
                                                ACFacebookAppIdKey: @"160727617451830",
                                                ACFacebookPermissionsKey: @[@"publish_stream",@"publish_actions"],
                                                ACFacebookAudienceKey: ACFacebookAudienceFriends};
                // asking write permission
                [accountStore requestAccessToAccountsWithType:accountType options:writeOptions completion:^(BOOL granted, NSError * error) {
                    if (granted == YES) {
                        
                        NSArray * accounts = [accountStore accountsWithAccountType:accountType];
                        ACAccount * facebookAccount = accounts.lastObject;
                        
                        NSDictionary * postDict = @{
                                                    @"status": @"Sharing this location using myMapApp",
                                                    @"place": currentPlaceID};
                        NSURL * feedURL = [NSURL URLWithString:@"http://graph.facebook.com/me/feed"];
                        SLRequest * feedRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:feedURL parameters:postDict];
                        
                        feedRequest.account = facebookAccount;
                        [feedRequest performRequestWithHandler:^(NSData * responseData, NSHTTPURLResponse * urlResponse, NSError * error) {
                            NSLog(@"Facebook HTTP response: %i", urlResponse.statusCode);
                            NSLog(@"Facebook HTTP error: %@", [error localizedDescription]);
                        }];
                        
                        
                    } else {
                        NSLog(@"error occurred at write: %@", error.localizedDescription);
                    }
                }];
            } else {
                NSLog(@"error occurred at read: %@", error.localizedDescription);
            }
        }];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Finished Loading");
    self.imageView.image = [UIImage imageWithData:self.receivedData];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
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
