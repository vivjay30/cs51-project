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
                NSLog(friend.id);
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
    [self.tabBarController setSelectedIndex:0];
    NSLog(@"%i", self.gameUsers.count);

    
}

- (void) makeGame {
    PFObject *newGame = [PFObject objectWithClassName:@"Game"];
    [newGame setObject:[PFUser currentUser] forKey:@"creator"];
    NSString *gamename = [NSString stringWithFormat:@"%@'s game", [PFUser currentUser][@"name"]];
    NSLog(gamename);

    [newGame setObject:gamename forKey:@"GameName"];
    [newGame setObject:NO forKey:@"completed"];
    PFRelation *relation = [newGame relationforKey:@"participants"];
    for (PFUser *user in self.gameUsers)
    {
        [relation addObject: user];
    }
    [relation addObject: [PFUser currentUser]];
    [newGame saveInBackground];
}

- (void) goToSuggestions {
    /*self.gameUsers = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.FacebookUsers count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *aCell = (UITableViewCell*) [self.tableView cellForRowAtIndexPath:indexPath];
        if (aCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [self.gameUsers addObject:self.FacebookUsers[i]];
        }
    }

    if ([self.gameUsers count] == 0) {
        [self.gameUsers addObject:self.FacebookUsers[0]];
    }
    double omega = 1.5;
    double weight = 1.3;
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query whereKey:@"participants" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *foundgames, NSError *errorgame)] {
        if (errorgame) {
            NSLog(@"Error: %@ %@", errorgame, [errorgame userInfo]);
        }
        else {
            NSMutableDictionary *tempdict = [[NSMutableDictionary alloc] init];
            for (PFObject *foundgame in foundgames) {
                PFRelation *relation = [result relationForKey:@"participants"]
                PFQuery *query2 = [relation query];
                [query findObjectsinBackgroundWithBlock:^(NSArray *foundusers, NSERRor *erroruser)] {
                    if (erroruser) {
                        NSLog(@"Error: &@ &@", erroruser, [erroruser userInfo]);
                    }
                    else {
                        for (PFUser *founduser in foundusers) {
                            if (founduser != [PFUser currentUser]) && ([self.gameUsers indexOfObject:founduser == NSIntegerMax]) && ([tempdict objectForKey:founduser] != nil) {
                                [tempdict setObject:(double)0 forKey:founduser];
                            }
                            double ir = if (foundgame.creator == [PFUser currentUser]) {
                                omega * pow(0.5, (double)[[NSDate date] timeIntervalSinceDate:foundgame.createdAt]);
                            }
                            else {
                                pow(0.5, (double)[[NSDate date] timeIntervalSinceDate:foundgame.createdAt]);
                            }
                            //finding intersection
                            NSMutableSet *tempset = [NSMutableSet setwithArray:gameUsers];
                            NSMutableSet *tempset2 = [NSMutableSet setwithArray:foundusers];
                            NSMutableSet *intersect = [tempset intersectSet:tempset2];
                            double toadd = ir * weight * (double)[intersect count];
                            double old = [tempdict objectForKey:founduser];
                            [tempdict setObject:(toadd + old) forKey:founduser]
                        }
                    }
                }
            }
            NSMutableArray self.suggestedUsers = [tempdict keysSortedByValueUsingSelector:NSOrderedDescending];
        }
        [self performSegueWithIdentifier:@"Suggestions" sender:self];
    };
*/
}
@end
