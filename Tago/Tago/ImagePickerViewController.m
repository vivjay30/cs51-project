//
//  ImagePickerViewController.m
//  Tago
//
//  Created by Vivek Jayaram on 5/1/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "TakenPictureViewController.h"

@interface ImagePickerViewController ()

@end

@implementation ImagePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated{
    UIViewController *vc = self.visibleViewController;
    NSLog(NSStringFromClass([vc class]));
    if ([NSStringFromClass([vc class]) isEqualToString:@"PLUICameraViewController"]){
        
        [self.tabBarController.tabBar setHidden:YES];}

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.delegate = self.tabBarController;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Announcement" message: @"Your device has no camera." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alert show];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
