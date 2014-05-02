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
    
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.delegate = self.tabBarController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
