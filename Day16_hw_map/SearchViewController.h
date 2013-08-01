//
//  SearchViewController.h
//  Day16_hw_map
//
//  Created by Chao-Hung Sun on 7/26/13.
//  Copyright (c) 2013 Chao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchViewControllerDelegate <NSObject>

- (void) doneEnteringText:(NSString*)addressStr;

@end


@interface SearchViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) id delegate;

@end
