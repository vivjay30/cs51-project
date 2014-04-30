//
//  LoginViewController.m
//  Tago
//
//  Created by Vivek Jayaram on 4/21/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import "LoginViewController.h"
#import "HomePageViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController () {
    NSMutableArray *_objects;
}
@end

@implementation LoginViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // If Our user is Already logged in then update profile which goes to the next page
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self performSegueWithIdentifier:@"LogIn" sender:self];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

// Action on the login button
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self updateProfile];
            
        } else {
            [self updateProfile];
            NSLog(@"User with facebook logged in!");
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void)updateProfile {
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            [[PFUser currentUser] setObject:userData[@"name"] forKey:@"name"];
            [[PFUser currentUser] setObject:userData[@"id"] forKey:@"Facebookid"];
            [[PFUser currentUser] saveInBackground];
            [self performSegueWithIdentifier:@"LogIn" sender:self];
        }}
     ];
}
@end
