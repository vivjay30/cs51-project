//
//  NewGameViewController.m
//  Tago
//
//  Created by Vivek Jayaram on 4/24/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import "NewGameViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SuggestionsViewController.h"
#import "HomePageViewController.h"

@interface NewGameViewController ()

@end

@implementation NewGameViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *startGame = [[UIBarButtonItem alloc] initWithTitle:@"Start Game" style:UIBarButtonItemStyleBordered target:self action:@selector(startGameTouchHandler:)];
    self.navigationItem.rightBarButtonItem = startGame;
    UIBarButtonItem *suggestionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Suggestions" style:UIBarButtonItemStyleBordered target:self action:@selector(goToSuggestions:)];
    self.navigationItem.LeftBarButtonItem = suggestionsButton;
    self.gameNameText = [[UITextField alloc] initWithFrame:CGRectMake(14, 13, 280, 21)];
    self.gameNameText.textAlignment = NSTextAlignmentLeft;
    self.gameNameText.text = [NSString stringWithFormat:@"%@'s game", [PFUser currentUser][@"name"]];

    
    [self getFriends];
    
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
     //                              initWithTarget:self
       //                            action:@selector(dismissKeyboard)];
    
    //[self.view addGestureRecognizer:tap];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    
    else if (section == 1)
    {
        
        return 1;
    }
    // Return the number of rows in the section.
    else
    {
        return self.FacebookUsers.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0)
    {
        return @"Choose Game Name";
    }
    else if (section == 1)
    {
        return @"Choose Game Duration";
    }
    else
    {
        return @"Choose Friends";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"cell"];
    }
    if ([indexPath section] == 0)
    {
        [cell.contentView addSubview:self.gameNameText];
    }
    if ([indexPath section] == 2){
        cell.textLabel.text = [self.FacebookUsers objectAtIndex:[indexPath row]][@"name"];
    }
    self.gameNameText.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void) getFriends {
    
    // Getting the list of all facebook friends
    self.FacebookUsers = [[NSMutableArray alloc] init];
    FBRequest* friendsRequest = [FBRequest requestWithGraphPath:@"me/friends?fields=installed,name" parameters:nil HTTPMethod:@"GET"];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        
        // Iterating over all the friends and see who has the app installed
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser> *friend in friends) {
            if (friend.installed)
            {
                // Get the PFUser of all the facebook ids
                PFQuery *query = [PFUser query];
                [query whereKey:@"Facebookid" equalTo:friend.id];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                    if (!error){
                        NSLog(@"Found %i objects", objects.count);
                        for (PFObject *object in objects){
                            [self.FacebookUsers addObject:object];
                            NSLog(@"%i", self.FacebookUsers.count);
                            [self.tableView reloadData];
                        }
                    }
                }];
            }
        }
    }];
}

- (void)startGameTouchHandler:(id)sender {
    
    // Getting the users that were selected
    self.gameUsers = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.FacebookUsers count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:2];
        UITableViewCell *aCell = (UITableViewCell*) [self.tableView cellForRowAtIndexPath:indexPath];
        if (aCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [self.gameUsers addObject:self.FacebookUsers[i]];
        }
    }
    
    [self makeGame];
    
    // Popping back to the home page and updating the games
    UINavigationController *navc = [self.tabBarController.viewControllers objectAtIndex:0];
    HomePageViewController *homepage = [navc.viewControllers objectAtIndex:0];
    [navc popToRootViewControllerAnimated:NO];
    [homepage updateGames];
    [homepage.tableView reloadData];
    [self.tabBarController setSelectedIndex:0];
    
    // Destroying the current New Game Page
    UINavigationController *mynavc = [self.tabBarController.viewControllers objectAtIndex:1];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewGameViewController *newgamevs = [storyboard instantiateViewControllerWithIdentifier:@"NewGame"];
    mynavc.viewControllers = [[NSArray alloc] initWithObjects: newgamevs, nil];
}

- (void) makeGame {
    PFObject *newGame = [PFObject objectWithClassName:@"Game"];
    [newGame setObject:[PFUser currentUser] forKey:@"creator"];
    NSString *gamename = self.gameNameText.text;

    [newGame setObject:gamename forKey:@"GameName"];
    [newGame setObject:[NSNumber numberWithBool:NO] forKey:@"completed"];
    PFRelation *relation = [newGame relationforKey:@"participants"];
    [self.gameUsers addObject:[PFUser currentUser]];
    for (PFUser *user in self.gameUsers)
    {
        [relation addObject: user];
    }
    
    // Setting the targets to be randomly distributed
    NSMutableArray *targets = [[NSMutableArray alloc] initWithArray:self.gameUsers];
    NSUInteger count = [targets count];
    NSMutableDictionary *targetsdict = [[NSMutableDictionary alloc] init];
    for (NSUInteger i = 0; i < count; ++i) {
        int n;
        do
        {
            n = arc4random() % count;
        }while (n == i);
        [targetsdict setObject:((PFUser *)self.gameUsers[n]).objectId forKey:((PFUser *)targets[i]).objectId];
    }
    [newGame setObject:targetsdict forKey:@"targets"];
    
    // Save the game
    [newGame saveInBackground];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
//-(void)dismissKeyboard {
  //  [self.gameNameText resignFirstResponder];
//}
- (void) goToSuggestions: (id)sender {
    
    self.gameUsers = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.FacebookUsers count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *aCell = (UITableViewCell*) [self.tableView cellForRowAtIndexPath:indexPath];
        if (aCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [self.gameUsers addObject:self.FacebookUsers[i]];
        }
    }
    
    if ([self.gameUsers count] == 0)
    {
        [self.gameUsers addObject:self.FacebookUsers[0]];
    }
    
    
    double omega = 1.5;
    
    double weight = 1.3;
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query whereKey:@"participants" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *foundgames, NSError *errorgame) {
        if (errorgame) {
            NSLog(@"Error: %@ %@", errorgame, [errorgame userInfo]);
        }
        else
        {
            
            NSMutableDictionary *tempdict = [[NSMutableDictionary alloc] init];
 
            for (PFObject *foundgame in foundgames) {
          
                PFRelation *relation = [foundgame relationforKey:@"participants"];
            
                PFQuery *query2 = [relation query];
           
                [query2 findObjectsInBackgroundWithBlock:^(NSArray *foundusers, NSError *erroruser) {
                  
                    if (erroruser) {
                        
                        NSLog(@"Error: %@", [erroruser userInfo][@"error"]);
                        
                    }
                    else {
                        
                        for (PFUser *founduser in foundusers)
                            
                        {
                            if ((founduser.objectId != [PFUser currentUser].objectId) && ([self.gameUsers indexOfObject:founduser] == NSNotFound) && ([tempdict objectForKey:founduser.objectId] == nil)) {
                                [tempdict setObject:[NSNumber numberWithDouble:0] forKey:founduser.objectId];
                                
                            }
                      
                            double ir = 0;
      
                            if (foundgame[@"creator"] == [PFUser currentUser])
                            {
                                
                                ir = omega * pow(0.5, (double)[[NSDate date] timeIntervalSinceDate:foundgame.createdAt]);
                                
                            }

                            else
                                
                            {
                                
                                ir = pow(0.5, (double)[[NSDate date] timeIntervalSinceDate:foundgame.createdAt]);
                                
                            }
   
                            //finding intersection

                            NSMutableSet *tempset = [NSMutableSet setWithArray:self.gameUsers];
                            NSMutableSet *tempset2 = [NSMutableSet setWithArray:foundusers];

                            [tempset intersectSet:(tempset2)];

                            double toadd = ir * weight * (double)[tempset count];
 
                            double old = [[tempdict objectForKey:founduser] doubleValue];

                            //NSLog(founduser[@"username"]);
                            
                            [tempdict setObject:([NSNumber numberWithDouble:(toadd + old)]) forKey:founduser.objectId];
                            
                        }
                    }
                    
                    self.suggestedUsers = [tempdict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) { return [obj2 compare:obj1];
                }];
                    
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    SuggestionsViewController *suggestionsPage = [storyboard instantiateViewControllerWithIdentifier:@"SuggestionsPage"];
                    suggestionsPage.suggestedUsers = self.suggestedUsers;
                    [self.navigationController pushViewController:suggestionsPage animated:YES];

                }];
                
                // suggestedUsers returns an NSArray of objectIDs, which are strings, corresponding to PFUsers, hopefully
                
                // in increasing order from most suggested to least suggested
                
            }
        };
        
    }];
    
}
@end