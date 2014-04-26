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


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    //NSLog(@"Hey");
    NSString *name = [PFUser currentUser][@"name"];
    NSLog(name);
    self.navigationItem.title = name;
    [self updateGames];
   // NSLog([[PFUser currentUser] objectForKey:@"Profile"][@"name"]);

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.gamesArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.gamesArray[[indexPath row]][@"GameName"];
    
    return cell;
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
    [self dismissViewControllerAnimated:NO completion:nil];
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
- (void) updateGames {
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query whereKey:@"participants" equalTo:[PFUser currentUser]];
    [query whereKey:@"completed" equalTo:[NSNumber numberWithBool:NO]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *games, NSError *error) {
        self.gamesArray = [[NSMutableArray alloc] initWithArray: games];
        [self.tableView reloadData];
        
    }];
}

@end
