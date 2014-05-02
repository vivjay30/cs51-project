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
    
    NSString *hey = @"hey";
    NSString *hey2 = @"hey";
    NSSet * heySet = [[NSSet alloc] initWithObjects:hey, nil];
    NSSet *heyset2 = [[NSSet alloc] initWithObjects:hey2, nil];
    [heySet intersectsSet:heyset2];
    NSLog(@"%i", heySet.count);
    
    
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
                    BOOL somebody = NO;
        for (NSDictionary<FBGraphUser> *friend in friends) {
            if (friend.installed)
            {
                somebody = YES;
                // Get the PFUser of all the facebook ids
                PFQuery *query = [PFUser query];
                [query whereKey:@"Facebookid" equalTo:friend.id];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                    if (!error){
                            for (PFObject *object in objects){
                                [self.FacebookUsers addObject:object];
                                [self.tableView reloadData];
                        }
                    }
                }];
            }
        }
        if (!somebody)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Announcement" message: @"You need to get friends on the app. Invite Some Friends." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alert show];
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
    if (self.gameUsers.count != 0)
    {
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
- (BOOL) UserinArray: (PFUser *) myuser : (NSArray *) myArray{
    for (PFUser *arrayUser in myArray){
        if ([myuser.objectId isEqualToString:arrayUser.objectId]){
            return YES;
        }
    }
    return NO;
}
- (void) goToSuggestions: (id)sender {
    self.suggestedUsers = [[NSMutableArray alloc] init];
    self.gameUsers = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.FacebookUsers count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:2];
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
            int i = 0;
            __block int k = 0;
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
                            if ([founduser.objectId isEqualToString:[PFUser currentUser].objectId] || ([self UserinArray:founduser :self.gameUsers]))  {
                            }
                            else {
                                if ([tempdict objectForKey:founduser.objectId] == nil) {
                                    [tempdict setObject:[NSNumber numberWithDouble:0] forKey:founduser.objectId];
                                    
                                }
                                
                                double ir = 0;
                                if ([((PFUser *)foundgame[@"creator"]).objectId isEqualToString:[PFUser currentUser].objectId])
                                {
                                    
                                    ir = omega * pow(0.5, ((double)[[NSDate date] timeIntervalSinceDate:foundgame.createdAt]/ 1000));
                                    
                                }
                                
                                else
                                    
                                {
                                    
                                    ir = pow(0.5, (double)[[NSDate date] timeIntervalSinceDate:foundgame.createdAt]/ 1000);
                                    
                                }
                                
                                //finding intersection
                                NSMutableArray *temparray1 = [[NSMutableArray alloc] init];
                                NSMutableArray *temparray2 = [[NSMutableArray alloc] init];
                                for (PFUser *tempuser1 in self.gameUsers) {
                                    [temparray1 addObject:tempuser1.objectId];
                                }
                                for (PFUser *tempuser2 in foundusers) {
                                    [temparray2 addObject:tempuser2.objectId];
                                }
                                NSMutableSet *tempset1 = [NSMutableSet setWithArray:temparray1];
                                NSMutableSet *tempset2 = [NSMutableSet setWithArray:temparray2];
                                [tempset1 intersectSet:tempset2];
                                
                                double toadd = ir * weight * (double)[tempset1 count];
                                
                                double old = [[tempdict objectForKey:founduser.objectId] doubleValue];
                                
                                //NSLog(founduser[@"username"]);
                                
                                [tempdict setObject:([NSNumber numberWithDouble:(toadd + old)]) forKey:founduser.objectId];
                                
                            }
                        }
                    }
                    
                    NSArray *temparray = [tempdict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) { return [obj2 compare:obj1];
                        
                    }];
                    
                    
                    if (i == ([foundgames count] - 1)) {
                        for (NSString *uniqueid in temparray) {
                            PFQuery *queryid = [PFUser query];
                            [queryid getObjectInBackgroundWithId:uniqueid block:^(PFObject *userstore, NSError *storingerror) {
                                if (storingerror) {
                                    NSLog(@"Error: %@ %@", storingerror, [storingerror userInfo]);
                                }
                                else {
                                    
                                    [self.suggestedUsers addObject:userstore];
                                    
                                }
                                
                                if (k == [temparray count] - 1) {
                                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                    SuggestionsViewController *suggestionsPage = [storyboard instantiateViewControllerWithIdentifier:@"SuggestionsPage"];
                                    suggestionsPage.suggestedUsers = self.suggestedUsers;
                                    
                                    [self.navigationController pushViewController:suggestionsPage animated:YES];
                                }
                                k++;
                            }];
                            
                            
                        }
                        
                    }
                }];
                i++;
            }
        };
        
    }];
    
}
@end