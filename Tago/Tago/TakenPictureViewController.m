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
    [self updateGames];
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
    cell.TargetText.text = @"hey";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
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
