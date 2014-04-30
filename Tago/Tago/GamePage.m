//
//  GamePage.m
//  Tago
//
//  Created by Vivek Jayaram on 4/29/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import "GamePage.h"

@interface GamePage ()

@end

@implementation GamePage

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
    self.navigationItem.title = self.currentGame[@"GameName"];
    PFRelation *RelationParts = [self currentGame][@"participants"];
    self.participants = [RelationParts.query findObjects];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0)
    {
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" equalTo:((PFUser *)[[self currentGame][@"targets"] objectForKey:[PFUser currentUser].objectId]).objectId];
        PFUser *target = [query findObjects][0];
        return [NSString stringWithFormat:@"Your Target is %@", target[@"name"]];
    }
    else if (section == 1)
    {
        return @"Rankings";
    }
    else
    {
        return @"Recent Activity";
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1)
    {
        return self.participants.count;
    }
    else
    {
        return 1;
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
    if ([indexPath section] == 1)
    {
        cell.textLabel.text = self.participants[[indexPath row]][@"name"];
    }
    else
    {
        cell.textLabel.text = @"hey";
    }
    return cell;
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
