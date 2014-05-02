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
    [[self currentGame] refresh];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.currentGame[@"GameName"];
    
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
        cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", self.participants[[indexPath row]][@"name"], self.scores[[indexPath row]]];
    }
    else if ([indexPath section] == 0)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", self.target[@"name"]];;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


// Our algorithm using pagerank to get the sorted list of users
- (void) updateRankings: (PFObject *)game;
{
    //we can make more complex if needed
    int i = 4;
    double d = 0.85;
    //Initialize an empty mutable array
    //Query Parse for all phototags associated with this specific game game - put in array
    self.participants = [[NSMutableArray alloc] init];
    self.scores = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"PhotoTag"];
    
    [query whereKey:@"Game" equalTo:game];
    
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
                    //Query game for participants array - find couqnt of array (N)
                    int n = [participants count];
                    //Initialize an empty mutable dict opg
                    NSMutableDictionary *opg = [[NSMutableDictionary alloc] init];
                    //Initialize an empty mutable array
                    NSMutableArray *notags = [[NSMutableArray alloc] init];
                    for (PFUser *user in participants) {
                        
                        [opg setObject:[NSNumber numberWithDouble:((double)1/(double)n)] forKey:user.objectId];
                        PFQuery *queryuser = [PFQuery queryWithClassName:@"PhotoTag"];
                        
                        [queryuser whereKey:@"Game" equalTo:game];
                        [queryuser whereKey:@"PictureOf" equalTo:user];
                        PFObject *tagNumber = [queryuser getFirstObject];
                        if (tagNumber == nil) {
                            [notags addObject:user];
                        }
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
                            [queryin whereKey:@"Game" equalTo:game];
                            [queryin whereKey:@"Taker" equalTo:alluser];
                            NSArray *taggerin = [queryin findObjects]; //taggerin: array of tags by user
                            for (PFObject *usertagged in taggerin) {    // for each tag by user...
                                PFQuery *querytaggedtaggee = [PFQuery queryWithClassName:@"PhotoTag"];
                                [querytaggedtaggee whereKey:@"Game" equalTo:game];
                                [querytaggedtaggee whereKey:@"PictureOf" equalTo:usertagged[@"PictureOf"]];
                                NSArray *taggeetagger = [querytaggedtaggee findObjects]; // taggeetagger: array of tags by person user tagged
                                PFUser *dude = usertagged[@"PictureOf"]; // the person tagged
                                double oldvaluetaggee = [[opg objectForKey:dude.objectId] doubleValue];
                                double npgvalue = [[npg objectForKey:alluser.objectId] doubleValue];
                                double newvalue = npgvalue + (d * oldvaluetaggee / (double) [taggeetagger count]);
                                [npg setObject:[NSNumber numberWithDouble:newvalue] forKey:alluser.objectId];
                            }
                        }
                        opg = [npg mutableCopy];
                    }
                    NSArray *userIdRankings = [opg keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        return [obj2 compare:obj1];
                    }];
                    for (NSString *uniqueuser in userIdRankings) {
                        
                        PFQuery *queryrankuser = [PFUser query];
                        PFObject *usertostore = [queryrankuser getObjectWithId:uniqueuser];
                        [self.participants addObject:usertostore];
                        [self.scores addObject:[opg objectForKey:uniqueuser]];
                    }
                    [self.tableView reloadData];
                }
            }];
        }
    }];
}


@end
