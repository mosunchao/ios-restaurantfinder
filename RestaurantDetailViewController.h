//
//  RestaurantDetailViewController.h
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/26/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAnnotation.h"
#import "FacebookLocationSharer.h"

@interface RestaurantDetailViewController : UIViewController<FacebookLocationSharerDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) CustomAnnotation * annotation;
@end
