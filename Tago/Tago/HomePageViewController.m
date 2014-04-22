//
//  HomePageViewController.m
//  Tago
//
//  Created by Vivek Jayaram on 4/21/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import "HomePageViewController.h"
#import <Parse/Parse.h>

@interface HomePageViewController ()

@end

@implementation HomePageViewController

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
    // Do any additional setup after loading the view.
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    NSLog(@"Hey");
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:1];
            userProfile[@"name"] = userData[@"name"];
            [[PFUser currentUser] setObject:userProfile forKey:@"Profile"];
            NSString *name = [[PFUser currentUser] objectForKey:@"Profile"][@"name"];
            self.navigationItem.title = name;
            //NSLog([[PFUser currentUser] objectForKey:@"Data"][@"name"]);
        }}];
   // NSLog([[PFUser currentUser] objectForKey:@"Profile"][@"name"]);

}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logoutButtonTouchHandler:(id)sender {
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    
    // Return to login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
