//
//  NewGameViewController.h
//  Tago
//
//  Created by Vivek Jayaram on 4/24/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NewGameViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property NSMutableArray *FacebookUsers;

@property NSMutableArray *gameUsers;

@property NSMutableArray *suggestedUsers;

@property UITextField *gameNameText;
- (void) makeGame;
- (void) goToSuggestions: (id)sender;
- (BOOL) UserinArray: (PFUser *) myuser : (NSArray *) myArray;
@end
