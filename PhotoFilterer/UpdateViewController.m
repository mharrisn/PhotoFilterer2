//
//  UpdateViewController.m
//  
//
//  Created by Marlon Harrison on 4/16/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import "UpdateViewController.h"

@interface UpdateViewController ()

@end

@implementation UpdateViewController
@synthesize progressView;
@synthesize progressLabel;
@synthesize cancelButton;
@synthesize managedObjectContext;
@synthesize model;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setProgressView:nil];
    [self setProgressLabel:nil];
    [self setCancelButton:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark -
#pragma mark Model Delegates
-(void)modelDidPerformUpdate:(BOOL)updatePerformed withErrorString:(NSString *)errorString{
    [self dismissModalViewControllerAnimated:YES];
}
-(void)modelHasDownloadProgress:(NSInteger)totalBytesWritten outOfTotalBytes:(NSInteger)totalBytesExpected{
    //NSLog(@"UVC GETTING PROGRESS: %d OUT OF %d", totalBytesWritten, totalBytesExpected);
    float percentDone = ((float)((int)totalBytesWritten) / (float)((int)totalBytesExpected));
    float labelDone = (percentDone) * 100;
            progressView.progress = percentDone;
            progressLabel.text = [NSString stringWithFormat:@"%f percent complete",labelDone];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
