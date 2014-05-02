//
//  TakenPictureViewController.h
//  Tago
//
//  Created by Vivek Jayaram on 4/30/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePickerViewController.h"

@interface TakenPictureViewController : UITableViewController
@property NSMutableArray *gamesArray;
@property NSMutableArray *targetsArray;
@property ImagePickerViewController *imagePicker;
@property NSData *picture;
- (void) updateGames;
- (void) updateTargets;
- (IBAction)goBackToPicture:(id)sender;
- (void) saveGame;

@end
