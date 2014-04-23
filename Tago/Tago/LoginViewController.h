//
//  LoginViewController.h
//  Tago
//
//  Created by Vivek Jayaram on 4/21/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LoginViewController : UIViewController
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)loginButtonTouchHandler:(id)sender;

@end
