//
//  PictureViewController.m
//  Tago
//
//  Created by Vivek Jayaram on 4/29/14.
//  Copyright (c) 2014 Vivek Jayaram. All rights reserved.
//

#import "PictureViewController.h"
#import "TakenPictureViewController.h"
#import <Parse/Parse.h>

@interface PictureViewController ()

@end

@implementation PictureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [self cameraButtonTapped:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *moveOnButton = [[UIBarButtonItem alloc] initWithTitle:@"->" style:UIBarButtonItemStyleBordered target:self action:@selector(cameraButtonTapped:)];
    self.navigationItem.rightBarButtonItem = moveOnButton;
    
}

- (IBAction)cameraButtonTapped:(id)sender{
    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    
    // Delegate is self
    imagePicker.delegate = self;
    
    // Show image picker
    [self presentViewController:imagePicker animated:YES completion:nil];


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    self.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [self.image drawInRect: CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(self.image, 0.05f);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TakenPictureViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TakenPicture"];
    vc.picture =  imageData;
    [picker pushViewController:vc animated:YES];
    
}

- (void)uploadImage:(NSData *)imageData
{
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // Create a PFObject around a PFFile and associate it with the current user
            PFObject *photoTag = [PFObject objectWithClassName:@"PhotoTag"];
            [photoTag setObject:imageFile forKey:@"imageFile"];
            
            // Set the access control list to current user for security purposes
            photoTag.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            PFUser *user = [PFUser currentUser];
            [photoTag setObject:user forKey:@"Tagger"];
            
            [photoTag saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
@end
