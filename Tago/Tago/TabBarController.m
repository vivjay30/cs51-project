//
//  TabBarController.m
//  Tago
//
//  Created by Vivek Jayaram on 5/1/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import "TabBarController.h"
#import "TakenPictureViewController.h"
#import "ImagePickerViewController.h"

@interface TabBarController ()

@end

@implementation TabBarController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(ImagePickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    self.myimage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [self.myimage drawInRect: CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(self.myimage, 0.05f);
    
    // Transition to the next page
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TakenPictureViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TakenPicture"];
    vc.picture =  imageData;
    [picker pushViewController:vc animated:YES];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.tabBar setHidden:NO];
    [self setSelectedIndex:0];
}

@end
