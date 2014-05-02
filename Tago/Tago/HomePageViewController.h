//
//  HomePageViewController.h
//  Tago
//
//  Created by Vivek Jayaram on 4/21/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePageViewController : UITableViewController
@property NSMutableArray *gamesArray;
- (void) updateGames;
- (void)logoutButtonTouchHandler:(id)sender;
@end
