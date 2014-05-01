//
//  TakenPictureViewController.h
//  Tago
//
//  Created by Vivek Jayaram on 4/30/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TakenPictureViewController : UITableViewController
@property NSMutableArray *gamesArray;
@property NSMutableArray *targetsArray;
@property NSData *picture;
- (void) updateGames;
- (void) updateTargets;

@end
