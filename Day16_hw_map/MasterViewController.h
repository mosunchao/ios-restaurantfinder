//
//  MasterViewController.h
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/26/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "SearchViewController.h"
#import "SingletonRestaurants.h"

@interface MasterViewController : UITableViewController<UIPopoverControllerDelegate,UITableViewDataSource,UITableViewDelegate,RestaurantListDelegate>
@property (strong, nonatomic) DetailViewController * detailVC;
@property (strong, nonatomic) UIPopoverController * popOverController;
@property (strong, nonatomic) SingletonRestaurants * sharedData;
@end
