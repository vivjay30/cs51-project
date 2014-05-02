//
//  HomePageViewController.m
//  Tago
//
//  Created by Vivek Jayaram on 4/21/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import "HomePageViewController.h"
#import <Parse/Parse.h>
#import "GamePage.h"

@interface HomePageViewController ()

@end

@implementation HomePageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
  //  UITabBarController *tabBarController = self.tabBarController;
   // UITabBar *tabBar = tabBarController.tabBar;
    
    UITabBarItem *tabBarItem1 = [self.tabBarController.tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [self.tabBarController.tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [self.tabBarController.tabBar.items objectAtIndex:2];

    
    tabBarItem1.title = @"Home";
    tabBarItem2.title = @"New Game";
    tabBarItem3.title = @"Tag";
    // Do any additional setup after loading the view.
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    NSString *name = [PFUser currentUser][@"name"];
    self.navigationItem.title = name;
    [self updateGames];

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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GamePage *newGamePage = [storyboard instantiateViewControllerWithIdentifier:@"GamePage"];
    newGamePage.currentGame = [self gamesArray][[indexPath row]];
    [self.navigationController pushViewController:newGamePage animated:YES];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0){
        return @"Curent Games";
    }
    else
        return @"blah";
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
