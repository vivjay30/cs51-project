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
    [self.tabBarController.tabBar setHidden:YES];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
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
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TakenPictureViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TakenPicture"];
    vc.picture =  imageData;
    [picker pushViewController:vc animated:YES];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.tabBarController setSelectedIndex:0];
}


@end
