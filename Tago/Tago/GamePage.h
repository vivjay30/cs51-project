//
//  GamePage.h
//  Tago
//
//  Created by Vivek Jayaram on 4/29/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface GamePage : UITableViewController
@property PFObject *currentGame;
@property NSArray *participants;
@property PFUser *target;

@end
