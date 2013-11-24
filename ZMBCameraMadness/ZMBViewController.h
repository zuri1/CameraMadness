//
//  ZMBViewController.h
//  ZMBCameraMadness
//
//  Created by Zuri Biringer on 11/5/13.
//  Copyright (c) 2013 Zuri Biringer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZMBViewController : UIViewController

@property (nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSURL *photoURL;

@end