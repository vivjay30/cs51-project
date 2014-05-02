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
    //PFRelation *RelationParts = [self currentGame][@"participants"];
    //self.participants = [RelationParts.query findObjects];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[[self currentGame][@"targets"] objectForKey:[PFUser currentUser].objectId]];
    self.target = (PFUser *)[query getFirstObject];
    [self updateRankings:self.currentGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0)
    {

        return @"Your Target is ";//[NSString stringWithFormat:@"Your Target is %@", self.target[@"name"]];
    }
    else
    {
        return @"Rankings";
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
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
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
    else if ([indexPath section] == 0)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", self.target[@"name"]];;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void) updateRankings: (PFObject *)game;
{
    //we can make more complex if needed
    int i = 100;
    double d = 0.85;
    //Initialize an empty mutable array
    //Query Parse for all phototags associated with this specific game game - put in array
    
    PFQuery *query = [PFQuery queryWithClassName:@"PhotoTag"];
    
    [query whereKey:@"game" equalTo:game];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *tags, NSError *tagerror)    {
        if (tagerror) {
            NSLog(@"Error: %@ %@", tagerror, [tagerror userInfo]);
        }
        else {
            PFRelation *relation = [game relationforKey:@"participants"];
            
            PFQuery *query2 = [relation query];
            
            [query2 findObjectsInBackgroundWithBlock:^(NSArray *participants, NSError *parterror) {
                if (parterror) {
                    NSLog(@"Error: %@ %@", parterror, [parterror userInfo]);
                }
                else {
                    //Query game for participants array - find count of array (N)
                    int n = [participants count];
                    //Initialize an empty mutable dict opg
                    NSMutableDictionary *opg = [[NSMutableDictionary alloc] init];
                    //Initialize an empty mutable array
                    NSMutableArray *notags = [[NSMutableArray alloc] init];
                    for (PFUser *user in participants) {
                        
                        [opg setObject:[NSNumber numberWithDouble:((double)1/(double)n)] forKey:user.objectId];
                        PFQuery *queryuser = [PFQuery queryWithClassName:@"PhotoTag"];
                        
                        [queryuser whereKey:@"game" equalTo:game];
                        [queryuser whereKey:@"PictureOf" equalTo:user];
                        [queryuser findObjectsInBackgroundWithBlock:^(NSArray *taggeenumber, NSError *taggeeerror) {
                            if (taggeeerror) {
                                NSLog(@"Error: %@ %@", taggeeerror, [taggeeerror userInfo]);
                            }
                            else {
                                if ([taggeenumber count] == 0) {
                                    [notags addObject:user];
                                }
                            }
                        }];
                    }
                    for (int j = 0; j < i; j++) {
                        double dp = 0;
                        for (PFUser *notaguser in notags) {
                            dp = dp + d * [[opg objectForKey:notaguser.objectId] doubleValue]/n;
                        }
                        NSMutableDictionary *npg = [[NSMutableDictionary alloc] init];
                        for (PFUser *alluser in participants) {
                            
                            [npg setObject:[NSNumber numberWithDouble:(dp + ((double)1 - d)/n)] forKey:alluser.objectId];
                            PFQuery *queryin = [PFQuery queryWithClassName:@"PhotoTag"];
                            [queryin whereKey:@"game" equalTo:game];
                            [queryin whereKey:@"Taker" equalTo:alluser];
                            [queryin findObjectsInBackgroundWithBlock:^(NSArray *taggerin, NSError *taggererror) {
                                for (PFObject *usertagged in taggerin) {
                                    PFQuery *querytaggedtaggee = [PFQuery queryWithClassName:@"PhotoTag"];
                                    [querytaggedtaggee whereKey:@"game" equalTo:game];
                                    [querytaggedtaggee whereKey:@"PictureOf" equalTo:usertagged[@"PictureOf"]];
                                    [querytaggedtaggee findObjectsInBackgroundWithBlock:^(NSArray *taggeetagger, NSError *taggeetaggererror) {
                                        if (taggeetaggererror) {
                                            NSLog(@"Error: %@ %@", taggeetaggererror, [taggeetaggererror userInfo]);
                                        }
                                        else {
                                            double oldvaluetaggee = [[opg objectForKey:usertagged[@"PictureOf"]] doubleValue];
                                            double npgvalue = [[npg objectForKey:alluser.objectId] doubleValue];
                                            double newvalue = npgvalue + (d * oldvaluetaggee / (double) [taggeetagger count]);
                                            
                                            [npg setObject:[NSNumber numberWithDouble:newvalue] forKey:alluser.objectId];
                                        }
                                    }];
                                }
                            }];
                        }
                        opg = [npg mutableCopy];
                    }
                    NSArray *userIdRankings = [opg keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        return [obj2 compare:obj1];
                    }];
                    for (NSString *uniqueuser in userIdRankings) {
                        PFQuery *queryrankuser = [PFQuery queryWithClassName:@"User"];
                        [queryrankuser getObjectInBackgroundWithId:uniqueuser block:^(PFObject *usertostore, NSError *storeerror) {
                            if (storeerror) {
                                NSLog(@"Error: %@ %@", storeerror, [storeerror userInfo]);
                            }
                            else {
                                [self.participants addObject:usertostore];
                                // Stores an array of NSNumbers
                                [self.scores addObject:[opg objectForKey:uniqueuser]];
                                [self.tableView reloadData];
                                
                            }
                        }];
                        
                    }
                    
                }
            }];
        }
    }];
}


@end
