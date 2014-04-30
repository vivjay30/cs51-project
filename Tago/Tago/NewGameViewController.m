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

    
    [self getFriends];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.FacebookUsers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [self.FacebookUsers objectAtIndex:[indexPath row]][@"name"];
    
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
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) getFriends {
    self.FacebookUsers = [[NSMutableArray alloc] init];
    FBRequest* friendsRequest = [FBRequest requestWithGraphPath:@"me/friends?fields=installed,name" parameters:nil HTTPMethod:@"GET"];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser> *friend in friends) {
            if (friend.installed)
            {
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
    
    self.gameUsers = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[self.FacebookUsers count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *aCell = (UITableViewCell*) [self.tableView cellForRowAtIndexPath:indexPath];
        if (aCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [self.gameUsers addObject:self.FacebookUsers[i]];
        }
    }
    
    [self makeGame];
    [self performSegueWithIdentifier:@"StartedGame" sender:self];
    
}

- (void) makeGame {
    PFObject *newGame = [PFObject objectWithClassName:@"Game"];
    [newGame setObject:[PFUser currentUser] forKey:@"creator"];
    NSString *gamename = [NSString stringWithFormat:@"%@'s game", [PFUser currentUser][@"name"]];

    [newGame setObject:gamename forKey:@"GameName"];
    [newGame setObject:[NSNumber numberWithBool:NO] forKey:@"completed"];
    PFRelation *relation = [newGame relationforKey:@"participants"];
    [self.gameUsers addObject:[PFUser currentUser]];
    for (PFUser *user in self.gameUsers)
    {
        [relation addObject: user];
    }
    NSMutableArray *targets = [[NSMutableArray alloc] initWithArray:self.gameUsers];
    
    NSUInteger count = [targets count];
    NSMutableDictionary *targetsdict = [[NSMutableDictionary alloc] init];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int n;
        do
        {
            n = arc4random() % count;
        }while (n == i);
        [targetsdict setObject:self.gameUsers[n] forKey:((PFUser *)targets[i]).objectId];
    }
    [newGame setObject:targetsdict forKey:@"targets"];
    
    [newGame saveInBackground];
}

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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"SelectedGame"])
    {
        // Get reference to the destination view controller
        HomePageViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc updateGames];
        [vc.tableView reloadData];
    }
}



@end