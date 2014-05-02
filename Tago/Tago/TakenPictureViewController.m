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

- (void)viewDidAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBarController.tabBar setHidden:NO];
    [self updateGames];
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBackToPicture:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
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
    [self savePhoto:indexPath];
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

- (IBAction)goBackToPicture:(id)sender{
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void) savePhoto: (NSIndexPath *) indexPath{
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [self.picture drawInRect: CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    PFObject *currentGame = [self.gamesArray objectAtIndex:[indexPath row]];
    PFUser *previousTarget = [self.targetsArray objectAtIndex:[indexPath row]];
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(self.picture, 0.05f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // Create a PFObject around a PFFile and associate it with the current user
            PFObject *photoTag = [PFObject objectWithClassName:@"PhotoTag"];
            [photoTag setObject:imageFile forKey:@"imageFile"];
            
            
            PFUser *user = [PFUser currentUser];
            [photoTag setObject:user forKey:@"Taker"];
            
            [photoTag setObject: previousTarget forKey:@"PictureOf"];
            [photoTag setObject:currentGame forKey:@"Game"];
            
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
    
    PFRelation *relation = [currentGame relationforKey:@"participants"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *participants, NSError *error){
        NSMutableDictionary *targetsdict = currentGame[@"targets"];
        int n;
        do
        {
            n = arc4random() % participants.count;
        }while ((participants.count == 2 && [((PFUser *)participants[n]).objectId isEqualToString:previousTarget.objectId]) || [((PFUser *)participants[n]).objectId isEqualToString: [PFUser currentUser].objectId]);
        
        [targetsdict setObject:((PFUser *)participants[n]).objectId forKey:[PFUser currentUser].objectId];
    }];
    [self goBackToPicture:self];
    [self.tabBarController setSelectedIndex:0];
    [self.tabBarController.tabBar setHidden:NO];
}

@end
