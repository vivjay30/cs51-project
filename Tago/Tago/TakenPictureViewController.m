//
//  TakenPictureViewController.m
//  Tago
//
//  Created by Vivek Jayaram on 4/30/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import "TakenPictureViewController.h"
#import <Parse/Parse.h>
#import "CellTakenPicture.h"

@interface TakenPictureViewController ()

@end

@implementation TakenPictureViewController

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
    [self.tabBarController.tabBar setHidden:NO];
    [self updateGames];
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
    return [self.gamesArray count];
}


- (CellTakenPicture *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellTakenPicture *cell = [tableView dequeueReusableCellWithIdentifier:@"GameCell"];
    
    if(cell == nil)
    {
        cell = [[CellTakenPicture alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"GameCell"];
    }
    cell.GameText.text = self.gamesArray[[indexPath row]][@"GameName"];
    cell.TargetText.text = self.targetsArray[[indexPath row]][@"name"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:self.picture];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // Create a PFObject around a PFFile and associate it with the current user
            PFObject *photoTag = [PFObject objectWithClassName:@"PhotoTag"];
            [photoTag setObject:imageFile forKey:@"imageFile"];
            
            // Set the access control list to current user for security purposes
            photoTag.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            PFUser *user = [PFUser currentUser];
            [photoTag setObject:user forKey:@"Taker"];
            
            [photoTag setObject:[self.targetsArray objectAtIndex:[indexPath row]] forKey:@"PictureOf"];
            [photoTag setObject:[self.gamesArray objectAtIndex:[indexPath row]] forKey:@"Game"];
            
            [photoTag saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}
- (void) updateGames {
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query whereKey:@"participants" equalTo:[PFUser currentUser]];
    [query whereKey:@"completed" equalTo:[NSNumber numberWithBool:NO]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *games, NSError *error) {
        self.gamesArray = [[NSMutableArray alloc] initWithArray: games];
        [self updateTargets];
    }];
}
- (void) updateTargets {
    self.targetsArray = [[NSMutableArray alloc] init];
    for (PFObject *game in self.gamesArray){
        PFQuery *query = [PFUser query];
        PFUser *target = [query getObjectWithId:[game[@"targets"] objectForKey:[PFUser currentUser].objectId]];
        [self.targetsArray addObject:target];
    }
    [self.tableView reloadData];
}
@end
