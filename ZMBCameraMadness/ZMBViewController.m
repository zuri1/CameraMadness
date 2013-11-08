//
//  ZMBViewController.m
//  ZMBCameraMadness
//
//  Created by Zuri Biringer on 11/5/13.
//  Copyright (c) 2013 Zuri Biringer. All rights reserved.
//

#import "ZMBViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ZMBViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@end

@implementation ZMBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerController

-(IBAction)choosePhoto:(id)sender
{
    _picker = [[UIImagePickerController alloc] init];
    [_picker setDelegate:self];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [_picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [_picker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }

    [_picker setAllowsEditing:YES];
    [self presentViewController:_picker animated:YES completion:^{
        NSLog(@"Showing Camera");
    }];
    
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        NSLog(@"%i",[group numberOfAssets]);
    } failureBlock:^(NSError *error) {
        if (error.code == ALAssetsLibraryAccessUserDeniedError) {
            NSLog(@"user denied access, code: %i",error.code);
        }else{
            NSLog(@"Other error code: %i",error.code);
        }
    }];
    
    UIActionSheet *myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Picture", @"Use Camera Roll", nil];
    [myActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"The %@ button was tapped.", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex == 1)
    {
        [_picker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
    if (buttonIndex == 2)
    {
        [_picker dismissViewControllerAnimated:YES completion:^{
            NSLog(@"User cancelled action sheet");
        }];
    }

    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        
        [self applyFilterToImage:pickedImage];
        
    }];
}

- (void)applyFilterToImage:(UIImage *)image
{
    // filter the imagae
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    
    [filter setValue:ciImage forKey:kCIInputImageKey];
    
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGRect extent = [result extent];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];
    
    UIImage *filteredImage = [UIImage imageWithCGImage:cgImage];
    
    // show the image to the user
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [imageView setImage:filteredImage];
    [self.view addSubview:imageView];
    
    // save the image to the photos album
    UIImageWriteToSavedPhotosAlbum(filteredImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"User cancelled image selection");
    }];
}

- (void)image: (UIImage *)image didFinishSavingWithError: (NSError *) error
  contextInfo: (void *) contextInfo
{
    if (error) {
        NSLog(@"Unable to save photo to camera roll");
    } else {
        NSLog(@"Saved image to camera roll");
    }
}

@end
