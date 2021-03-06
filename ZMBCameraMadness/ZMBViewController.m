//
//  ZMBViewController.m
//  ZMBCameraMadness
//
//  Created by Zuri Biringer on 11/5/13.
//  Copyright (c) 2013 Zuri Biringer. All rights reserved.
//

#import "ZMBViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

@interface ZMBViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

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
        
//        UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
//        overlayView.layer.borderColor = [[UIColor redColor] CGColor];
//        overlayView.layer.borderWidth = 5.0f;
//        _picker.cameraOverlayView = overlayView;
//        
//        UIButton *overlayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
//        overlayButton.center = overlayView.center;
//        overlayButton.backgroundColor = [UIColor yellowColor];
//        overlayButton.titleLabel.text = @"Close picker";
//        overlayButton.titleLabel.textColor = [UIColor redColor];
//        [overlayButton addTarget:self
//                          action:@selector(overlayButtonTapped)
//                forControlEvents:UIControlEventTouchUpInside];
//        [overlayView addSubview:overlayButton];

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

- (void)overlayButtonTapped
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
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
    // filter the image
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    
    [filter setValue:ciImage forKey:kCIInputImageKey];
    
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGRect extent = [result extent];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];
    
    UIImage *filteredImage = [UIImage imageWithCGImage:cgImage];
    
    // show the image to the user
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [_imageView setImage:filteredImage];
    [self.view addSubview:_imageView];
    
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
        NSLog(@"info: %@", contextInfo);
    }
}

#pragma mark - Social Kit

- (IBAction)shareAction:(UIButton *)sender
{
    SLComposeViewController *shareViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [shareViewController setInitialText:@"Hihihihihihi"];
    [shareViewController addImage:_imageView.image];
    [shareViewController addURL:[NSURL URLWithString:@"http://facebook.com/zuri.biringer"]];
    [self presentViewController:shareViewController animated:YES completion:nil];
}

#pragma mark - MessageUI Kit

- (IBAction)emailPhoto:(UIButton *)sender
{
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Hi from inside my app!"];
        // Attach image somehow...
        NSData *sendImage = UIImageJPEGRepresentation(_imageView.image, 0.0);
        [mailViewController addAttachmentData:sendImage mimeType:@"image/jpeg" fileName:@"ZBImageAppImage.jpg"];
        NSString *emailBody = @"http://hihihihihihihihihiiihihihihihihihhi.com/2010/11/tao-lins-drawing-style-re-2006-2010.html";
        [mailViewController setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:nil];
    } else {
        // Might want to make this an actionsheet or alert?
        NSLog(@"Device not configured to send mail.");
    }
}

- (IBAction)messagePhoto:(UIButton *)sender
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
        messageViewController.messageComposeDelegate = self;
        NSData *sendImage = UIImageJPEGRepresentation(_imageView.image, 0.0);
        [messageViewController addAttachmentData:sendImage typeIdentifier:@"public.jpeg" filename:@"ZBImageAppImage.jpg"];
        messageViewController.body = @"http://hihihihihihihihihiiihihihihihihihhi.com/2010/11/tao-lins-drawing-style-re-2006-2010.html";
        [self presentViewController:messageViewController animated:YES completion:nil];
    } else {
        // Might want to make this an actionsheet or alert?
        NSLog(@"Device not configured to send SMS.");
    }
    
}

#pragma mark - Delegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: Mail sending canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: Mail sending failed");
            break;
        default:
            NSLog(@"Result: Mail not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Result: SMS sending canceled");
            break;
        case MessageComposeResultSent:
            NSLog(@"Result: SMS sent");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Result: SMS sending failed");
            break;
        default:
            NSLog(@"Result: SMS not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
