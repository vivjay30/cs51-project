//
//  NewGameViewController.h
//  Tago
//
//  Created by Vivek Jayaram on 4/24/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewGameViewController : UITableViewController

@property NSMutableArray *FacebookUsers;

@property NSMutableArray *gameUsers;

@property NSArray *suggestedUsers;

- (void) makeGame;
- (void) goToSuggestions: (id)sender;
@end
